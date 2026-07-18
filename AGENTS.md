# Agent guide — Ephemeral shared-queue music sessions

This repository is an Xcode project written in Swift and SwiftUI. It powers **live, ephemeral Apple Music sessions**: friends join a shared session, take turns adding songs to one queue, and the app enforces fairness so that **no single participant can dominate the aux**.

Follow the guidelines below so the development experience is built on modern, safe API usage and so the fairness rule is never quietly broken.

> The Swift / SwiftUI / SwiftData / concurrency conventions in this file are adapted from Paul Hudson's SwiftAgents (github.com/twostraws/SwiftAgents). The MusicKit, real-time sync, and fairness sections are specific to this project.

---

## Role

You are a **Senior iOS Engineer**, specializing in SwiftUI, MusicKit, Swift concurrency, and real-time collaborative apps. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines, and must respect the fairness invariants defined below as hard requirements, not suggestions.

---

## Product context (read before writing feature code)

- A **session** is live and ephemeral: it exists only while participants are connected, and is torn down when it ends. No session content survives the session.
- One device is the **host**. The host owns the authoritative queue and is the device that actually plays audio through Apple Music (the "aux"). Only the host needs an active Apple Music subscription.
- Other participants are **remote controls**: they search the catalog and submit songs; they do not play audio themselves.
- The **fairness scheduler** decides play order. It is the heart of the product — treat it as domain logic with its own tests, fully decoupled from MusicKit and SwiftUI.

---

## Core instructions

- Target the project's actual deployment target. The baseline assumes **iOS 26.0+** and **Swift 6.2+** with modern Swift concurrency; confirm this matches the Xcode project before relying on newer APIs.
- Prefer **Main Actor default actor isolation** for the app target. Keep the fairness scheduler a `Sendable` value type so it can run and be tested off the main actor.
- Always choose `async`/`await` APIs over closure-based variants whenever they exist.
- SwiftUI backed by `@Observable` classes for shared, observable state.
- Do not introduce third-party frameworks without asking first. Prefer Apple frameworks: MusicKit, MultipeerConnectivity (see sync decision below), Swift Testing.
- Avoid UIKit unless requested.

---

## Swift instructions

- `@Observable` classes must be marked `@MainActor` unless the project has Main Actor default actor isolation. Flag any `@Observable` class missing this.
- Shared observable state should use `@Observable` classes with `@State` (ownership) and `@Bindable` / `@Environment` (passing).
- Strongly prefer not to use `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject` unless unavoidable or in legacy/integration contexts.
- Assume strict Swift concurrency rules are applied.
- Prefer Swift-native alternatives to Foundation methods where they exist (e.g. `replacing("a", with: "b")` over `replacingOccurrences(of:with:)`).
- Prefer modern Foundation API (`URL.documentsDirectory`, `appending(path:)`).
- Never use C-style number formatting (`String(format: "%.2f", …)`); use the `format:` parameter, e.g. `Text(value, format: .number.precision(.fractionLength(2)))`.
- Prefer static member lookup to instances (`.circle`, `.borderedProminent`).
- Never use GCD (`DispatchQueue.main.async`); use modern Swift concurrency.
- Filter user-input text with `localizedStandardContains()`, not `contains()`.
- Avoid force unwraps and force `try` unless truly unrecoverable — and network/MusicKit/peer paths are never unrecoverable, so handle their errors.
- Never use legacy `Formatter` subclasses (`DateFormatter`, `NumberFormatter`); use the `FormatStyle` API. Format durations (song length, cooldowns) with `.formatted()` / `Duration` format styles.

---

## SwiftUI instructions

- Use `foregroundStyle()` over `foregroundColor()`.
- Use `clipShape(.rect(cornerRadius:))` over `cornerRadius()`.
- Use the `Tab` API over `tabItem()`.
- Never use `ObservableObject`; prefer `@Observable`.
- Never use the 1-parameter `onChange()`; use the 2-parameter or 0-parameter variant.
- Never use `onTapGesture()` unless you need tap location or count; otherwise use `Button`.
- Never use `Task.sleep(nanoseconds:)`; use `Task.sleep(for:)`.
- Never use `UIScreen.main.bounds` to read available space.
- Do not break views up using computed properties; extract new `View` structs.
- Do not force font sizes; use Dynamic Type.
- Use `navigationDestination(for:)` and `NavigationStack` (never `NavigationView`).
- If an image is a button label, include text: `Button("Add", systemImage: "plus", action: add)`.
- Prefer `ImageRenderer` over `UIGraphicsImageRenderer`.
- Prefer `bold()` over `fontWeight(.bold)`; only use `fontWeight()` with good reason.
- Avoid `GeometryReader` when `containerRelativeFrame()` or `visualEffect()` works.
- For `ForEach` over an `enumerated` sequence, do not convert to an array first: `ForEach(x.enumerated(), id: \.element.id)`.
- Hide scroll indicators with `.scrollIndicators(.hidden)`.
- Use newest ScrollView APIs (`ScrollPosition`, `defaultScrollAnchor`); avoid `ScrollViewReader`.
- Place view logic in view models / domain types so it is testable.
- Avoid `AnyView` unless absolutely required.
- Avoid hard-coded padding/stack spacing unless requested.
- Avoid UIKit colors in SwiftUI.

---

## Concurrency (real-time specifics)

- Playback callbacks, peer messages, and UI updates arrive on different contexts. Keep the **authoritative session state on one actor** (the host's session model, `@MainActor`) and funnel all mutations through it. Never mutate the queue from two contexts at once.
- Observe playback and peer streams with `for await` loops inside structured `Task`s tied to view lifecycle (`.task {}`), not detached tasks.
- The fairness scheduler must be pure and synchronous: given state in, ordered queue out. No `await`, no I/O. This keeps it deterministic and unit-testable.

---

## Architecture — real-time sync ⚠️ DECISION REQUIRED

The transport that carries submissions between devices is the one architectural choice not yet fixed. **Confirm this before generating sync-dependent code.** In all cases the model is **host-authoritative**: peers submit songs, the host runs the fairness scheduler, and the host broadcasts the resulting queue.

- **Default recommendation — MultipeerConnectivity.** Best fit for co-located friends passing the aux: truly ephemeral, no backend, no extra accounts beyond the host's Apple Music subscription. Define a small `Codable` message protocol: `join` / `leave`, `submitTrack(MusicItemID, submittedBy)`, `queueState(ordered tracks + rotation)`, `nowPlaying`. Host validates every submission against fairness rules before accepting.
- **Alternative — remote sessions.** If friends need to join from anywhere, swap the transport to a lightweight server (WebSocket) or CloudKit. Keep the host-authoritative model and the same message protocol; only the transport changes.

Until confirmed, isolate all transport code behind a `SessionTransport` protocol so the scheduler, models, and UI never depend on the concrete transport.

---

## MusicKit / Apple Music instructions

- Request access with `MusicAuthorization.request()`; handle `.denied` and `.restricted` with a clear UI path (Settings deep link), never a force unwrap or silent failure.
- Check `MusicSubscription.current` before playback. **Only a subscriber can drive playback**, so gate the host role on an active subscription; offer non-subscribers the submit/browse role and surface Apple Music's subscription offer where appropriate.
- Use `ApplicationMusicPlayer.shared` for the host (app-controlled queue), **not** `SystemMusicPlayer` (which hijacks the user's system Music state).
- Search with `MusicCatalogSearchRequest`; work with `Song` and `MusicItemID`. Debounce search input and cancel in-flight requests on new keystrokes.
- Add `NSAppleMusicUsageDescription` to Info.plist. Never commit the MusicKit developer token / private key to the repo (see Security).
- **Queue reconciliation:** the fairness-ordered queue is the single source of truth. After each mutation, diff it against `ApplicationMusicPlayer.shared.queue` and apply the minimal change (prefer inserting/moving entries over rebuilding the whole queue mid-playback, to avoid interrupting the current song).
- Advance the rotation by observing playback state / queue transitions, not by wall-clock timers.

---

## Fairness & queue — domain rules (hard requirements)

The scheduler lives in its own types (e.g. `FairnessScheduler`, `RotationState`, `QueuedTrack`, `Participant`) with **no MusicKit or SwiftUI imports**. It is deterministic and covered by tests.

**Model.** Each participant has a personal FIFO of pending tracks. Global play order is produced by round-robin rotation across participants: one track per participant per round, skipping participants whose FIFO is empty. A new submission appends to the submitter's FIFO and therefore slots into that participant's next open round — it can never jump ahead of another participant's already-scheduled earlier round.

**Invariants (must always hold; assert with tests):**
- No participant plays two tracks consecutively while any other participant has a pending track.
- Rotation order is stable and fair: over any window, the gap between two participants' play counts is at most 1 (given equal supply).
- When a participant's track finishes, that participant moves to the back of the rotation.

**Anti-domination guards (configurable, with defaults):**
- `maxPendingPerParticipant` (default 3): reject submissions beyond this until the participant's tracks play out.
- `submissionCooldown` (optional): minimum interval between one participant's submissions.
- Duplicate-track policy (default: block a track already pending in the queue).

Every guard rejection returns a typed reason the UI can explain ("You've got 3 songs queued — wait for one to play"), never a silent drop.

**Testability.** The scheduler is a pure value type: `(RotationState, [Submission]) -> [QueuedTrack]`. Cover it with example tests and property tests (e.g. "for any interleaving of submissions, no invariant above is violated"). These tests must pass before any queue-affecting change is merged.

---

## Persistence (ephemeral-first)

- Sessions are **in-memory** and destroyed on end. Do **not** persist queue contents, submissions, or per-participant listening history beyond the live session.
- The CloudKit-SwiftData constraints from the SwiftAgents baseline generally do **not** apply here, because session content is never persisted. If SwiftData is used at all, restrict it to **local, non-synced** app preferences (e.g. display name, last fairness settings) — never session or listening data.
- Treat what friends listen to as sensitive: minimize collection, keep it on-device, discard on session end.

---

## Project structure

- Consistent structure with folders by feature (e.g. `Session/`, `Queue/`, `Fairness/`, `MusicKit/`, `Transport/`, `Search/`).
- Strict naming conventions for types, properties, methods, and models.
- One primary type per file; do not stack multiple structs/classes/enums in one file.
- Unit-test core logic — the fairness scheduler above all. Only write UI tests where unit tests are not possible.
- Add code comments and documentation comments as needed, especially on fairness invariants.
- Never commit secrets. If `Localizable.xcstrings` is used, add user-facing strings as symbol keys with `extractionState` "manual", access via generated symbols (`Text(.songQueued)`), and offer to translate new keys into all supported languages.

---

## Security & privacy

- The MusicKit developer token / `AuthKey_*.p8` private key must never be committed. Keep it out of the repo via `.gitignore` and inject at build/run time.
- No analytics on listening content without explicit consent; ephemeral sessions imply an expectation of no tracking.
- Validate every inbound peer/server message before mutating state — a participant must not be able to bypass fairness guards by crafting messages.

---

## Pull request review protocol

Review pull requests as a skeptical senior iOS engineer responsible for preventing user-visible regressions, fairness violations, concurrency bugs, privacy leaks, and unsafe MusicKit behavior. The goal is not to summarize the diff or comment on style. The goal is to determine whether the change is safe to merge.

### Establish scope before reviewing

Before evaluating the implementation:

1. Read the PR title and description and identify the intended behavior.
2. Inspect the complete diff against the PR's actual merge base.
3. Read the full contents of every materially changed file, not only the edited lines.
4. Inspect relevant callers, consumers, models, tests, and configuration files that may be affected.
5. Separate pre-existing problems from regressions introduced by the PR.
6. Note any claimed behavior that cannot be verified from the code or available environment.

Do not assume a changed function is correct in isolation. Trace important data and state transitions from input through side effects and observable output.

### Review priorities

Prioritize findings in this order:

1. Crashes, data corruption, security, or privacy problems.
2. Fairness invariant violations or ways a peer can bypass queue guards.
3. Incorrect session, queue, playback, or participant state.
4. Swift concurrency violations, races, reentrancy, or unstructured task lifetime bugs.
5. Error paths that leave the UI or host/peer state inconsistent.
6. Regressions in behavior, accessibility, localization, or platform compatibility.
7. Missing tests for meaningful behavior changes.
8. Maintainability issues only when they create a concrete correctness risk.

Do not report subjective style preferences unless they violate this guide or create a likely defect.

### Domain-specific review checklist

For changes involving the queue or fairness scheduler, verify:

- No participant can play twice consecutively while another participant has a pending track.
- FIFO ordering within each participant's submissions is preserved.
- Adding, removing, joining, and leaving participants does not corrupt rotation order.
- Empty participant queues are skipped without incorrectly losing their future place.
- Duplicate, cooldown, and maximum-pending policies are enforced by the authoritative host.
- Rejected submissions return a typed, user-explainable reason.
- Malformed or replayed peer messages cannot bypass validation.
- The currently playing track is not accidentally reordered or restarted.
- Queue-affecting changes include regression tests and boundary cases.

For concurrency or real-time session changes, verify:

- Authoritative session state is mutated only through its owning actor.
- No shared mutable state crosses isolation boundaries unsafely.
- Tasks have an intentional owner and cancellation path.
- Reconnection, duplicate delivery, out-of-order delivery, participant departure, and host shutdown are handled.
- Errors and cancellation cannot leave loading flags, queue state, or peer state stuck.
- `Sendable` conformance is valid rather than added only to silence the compiler.
- Continuations and event streams cannot be resumed or terminated more than once.

For MusicKit and playback changes, verify:

- Authorization denial, restricted access, expired authorization, and missing subscription are handled.
- Only the host controls `ApplicationMusicPlayer`.
- Catalog requests are cancellable and stale search results cannot replace newer results.
- MusicKit failures do not silently diverge the logical queue from the playback queue.
- Queue reconciliation preserves the current track whenever possible.
- Playback transitions, rather than timers alone, advance fairness rotation.

For SwiftUI changes, verify:

- All interactive controls are accessible through VoiceOver and have meaningful labels.
- Dynamic Type, long text, localization expansion, empty states, loading states, and error states remain usable.
- State ownership is correct and views do not create duplicate long-lived models.
- Repeated `.task` or appearance events cannot start duplicate observations or requests.
- Navigation and sheets remain consistent when asynchronous state changes.
- User-facing strings use the project's localization system.
- Screens do not depend on one device size, orientation, color scheme, or increased-contrast setting.

For privacy and security changes, verify:

- Session and listening data remain ephemeral.
- Logs do not expose participant identifiers, listening history, tokens, or private peer payloads.
- Every inbound message is decoded defensively and validated before state mutation.
- No developer token, private key, entitlement secret, or environment-specific credential is committed.

### Required test analysis

For each behavior change, identify:

- The expected success path.
- Boundary values and empty-state behavior.
- Failure and cancellation behavior.
- State-transition and repeated-operation behavior.
- Any regression scenario suggested by the surrounding code.

Tests should assert externally meaningful behavior, not duplicate implementation details.

Queue or scheduler changes should include table-driven examples and, where practical, randomized or property-based coverage of fairness invariants. Include cases for one participant, many participants, uneven supply, participants joining or leaving, rejected submissions, duplicate tracks, and repeated rotations.

A missing test is a review finding when the untested behavior could plausibly regress. Do not request tests solely to increase coverage numbers.

### Verification before approval

Run the strongest relevant verification available:

- Build the affected app target and treat warnings as meaningful review signals.
- Run all affected unit tests.
- Run fairness scheduler tests for every queue-affecting change.
- Run relevant UI tests for critical user flows that cannot be covered below the UI layer.
- Run SwiftLint if configured; it must return no warnings or errors.
- Inspect Xcode build warnings and Issue Navigator findings.
- Render or launch materially changed SwiftUI screens when tooling permits.

Never claim a build, test, preview, or lint check passed unless it was actually run. If verification cannot be performed, state exactly what remains unverified and why.

Passing tests do not by themselves make the PR safe. Review whether the tests cover the failure modes introduced by the change.

### Finding format

Report only actionable findings introduced or exposed by the PR. Each finding must include:

- Severity.
- A concise defect-oriented title.
- The smallest useful file and line range.
- The concrete scenario that triggers the problem.
- The resulting user or system impact.
- Why existing validation or tests do not prevent it.
- A direction for fixing it when that is not obvious.

Use these severity levels:

- `P0` — Immediate stop: security breach, destructive data loss, or universally broken critical functionality.
- `P1` — Must fix before merge: crash, fairness violation, race, privacy leak, or broken primary flow.
- `P2` — Should fix before merge: meaningful regression or unhandled edge case affecting some users.
- `P3` — Low-risk improvement: limited correctness or maintainability concern with concrete future impact.

Do not inflate severity. Do not present praise, summaries, or speculative concerns as findings.

If no defects are found, say so explicitly and list any remaining verification gaps or residual risks. “No findings” does not mean the change is proven correct.

### Approval criteria

A PR is ready to merge only when:

- No unresolved `P0`, `P1`, or `P2` findings remain.
- The implementation matches the stated product behavior.
- Relevant tests cover success, boundary, and failure paths.
- The app builds and relevant tests pass.
- Queue changes preserve every fairness invariant.
- New concurrency work has clear isolation, ownership, and cancellation behavior.
- Privacy and ephemeral-session requirements remain intact.
- Automated review feedback has been evaluated and either addressed or explicitly rejected with a technical reason.

Do not approve merely because the diff is small, existing tests pass, or another reviewer approved it.

---

## Xcode MCP

If the Xcode MCP is configured, prefer its tools over generic alternatives:

- `DocumentationSearch` — verify MusicKit / SwiftUI API availability and usage before writing code.
- `BuildProject` — build after changes to confirm compilation.
- `GetBuildLog` — inspect build errors and warnings.
- `RenderPreview` — visually verify SwiftUI views via Previews.
- `XcodeListNavigatorIssues` — check Issue Navigator issues.
- `ExecuteSnippet` — test a snippet in a source file's context.
- `XcodeRead`, `XcodeWrite`, `XcodeUpdate` — prefer these over generic file tools for Xcode project files.
