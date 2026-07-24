# Build Plan — Ephemeral Shared-Queue Music Sessions

Revision: 5
Last updated: 2026-07-24

## Authority and usage

This is the canonical implementation sequence. Read
[`PRODUCT_DECISIONS.md`](PRODUCT_DECISIONS.md) and the repository
[`AGENTS.md`](../AGENTS.md) before starting a slice.

Implement one vertical slice at a time. A slice may begin when every capability
gate named by that slice has passed; an unrelated blocked capability does not
block it. Do not declare a slice complete until its own exit gate has been
demonstrated. If a feasibility check fails, update the product decision record
before changing architecture or scope.

Physical-device results and unresolved hardware gates are tracked in
[`VERIFICATION_LOG.md`](VERIFICATION_LOG.md). A hardware or account dependency
does not make an exit gate pass.

### Provisional work while a feasibility gate is blocked

When a capability check cannot run solely because required physical hardware or
an account state is unavailable, work that does not depend on that capability may
proceed only when all of the following are true:

- The blocked check and exact dependency are recorded in `VERIFICATION_LOG.md`.
- The work is independently useful and does not assume an unverified MusicKit,
  Network framework, permission, or lifecycle behavior.
- The work has a mockable or pure boundary and can be revised without preserving
  compatibility with an unverified spike.
- No integration slice that names the blocked capability as a prerequisite starts,
  and no dependent slice is declared complete until the capability passes or the
  product decision and this plan are deliberately revised.

The pure Slice 1 fairness engine and Slice 2A domain-backed queue UI are authorized
while hardware/account checks remain blocked because they have no MusicKit,
Network, clock, I/O, or physical-device dependency. Transport, guest catalog,
permission-flow, playback, and lifecycle work still require their named capability
gate.

### Provisional mock-driven UI track

While Slice 0 is blocked only by the additional-device and account conditions
recorded in `VERIFICATION_LOG.md`, a mock-driven UI track may proceed alongside
Slice 1. This track is exploratory work, not the start or completion of Slice 4.
It must satisfy all of these boundaries:

- Enter through previews or an explicit mock route from the feasibility harness.
- Depend only on deterministic presentation fixtures and in-memory UI state.
- Do not import MusicKit or Network, request permissions, control playback, start
  discovery, or assume unverified device behavior.
- Do not duplicate the fairness scheduler, transport protocol, host session model,
  or guest snapshot model in mock types.
- Treat queue order as supplied canonical presentation state. Mock UI must not
  introduce arbitrary reorder or cross-participant mutation affordances.
- Keep view inputs presentation-specific so later host and guest session models can
  map canonical state into the UI without preserving the mock store.
- Preserve the Slice 0 feasibility harness and its physical-device test paths.
- Do not use mock or simulator results to satisfy any Slice 0 or Slice 4 exit gate.

The provisional track is divided into independently reviewable slices:

1. **P0 — authorization and gallery shell:** record these boundaries and provide a
   deterministic mock-only entry point.
2. **P1 — visual foundation:** participant identity, artwork placeholders, buttons,
   status treatments, queue rows, localization, and accessibility variants.
3. **P2 — entry and identity shell:** Host/Join choice and mock profile setup.
4. **P3 — lobby and admission:** host lobby, discovery, approval, invite, room-full,
   and rejection fixtures.
5. **P4 — joined-session shell:** session identity, participants, now playing, fair
   upcoming queue, empty queue, and Add Music entry.
6. **P5 — search and submission feedback:** mock search states, acknowledgement,
   and typed rejection presentation.
7. **P6 — lifecycle state gallery:** reconnecting, gone, removed, playback failure,
   host loss, ending, accessibility, and localization-expansion fixtures.

Each provisional slice must build without new warnings and remain replaceable by
production state. No provisional slice opens a canonical implementation gate.
Current implementation status and fresh-context continuation guidance live in
[`UI_PROTOTYPE_HANDOFF.md`](UI_PROTOTYPE_HANDOFF.md).

Every provisional UI change must update that handoff when it changes slice status,
routes, fixtures, presentation inputs, intended production seams, verification
evidence, or the next continuation task. The handoff must maintain a concrete
mock-to-production connection map and retirement checklist so the gallery cannot
quietly become a parallel application architecture.

## Repository baseline

- Existing source roots are `Jamsession/`, `JamsessionTests/`, and
  `JamsessionUITests/`; do not create parallel `Sources/` or `Tests/` roots.
- The app target already uses Main Actor default isolation.
- The project records deployment target 26.0 and Swift language mode 6. It was
  verified with Xcode 26.6 and the Apple Swift 6.3.3 compiler during Slice 0.
- Info.plist is generated. Add usage descriptions and Bonjour declarations through
  target build settings, or deliberately migrate to a checked-in plist.
- SwiftLint is not currently configured. Add it only with user approval; if later
  configured, it becomes part of the definition of done.

## Target structure

```text
Jamsession/
  App/
  Models/
  Fairness/
  Session/
  Transport/
  Music/
  Features/
    FirstRun/
    CreateSession/
    Join/
    Queue/
    Participants/
    Search/
  Support/

JamsessionTests/
  Fairness/
  Session/
  Transport/
  Music/
```

Use one primary type per file. The Xcode project's synchronized groups should pick
up filesystem additions; verify target membership rather than editing the project
file reflexively.

## Ground rules

- iOS 26+, Swift strict concurrency, async/await, SwiftUI, Observation, and Swift
  Testing.
- Host session state is authoritative and Main Actor isolated.
- The fairness engine is a pure `Sendable` value type with no framework imports,
  clock, I/O, or global state.
- Guests send idempotent commands and mirror snapshots. They never send replacement
  session or queue state.
- MusicKit and transport are hidden behind mockable boundaries.
- No secret or `.p8` private key enters the project.
- Every user-facing failure is typed and localized.
- Queue changes require fairness regression tests.

## Slice 0 — Physical-device feasibility and foundations

### Goal

Invalidate the riskiest assumptions cheaply before production architecture grows.

Slice 0 is tracked as independent capability gates:

- **0M — host MusicKit:** host authorization, subscription, catalog access,
  playback, and lock-screen behavior.
- **0G — guest catalog:** MusicKit authorization and catalog search for a guest
  without an active Apple Music subscription.
- **0N — nearby networking:** Bonjour discovery, framed messaging, denial
  distinction, foreground/background behavior, reconnection, and clean
  termination on two physical devices.

A later slice names the gates it requires. Passing 0M does not imply 0G or 0N;
blocked 0G or 0N does not block host-only work that depends solely on 0M.

### Tasks

- Verify the installed Xcode/Swift compiler and set the true minimum deployment
  target to iOS 26.0 if supported.
- Enable the MusicKit App Service for the app's explicit App ID in Certificates,
  Identifiers & Profiles. MusicKit has no code-signing entitlement. Use automatic
  developer-token management; do not implement custom `.p8` injection.
- Configure generated Info.plist values for Apple Music, local-network access, and
  declared Bonjour services.
- Add background audio capability only after verifying it is required for the host
  playback experience.
- Build a disposable-but-clean MusicKit spike:
  - Subscriber host authorizes, searches, queues, plays, pauses, and skips.
  - Non-subscriber guest authorizes and searches.
  - Denied guest can still reach a mock joined-queue screen.
- Build a minimal Network framework spike using `NetworkListener`,
  `NetworkBrowser`, and `NetworkConnection`:
  - Two physical devices discover each other.
  - They exchange one framed `Codable` message in each direction.
  - Observe foreground/background disconnect and reconnect behavior.
- Define `SessionTransport` only after the spike exposes the concrete needs.

### Capability exit gates

- **0M:** physical subscriber playback, pause, skip, denial recovery, and intended
  device-lock behavior work.
- **0G:** physical non-subscriber catalog search works or the guest product promise
  is deliberately revised.
- **0N:** two devices discover, connect, exchange framed messages, distinguish
  denial from no nearby room, observe foreground/background behavior, reconnect as
  designed, and terminate cleanly.
- Findings and platform limitations are recorded in `PRODUCT_DECISIONS.md` and
  `VERIFICATION_LOG.md`.

## Slice 1 — Pure fairness engine

### Goal

Implement and prove the complete queue policy without UI, MusicKit, or networking.

### Core types

- `ParticipantID`, `SubmissionID`, and `TrackID` domain identifiers.
- `ParticipantStatus`: connected, reconnecting, gone, removed.
- `QueuedTrack` containing domain track metadata and submitter.
- `FairnessConfig` with pending cap 3 and duplicate policy.
- `RotationState` with append-only locked order, cursor, per-participant FIFO,
  status/tombstones, current-round skips, and currently playing entry.
- `FairnessEvent` for submit, remove-own, turn-skip, host turn-skip, host removal,
  mark/unmark gone, block, late join, status transition, playback advance, and track
  failure.
- `FairnessRejection` containing only pure domain failures.
- `FairnessScheduler` for validation, event application, `nextUp`, and derived
  upcoming queue.

Do not add play history or a permanent played-track set to `RotationState`.
Duplicate validation checks current pending state (and the current track if product
behavior requires it), not historical plays.

### Required examples

- Equal supply: A1, B1, C1, A2, B2, C2.
- Uneven supply: A1, B1, A2, A3, verifying B has no pending track at A2 to A3.
- Host obeys identical fairness and cap rules.
- Empty, reconnecting, gone, removed, and skipped participants never stall playback.
- Turn skip retains the track, cap occupancy, and duplicate block until next round.
- Playing-track skip consumes the track and differs from turn skip.
- Track failure removes the track without recording a play.
- Removing `nextUp` selects the next eligible entry.
- Two participants skip in one round; skip state clears at the boundary.
- Only one participant has tracks and skips a turn: no artificial silence.
- Gone/removed participants remain tombstones; unmark-gone restores position but not
  removed songs; removed is terminal.
- Mark gone while next-up and while currently playing.
- Late join during a partially completed round and reconnect after the original
  position passed.
- Fourth pending submission is rejected; currently playing does not count.
- Pending duplicate is rejected; retained skipped track still blocks; failed or
  consumed track no longer blocks.
- Replayed events are idempotent where event identity applies.
- A guest cannot remove or skip another participant through the authorized command
  boundary (tested in Slice 3 if kept outside the pure scheduler).

### Property tests

- FIFO is preserved for every participant.
- No consecutive participant while another eligible participant has pending supply
  at that transition.
- Equal-supply play counts differ by at most one.
- Existing locked positions never move; late joins only append.
- Identical initial state and events produce identical output.

### Exit gate

- All example, boundary, repeated-event, and property tests pass.
- The domain module has no MusicKit, SwiftUI, Network, date, timer, or I/O import.
- Skip and tombstone semantics match `PRODUCT_DECISIONS.md` exactly.

## Slice 2A — Domain-backed functional queue UI

### Prerequisite

Slice 1 only. This slice does not depend on MusicKit, Network, permissions, a
clock, or physical devices.

### Goal

Connect real fairness behavior to reusable SwiftUI presentation without promoting
the provisional mock coordinator or scenario state into production architecture.

### Tasks

- Add one Main Actor authoritative in-memory host session owner.
- Define typed queue commands with explicit request identity.
- Map canonical `RotationState` and participant metadata into immutable,
  production-neutral queue presentation values.
- Reuse visual queue components only after their inputs no longer depend on mock
  fixtures.
- Drive submit, remove-own, host removal, turn skip, pending-limit, and duplicate
  behavior through `FairnessScheduler`.
- Surface typed accepted/rejected outcomes with localized, accessible feedback.
- Keep any deterministic catalog or participant harness Debug-only and clearly
  separate from the production state owner.

### Exit gate

- UI actions mutate only canonical session state through typed commands.
- Derived queue order exactly matches `FairnessScheduler.upcomingQueue`.
- Duplicate, pending-cap, unauthorized removal, replay, and turn-skip outcomes have
  focused integration tests.
- The app builds with no new warnings; the complete fairness suite passes.
- No MusicKit, Network, permission, timer, or persistence dependency is introduced.

## Slice 2B — Single-device host experience

### Prerequisite

Capability gate 0M and Slice 2A.

### Goal

Deliver the first usable production path: a subscriber hosts alone, searches,
queues fairly, and plays music on one device.

### Tasks

- Connect first-run role/profile presentation to a production app coordinator.
- Add the just-in-time host Music explanation, authorization, subscription, and
  recovery flow.
- Allow the host to create a lobby and start alone.
- Add cancellable, debounced catalog search behind a protocol.
- Add host-storefront resolution and map MusicKit `Song` into domain metadata.
- Add a Main Actor host player around `ApplicationMusicPlayer.shared`.
- Build `QueueReconciler` as a pure diff planner plus thin MusicKit executor.
- Own one playback-transition observation task with cancellation and
  deduplication.
- Connect real search, submission, queue, now-playing, pause, skip, failure, empty
  queue, and end-session UI.

### Exit gate

- A subscriber completes profile → host authorization → lobby → start alone →
  search → queue → playback → end on a physical device.
- Adding/removing future tracks does not disturb the current track.
- Completion and skip advance once under repeated callbacks.
- Reconciliation failure pauses and surfaces actionable UI.
- Pure diff-planning, transition-deduplication, mapping, and UI-flow tests pass.

## Slice 3 — Nearby lobby and admission

### Prerequisite

Capability gate 0N and Slice 2A. Guest catalog gate 0G is not required.

### Goal

Deliver discovery, admission, lobby convergence, and a canonical empty joined
queue on real nearby devices.

### Tasks

- Implement production `SessionTransport` with the proven iOS 26 Network APIs.
- Use host-and-spoke connections and structured tasks with explicit ownership and
  cancellation.
- Define framing, maximum message size, protocol version, session ID, participant
  ID, request ID, host revision, and typed payload.
- Implement on-device identity, reconnect credentials, Bonjour discovery, host
  approval, QR admission, and short-code filtering.
- Enforce capacity, authorization, idempotency, monotonic revisions, rate limits,
  defensive decoding, and credential privacy.
- Connect local-network explanation/recovery, discovery, no-room, approval,
  rejection, room-full, update-required, invite, lobby, and empty joined-queue UI
  to canonical host/guest state.

### Exit gate

- Host and guest discover, approve, form a lobby, start, and display the same
  canonical empty queue on two physical devices.
- Duplicate/stale delivery and unauthorized commands cannot diverge state.
- Framing, snapshots, admission, capacity, cancellation, and presentation mapping
  tests pass.
- Physical denial/no-room distinction and clean termination pass with no private
  values in logs or accessibility output.

## Slice 4 — Guest submission and full fair loop

### Prerequisite

Capability gate 0G, Slice 2B, and Slice 3. If 0G fails, revise the guest product
decision before changing this slice.

### Goal

Deliver the complete multi-device fair queue and playback loop.

### Tasks

- Connect guest Music authorization and cancellable catalog search.
- Send idempotent pending submission commands to the host.
- Resolve each item against the host storefront, then apply authorization and
  fairness validation.
- Separate fairness, track-validation, and session-command rejections and map each
  into localized feedback.
- Connect acknowledgement, canonical snapshots, pending cap, duplicate feedback,
  remove-own, turn skip, host moderation, current-track skip, gone/return, late
  join, automatic empty-queue resume, track failure, and in-memory play history.

### Exit gate

- Host plus two guests complete the full fair loop on physical devices.
- Every skip/failure type has correct queue, duplicate, cap, rotation, and history
  behavior.
- Integration tests drive the scheduler through fake transport and player
  services, including replay, stale response, cancellation, and failure paths.

## Slice 5 — Lifecycle and release hardening

### Goal

Make the core loop survive realistic party conditions and meet the MVP quality bar.

### Tasks

- Five-minute empty/stopped inactivity timer with cancelable warning.
- Thirty-second host-loss grace and 45-second guest reconnect grace.
- Foreground/background and device-lock states.
- Calls, Siri, Control Center, route changes, AirPods, and AirPlay behavior.
- Confirmed end, explicit guest notification, player clearing, command cancellation,
  and complete in-memory teardown.
- Capture an immutable history snapshot at the end-flow boundary for future playlist
  export, without persisting it after the flow completes.
- Finish required empty, loading, permission, connectivity, playback, and moderation
  states.
- VoiceOver, Dynamic Type, contrast, Reduce Motion, localization expansion, and
  privacy-log audit.

### Exit gate

- All automated tests pass with no concurrency warnings.
- Every required Slice 4C and release-gate scenario in `VERIFICATION_LOG.md`
  passes on a current build.
- Ten successful three-person sessions occur across at least three device/network
  setups, recorded manually.
- No unresolved P0, P1, or P2 review findings remain.

This gate is the closed-TestFlight MVP target.

## Slice 6 — Save the night (post-MVP)

### Goal

Let the host convert an immutable end-of-session history snapshot into an Apple
Music playlist before the snapshot is discarded.

### Tasks

- Create a host library playlist using MusicKit APIs.
- Include every track whose playback started, including host-skipped playing tracks;
  exclude failed-before-play tracks and preserve duplicates.
- Default to `Aux Session – {formatted date}` and allow editing.
- Surface permission denial and partial failure precisely.
- Destroy the snapshot when export is completed, declined, or abandoned.

## Deferred work

Host migration, remote sessions, backend accounts, profiles, chat, reactions,
StoreKit, cloud/persistent history, iPad-specific design, Android, advanced playlist
editing, clean-only mode, cooldowns, full localization, and analytics infrastructure.

## Definition of done for every slice

- Implementation matches `PRODUCT_DECISIONS.md` with no silent reinterpretation.
- Affected app target builds with no new warnings or concurrency diagnostics.
- Relevant Swift Testing suites pass; every queue change keeps fairness tests green.
- Physical-device verification is performed where simulators cannot prove behavior.
- Tasks and async streams have an owner and cancellation path.
- No secrets or sensitive session data are committed or logged.
- User-facing strings use localization keys.
- Introduced UI is accessible and handles empty, loading, error, cancellation, and
  repeated-operation states.
- SwiftLint passes only if it has been explicitly approved and configured.
- Verification actually run is recorded in `VERIFICATION_LOG.md`; unverified or
  stale behavior is named and cannot satisfy an exit gate.
