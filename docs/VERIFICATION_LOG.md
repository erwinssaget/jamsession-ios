# Verification Ledger — Physical-Device and Multi-Device Testing

Last updated: 2026-07-18

## Purpose and authority

This ledger records checks that simulators and automated tests cannot fully prove,
including MusicKit playback and account states, Bonjour and peer-to-peer behavior,
backgrounding, interruptions, and multi-device convergence.

`PRODUCT_DECISIONS.md` defines product behavior and `BUILD_PLAN.md` defines scope,
sequence, and exit gates. This ledger records execution and evidence; it does not
silently change either canonical document. A failed feasibility check requires a
product-decision update before architecture or scope changes.

## Current gate summary

| Gate | State | Required checks still open | Work allowed while blocked |
|------|-------|----------------------------|----------------------------|
| Slice 0 | **CLOSED — hardware/account verification incomplete** | V0-2, V0-4, V0-5, V0-6B, and V0-7B need additional hardware or account conditions | Remaining Slice 0 work, the pure Slice 1 fairness engine, and the mock-only provisional UI track defined in `BUILD_PLAN.md`. No dependent transport, playback, permission, or lifecycle integration may treat Slice 0 assumptions as proven. |
| Closed TestFlight | **CLOSED — implementation and release matrix incomplete** | VM-1 through VM-13 | Work authorized by the current completed gate or the explicit provisional-work rule only. |

The summary is informational. A gate opens only when every check required by its
canonical exit criteria has a current `PASS`, or when the canonical product
decision and build plan are deliberately revised.

## Status legend

- `TODO` — runnable with resources currently expected to be available, but not run.
- `BLOCKED` — cannot run because named hardware, account, accessory, implementation,
  or external condition is unavailable.
- `PASS` — expected behavior was observed and evidence metadata is complete.
- `FAIL` — expected behavior was not observed; notes link to a follow-up issue or
  product-decision revision.
- `RETEST` — previously passed, but a relevant code, entitlement, OS, account, or
  environment change has made the evidence stale.
- `N/A` — removed from the gate by an explicit canonical decision; notes must link
  to that decision.

Avoid `PARTIAL`. Split independently verifiable behavior into suffixed checks such
as `V0-7A` and `V0-7B`, so every row has one unambiguous result.

## Evidence required for PASS

Record the following in the result/evidence field or in a linked test note:

- Date, tester, and app commit SHA or TestFlight build.
- Device model and exact iOS version/build for every device.
- Relevant account condition, including Apple Music subscription and storefront,
  without recording Apple IDs or other personal identifiers.
- Network setup and relevant accessories.
- Expected result, observed result, and repeat count when meaningful.
- A link to a privacy-safe screenshot, screen recording, console excerpt, or test
  note when available. Do not record participant names, track IDs, search terms,
  listening history, credentials, secrets, tokens, or full peer payloads.

A bare status change is not sufficient evidence for an exit gate.

## Retest and failure rules

- Set affected rows to `RETEST` after changes to MusicKit integration, Network
  transport/framing, entitlements, permission handling, session lifecycle,
  background modes, or other behavior the check exercises.
- Also retest when adopting a new minimum iOS release or when a new OS version,
  account condition, device family, or network environment could materially alter
  the result.
- A `FAIL` records the concise observation here and links to the issue or decision
  entry where investigation and remediation are tracked.
- Simulator, mock, and unit-test results may support a row but never replace its
  stated physical-device requirement.
- Anything other than a current `PASS` remains an open risk and cannot satisfy the
  associated exit gate.

## Slice 0 — Feasibility gates

Repository foundation verified on 2026-07-18: Xcode 26.6 (build 17F113), Apple
Swift 6.3.3, iOS deployment target 26.0. A generic iOS device build with signing
disabled completed successfully after the local-network denial recovery change.
This build verifies compilation only and does not satisfy a physical-device row.

| ID | Verification | Needs | Blocks | Status | Date | Build / result / evidence |
|----|--------------|-------|--------|--------|------|---------------------------|
| V0-1 | Subscriber host authorizes, searches, queues, plays, pauses, and skips with `ApplicationMusicPlayer` | 1 physical iPhone; subscribed account | Slice 0 | PASS | 2026-07-18 | Tester: Erwin Saget. App commit `428e6b9` plus the current uncommitted Slice 0 denial-recovery changes. iPhone 14 Pro, iOS 26.5.2 (23F84), subscribed account, Wi-Fi, built-in speaker. One run: authorization and catalog search succeeded with 10 results; queue-and-play produced audible catalog playback; Pause stopped playback; queue-and-play followed by Skip reported “Skip completed.” Track ID, search term, and listening content intentionally omitted. |
| V0-2 | Non-subscriber authorizes MusicKit and searches the catalog | 1 physical iPhone; non-subscriber account | Slice 0 and guest product promise | BLOCKED | | Need a non-subscriber account/device condition. If it fails, revise `PRODUCT_DECISIONS.md` before changing the guest model. |
| V0-3 | Guest denied Music access can still reach the mock joined-queue screen | 1 physical iPhone; Music access denied | Slice 0 | PASS | 2026-07-18 | Tester: Erwin Saget. App commit `428e6b9` plus the current uncommitted Slice 0 denial-recovery changes. iPhone 14 Pro, iOS 26.5.2 (23F84). One run with Music access denied: the app displayed “Music access was denied. The mock queue remains available,” and the empty Joined Session screen remained reachable. |
| V0-4 | Two devices discover through Bonjour, connect host-and-spoke, exchange one framed `Codable` message in each direction, and terminate cleanly | 2 physical iPhones | Slice 0 | BLOCKED | | Need second device. Verify actual iOS 26 concurrency-native Network API availability before treating the spike as complete. |
| V0-5 | Peer link behavior across guest and host foreground/background transitions is observed; reconnection terminates cleanly | 2 physical iPhones | Slice 0 | BLOCKED | | Need second device. Record each transition tested and whether the connection persisted, disconnected, or reconnected. |
| V0-6A | Local-network denial produces the intended denial UI and recovery guidance | 1 physical iPhone; local-network access denied | Slice 0 | PASS | 2026-07-18 | Tester: Erwin Saget. App commit `428e6b9` plus the current uncommitted Slice 0 denial-recovery changes. iPhone 14 Pro, iOS 26.5.2 (23F84), Wi-Fi. One run: with Local Network disabled, discovery reported that local-network access was denied and presented Open Local Network Settings. After enabling access in Settings and retrying, the app reported that local-network access was available with no nearby host selected. UI/state handling only; this does not prove discovery behavior. |
| V0-6B | Local-network denial is behaviorally distinguishable from an allowed device with no nearby room | 2 physical iPhones; one discoverable host | Slice 0 | BLOCKED | | Need second device for the contrast case. |
| V0-7A | Host audio continues as designed under device lock; playback controls remain deterministic | 1 physical iPhone; subscribed account | Slice 0/open verification | PASS | 2026-07-18 | Tester: Erwin Saget. App commit `428e6b9` plus the current uncommitted Slice 0 denial-recovery changes. iPhone 14 Pro, iOS 26.5.2 (23F84), subscribed account, Wi-Fi, built-in speaker. One run: playback continued uninterrupted for at least 30 seconds while locked; Lock Screen pause and resume worked; Lock Screen skip exhausted the spike's single-entry queue and stopped playback; after unlock, Jamsession remained responsive and queue-and-play restarted playback. The project had no background-audio capability, so this check does not justify adding it. |
| V0-7B | Session-management and peer behavior under host/guest lock and backgrounding matches the foreground-oriented design | 2 physical iPhones | Slice 0/open verification and Slice 4C | BLOCKED | | Need second device. |

## Closed-TestFlight release matrix

These rows capture end-state physical testing early so hardware, accounts, and
accessories can be sourced before Slice 4C. They do not imply that the feature is
implemented yet; name implementation as the blocker until it is runnable.

| ID | Verification | Needs | Status | Date | Build / result / evidence |
|----|--------------|-------|--------|------|---------------------------|
| VM-1 | Subscriber host and non-subscriber guest complete guest catalog search end to end | 2 devices; non-subscriber account | BLOCKED | | Depends on implementation and V0-2. |
| VM-2 | Host and two guests complete the full fair playback loop | 3 devices | BLOCKED | | Depends on implementation and third device. |
| VM-3 | Eight-device capacity succeeds and a ninth device receives the typed room-full rejection | Up to 9 devices | BLOCKED | | Logistics-heavy; use borrowed devices or a planned test event. |
| VM-4A | MusicKit denial and recovery work on the affected device | 1 physical iPhone | BLOCKED | | Depends on implementation. |
| VM-4B | MusicKit denial on one participant does not corrupt a multi-device session | 2 devices | BLOCKED | | Depends on implementation and second device. |
| VM-5A | Local-network denial and recovery UI work on the affected device | 1 physical iPhone | BLOCKED | | Depends on implementation. |
| VM-5B | Local-network denial and recovery converge correctly with a discoverable host | 2 devices | BLOCKED | | Depends on implementation and second device. |
| VM-6 | Different storefronts and unplayable content produce the correct typed rejection | 2 devices; accounts in different storefronts | BLOCKED | | Depends on implementation and account sourcing. |
| VM-7 | Guest disconnect/reconnect reclaims the reserved slot and original rotation position | 2–3 devices | BLOCKED | | Depends on implementation and additional device. |
| VM-8 | Host-loss grace expires and guests destroy mirrored session state | 2–3 devices | BLOCKED | | Depends on implementation and additional device. |
| VM-9A | Calls, Siri, and Control Center interactions leave playback/session state deterministic | 1–2 physical iPhones | BLOCKED | | Depends on implementation; record each interruption separately in evidence. |
| VM-9B | AirPods, AirPlay, and route changes leave playback/session state deterministic | 1–2 physical iPhones; accessories/routes | BLOCKED | | Depends on implementation and accessories. |
| VM-10 | Empty queue remains active and playback resumes after the next accepted song | 2 devices | BLOCKED | | Depends on implementation. |
| VM-11 | Pending-cap and duplicate rejections surface correct localized UI without state divergence | 2 devices | BLOCKED | | Depends on implementation. |
| VM-12 | Turn skip, playing-track skip, gone/return, removal/block, late join, and confirmed end behave correctly | 3 devices | BLOCKED | | Depends on implementation; use a linked scenario sheet so each behavior has an explicit result. |
| VM-13 | Ten successful three-person sessions across at least three device/network setups | 3 devices per session; varied networks | BLOCKED | | Closed-TestFlight go/no-go. Record one linked session entry per run. |

## Device, account, and environment inventory

Track availability, not personal identifiers:

- Second iPhone on the minimum supported iOS: needed for most peer checks.
- Non-subscriber Apple Music account condition: needed for V0-2 and VM-1.
- Third physical device: needed for VM-2, VM-7, VM-8, VM-12, and VM-13.
- Borrowed-device or test-event plan: needed for the eight-device/ninth-device
  boundary in VM-3.
- Account in a different storefront, if obtainable: needed for VM-6.
- Relevant routes/accessories such as AirPods and AirPlay: needed for VM-9B.

Do not record device UDIDs, Apple IDs, join secrets, reconnect credentials, or
other personal or reusable identifiers in this file.

## Provisional mock-UI verification

Mock UI work may demonstrate layout, accessibility, localization readiness, and
deterministic presentation states. It cannot provide evidence for MusicKit,
Network, permission, playback, reconnection, multi-device convergence, or any
physical-device gate above.

For each provisional UI slice, record the build used, previews or simulator
variants inspected, accessibility checks performed, and any behavior deliberately
left as a fixture. When production integration begins, remove the mock-only route
or keep it explicitly debug-scoped; never allow fixture state to become session
authority.

| Date | Slice | Verification | Result |
|------|-------|--------------|--------|
| 2026-07-22 | P0, P1, P4 shell | Xcode project build; populated joined-session preview at default Dynamic Type in light appearance and AX5 in dark appearance; Issue Navigator warnings; fixture-boundary inspection | PASS for compilation and preview inspection. Build completed with no errors, Issue Navigator reported no warnings, and the AX5 header was revised to stack its Add Music action. Populated, empty, and reconnecting states remain deterministic fixtures; Add Music intentionally opens a P5 placeholder. The active test plan discovered 42 existing tests but ran none because the active Xcode destination did not provide a runnable test destination, so no test pass is claimed. |
| 2026-07-22 | P2 | Xcode project build; first-run entry preview at default Dynamic Type in light appearance and AX5 in dark appearance; host profile preview at AX5 in dark appearance; Issue Navigator warnings; string-catalog JSON, whitespace, and fixture-boundary checks | PASS for compilation and preview inspection. Build completed with no errors and Issue Navigator reported no warnings. Role cards switch to a vertical layout when horizontal content does not fit, and the profile form remains scrollable at AX5. Host/Join, identity, validation, cancellation, and permission-explainer behavior is fixture-only; no permission was requested. No MusicKit, Network, fairness scheduler, or rotation-state reference was found in the provisional UI boundary. No tests were run, so no test pass is claimed. |
| 2026-07-22 | P3 | Xcode project build; host-lobby preview at default Dynamic Type in light appearance; approval-request preview at AX5 in dark appearance; Issue Navigator warnings; string-catalog JSON, whitespace, and fixture-boundary checks | PASS for compilation and preview inspection. Build completed with no errors and Issue Navigator reported no warnings. The AX5 approval action stack changed to a vertical layout and its explanatory copy expands without truncation inside a scrollable surface. Host order, approval/rejection, discovery, no-nearby, awaiting, room-full, and invite states are deterministic fixtures. Start Session is disabled, and the decorative QR contains no join credential. No MusicKit, Network, session transport, fairness scheduler, or rotation-state reference was found in the provisional UI boundary. No tests were run, so no test pass is claimed. |
| 2026-07-22 | Connected P2–P4 walkthrough | Xcode project build; connected full-flow entry preview at default Dynamic Type in light appearance and AX5 in dark appearance; Issue Navigator warnings; string-catalog JSON, whitespace, and fixture-boundary checks | PASS for compilation and entry-screen preview inspection. Build completed with no errors and Issue Navigator reported no warnings. Host and Join presentation paths are connected by `MockPrototypeStep`; the guest path exposes a clearly labeled fixture control for simulated host approval, and Restart returns to role selection. Direct first-run, lobby, and queue galleries remain available. No MusicKit, Network, session transport, fairness scheduler, or rotation-state reference was found in the provisional UI boundary. The complete interactive path was not automated or physically exercised, and no tests were run, so no interaction or test pass is claimed. |
| 2026-07-22 | P5 | Xcode project build; search-results preview at default Dynamic Type in light appearance; pending-limit feedback preview at AX5 in dark appearance; Issue Navigator warnings; string-catalog JSON, whitespace, and fixture-boundary checks | PASS for compilation and preview inspection. Build completed with no errors and Issue Navigator reported no warnings. Add Music now opens the fixture search from both the joined queue and connected walkthrough. Search covers idle, loading, results, empty, denied, offline, and failure presentation; feedback covers pending, accepted, duplicate, pending-limit, inactive, unplayable, and timeout outcomes. The AX5 feedback card uses a vertical layout with full-width explanatory copy. No MusicKit, Network, session transport, fairness scheduler, or rotation-state reference was found in the provisional UI boundary. Search, validation, acknowledgement, and rejection remain fixtures; no tests were run, so no behavioral or test pass is claimed. |
| 2026-07-22 | P6 | Xcode project build; participant-gone gallery preview at default Dynamic Type in light appearance; host-loss preview at AX5 in dark appearance; deterministic Reduce Motion preview; localization-expansion preview; Issue Navigator warnings; string-catalog JSON, whitespace, timer, and fixture-boundary checks | PASS for compilation and preview inspection. Build completed with no errors. Participant gone/removed, track failure, host loss, ending/ended, Reduce Motion, and expansion states are static fixtures. Host-loss and ending indicators do not run clocks, transport, playback, or teardown; the connected walkthrough exposes the lifecycle gallery from its joined queue. The Reduce Motion gallery reads the system environment and its dedicated preview uses a fixture override because the SDK environment value is read-only. No MusicKit, Network, session transport, fairness scheduler, rotation state, timer, or sleep reference was found in the provisional UI boundary. No tests were run, so no lifecycle behavior or test pass is claimed. |
| 2026-07-22 | UI production-readiness review | Source audit of provisional presentation inputs, local state, fixture ownership, intent closures, mock-route isolation, and canonical gate status; documentation consistency and whitespace checks | COMPLETE as a review, not a production gate. Reusable leaf presentation, mock-only ownership, and required replacement seams are recorded in `UI_PRODUCTION_READINESS.md`. The first allowed hardening task is a pure validated profile draft because the current completion callback drops emoji and color. Slice 0 remains closed; no MusicKit, Network, playback, persistence, session lifecycle, or other production integration was performed. No build or test result is claimed by this review row. |
| 2026-07-22 | UI hardening R1 | Xcode project build; five focused `ProfileDraftValidatorTests` on the iPhone 14 Pro iOS 26.5 simulator; profile-form preview at default Dynamic Type; Issue Navigator warnings; string-catalog JSON and whitespace checks | PASS. The project built successfully, all five focused tests passed, the profile preview rendered, and Issue Navigator reported no warnings. `ProfileDraft`, `ProfileColorID`, `ProfileValidationError`, and `ProfileDraftValidator` are explicitly nonisolated under the app target’s Main Actor default. Profile completion now preserves normalized name, emoji, and color without adding persistence or production session identity. |
| 2026-07-22 | UI hardening R3–R5 | Xcode project build; focused `MockFixtureIdentityTests`, `MockScenarioCompletenessTests`, and `MockSubmissionFeedbackPresentationTests` on the iPhone 14 Pro iOS 26.5 simulator; Issue Navigator warnings; string-catalog JSON, whitespace, and launch-random fixture-ID checks | PASS for build, tests, and static checks. The project built successfully, all five focused tests passed, Issue Navigator reported no warnings, the string catalog parsed, `git diff --check` passed, and no `UUID()` calls remain under `Jamsession/Features`. Mock participant and track identity is stable across flows, the eventual UI intent inventory is recorded in `UI_INTENT_INVENTORY.md`, and all feedback/scenario cases are covered by pure presentation tests. Xcode’s post-change feedback preview request timed out, so no new visual-preview result is claimed. No MusicKit, Network, playback, persistence, or session lifecycle integration was performed. |
| 2026-07-23 | UI hardening R2 and R6 | Complete `JamsessionTests` target before and after changes on the iPhone 14 Pro iOS 26.5 simulator; active Debug build; generic Release iOS Simulator build; populated joined-queue leaf preview at default Dynamic Type in light appearance; Issue Navigator warnings; queue presentation seam and conditional-navigation source inspection | PASS. The complete unit target passed before the changes and all 50 unit tests passed afterward, including the new populated/empty/reconnecting queue-presentation mapping test. Debug and Release simulator builds succeeded, the extracted queue leaf rendered with its hierarchy and Add Music affordance intact, and Issue Navigator reported no warnings. Xcode discovers 53 enabled tests total; the three template UI tests were not run. `MockJoinedQueueView` now owns fixture/sheet state while `MockJoinedQueuePresentationView` receives immutable presentation and emits Add Music/Lifecycle intents. All feasibility-harness mock buttons and `FeasibilityDestination` are guarded by `DEBUG`, so release navigation cannot construct or reach mock flows. The MusicKit and Network feasibility controls remain intact. No physical-device result or canonical gate pass is claimed. |
| 2026-07-23 | Connected mock-flow UI smoke | Focused Host and Join `MockConnectedFlowUITests` on the iPhone 14 Pro iOS 26.5 simulator; complete 50-test `JamsessionTests` target; active Debug build; generic Release iOS Simulator build; Issue Navigator warnings; stable mock-control accessibility identifiers | PASS. Both debug-only UI tests passed. Each path opened the connected mock flow, submitted a valid profile, finished the inert permission explanation, reached the joined queue, opened and dismissed Add Music, and restarted to role selection; Join also selected the nearby fixture and simulated host approval. All 50 unit tests passed, Debug/Release simulator builds succeeded, and Issue Navigator reported no warnings. Xcode discovers 55 tests total; the three template UI tests were not part of this focused run. The smoke tests exercise fixture navigation only and do not request permissions, call MusicKit or Network, control playback, or satisfy any physical-device/canonical gate. |
