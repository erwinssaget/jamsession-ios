# Build Plan — Ephemeral Shared-Queue Music Sessions

Revision: 4
Last updated: 2026-07-18

## Authority and usage

This is the canonical implementation sequence. Read
[`PRODUCT_DECISIONS.md`](PRODUCT_DECISIONS.md) and the repository
[`AGENTS.md`](../AGENTS.md) before starting a slice.

Implement one slice at a time. Do not begin the next slice until the current
slice's exit gate has been demonstrated. If a feasibility gate fails, update the
product decision record before changing architecture or scope.

Physical-device results and unresolved hardware gates are tracked in
[`VERIFICATION_LOG.md`](VERIFICATION_LOG.md). A hardware or account dependency
does not make an exit gate pass.

### Provisional work while a feasibility gate is blocked

When a Slice 0 check cannot run solely because required physical hardware or an
account state is unavailable, low-coupling work from a later slice may proceed
provisionally only when all of the following are true:

- The blocked check and exact dependency are recorded in `VERIFICATION_LOG.md`.
- The work is independently useful and does not assume an unverified MusicKit,
  Network framework, permission, or lifecycle behavior.
- The work has a mockable or pure boundary and can be revised without preserving
  compatibility with an unverified spike.
- No dependent integration slice starts, and no later slice is declared complete,
  until Slice 0 passes or the product decision and this plan are deliberately
  revised.

The pure Slice 1 fairness engine is authorized under this exception because it has
no MusicKit, Network, clock, I/O, or physical-device dependency. Transport,
playback, permission-flow, and lifecycle architecture are not authorized by this
exception where their design depends on an unresolved Slice 0 result.

## Repository baseline

- Existing source roots are `Jamsession/`, `JamsessionTests/`, and
  `JamsessionUITests/`; do not create parallel `Sources/` or `Tests/` roots.
- The app target already uses Main Actor default isolation.
- The project currently records deployment target 26.5 and Swift language version
  6.0. Slice 0 must verify the installed compiler, then lower the deployment target
  to 26.0 unless a documented API requires otherwise.
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

### Tasks

- Verify the installed Xcode/Swift compiler and set the true minimum deployment
  target to iOS 26.0 if supported.
- Enable MusicKit and required signing capabilities. Use automatic developer-token
  management; do not implement custom `.p8` injection.
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

### Exit gate

- Physical subscriber playback works.
- Physical non-subscriber catalog search is either proven or the product promise is
  revised.
- Two devices discover, connect, exchange framed messages, and terminate cleanly.
- Permission denial is distinguishable from no nearby room.
- Findings and platform limitations are recorded in `PRODUCT_DECISIONS.md`.

Do not proceed if either MusicKit or local peer-to-peer feasibility remains
unverified.

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

## Slice 2 — Host player and reconciliation spike

### Goal

Turn the fair logical queue into stable host playback without restarting the current
track or advancing rotation twice.

### Tasks

- Add cancellable, debounced catalog search behind a protocol.
- Add a Main Actor host player around `ApplicationMusicPlayer.shared`.
- Add host-storefront resolution behind a mockable protocol.
- Map MusicKit `Song` values into domain metadata without leaking MusicKit types into
  fairness.
- Build `QueueReconciler` as a testable diff planner plus a thin MusicKit executor.
- Own exactly one playback transition observation task with an explicit cancellation
  path and event deduplication.
- Handle pause, host skip, track completion, unplayable entry, reconciliation
  failure, interruption, and route change.

### Exit gate

- A fair multi-participant fixture plays on a subscriber device.
- Adding/removing future tracks does not disturb the current track.
- Completion and skip advance once even under repeated callbacks.
- A reconciliation failure pauses and surfaces an actionable state.
- Pure diff-planning and transition-deduplication tests pass.

## Slice 3 — Authoritative session protocol and transport

### Goal

Make two or more devices converge on host-owned state across discovery, admission,
commands, snapshots, loss, and reconnection.

### Tasks

- Implement production `SessionTransport` with the proven iOS 26 Network APIs.
- Use host-and-spoke connections and structured tasks with explicit ownership and
  cancellation.
- Define length-prefixed framing, maximum message size, protocol version, session
  ID, participant ID, request ID, host revision, and typed payload.
- Implement random on-device identity and per-session reconnect credential.
- Implement Bonjour discovery, host approval, QR admission secret, and short-code
  local filtering. Short codes never bypass approval.
- Enforce eight total devices, preserving a reconnecting participant's slot.
- Implement host command authorization, request idempotency, typed acknowledgement
  or rejection, monotonic revisions, and full reconnect snapshots.
- Rate-limit before command processing. Reject malformed, oversized, stale,
  unauthorized, version-incompatible, and blocked requests.
- Never include peer credentials or admission secrets in broadcast snapshots.

### Tests

- Envelope and every payload round-trip.
- Truncated, oversized, malformed, and unknown-version frames fail safely.
- Replayed request mutates state once and returns a consistent result.
- Unauthorized cross-participant remove/skip is rejected.
- Old snapshot cannot replace a newer guest mirror.
- Ninth device is rejected; reconnecting identity reclaims reserved slot.
- Blocked identity cannot rejoin or submit.
- Connection and observation tasks terminate on session end.
- Physical-device discovery, approval, QR join, short-code join, disconnect, and
  reconnect scenarios pass.

### Exit gate

- At least three physical devices maintain a consistent mock session through a
  disconnect/reconnect cycle.
- Host state remains canonical under duplicate and stale delivery.
- Instruments/log inspection shows no leaked participant or credential data.

## Slice 4A — Lobby, joining, and session shell

### Goal

Deliver the complete pre-play experience and authoritative lifecycle shell.

### Tasks

- First-run name/avatar setup and Host/Join entry.
- Just-in-time MusicKit and local-network explainers and permission flows.
- Host eligibility and guest search eligibility states.
- Lobby creation, host ordering, guest approval, pre-submission, start, and locked
  order.
- Discovery, QR scan, short-code filtering, room-full, rejection, and update-required
  UI.
- Guest mirror, connected/reconnecting/gone/removed states, and empty queue shell.

### Exit gate

- Host and two guests can form a lobby, arrange order, pre-submit mock tracks, start,
  late join, disconnect, reconnect, remove, and end without MusicKit playback.
- All introduced states are VoiceOver and Dynamic Type usable.

## Slice 4B — Search, submission, fairness, and playback

### Goal

Deliver the actual multi-device fair queue and playback loop.

### Tasks

- Guest pending submission -> host storefront resolution -> authorization and
  fairness validation -> acknowledgement/rejection -> canonical snapshot.
- Separate `FairnessRejection`, `TrackValidationRejection`, and session-command
  rejection, then map them into localized `SubmissionRejection` UI.
- Search loading, cancellation, empty, denial, offline, and failure states.
- Pending-cap and duplicate feedback.
- Queue, now playing, participant attribution, remove-own, turn skip, host turn
  skip, current-track skip, moderation removal, gone/return, and late join.
- Fair queue reconciliation, automatic empty-queue resume, track failure, and play
  history in memory.

### Exit gate

- Host plus two guests complete the full fair loop on physical devices.
- Every skip/failure type has correct queue, duplicate, cap, rotation, and history
  behavior.
- Integration tests drive the scheduler through fake transport and player services.

## Slice 4C — Lifecycle and release hardening

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

## Slice 5 — Save the night (post-MVP)

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
