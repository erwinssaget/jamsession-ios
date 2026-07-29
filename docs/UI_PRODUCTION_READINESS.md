# Mock UI Production-Readiness Review

Last reviewed: 2026-07-28

## Outcome

The P0–P6 mock UI remains suitable for presentation review and provisional
walkthroughs. The queue is now the first production-connected presentation
surface: Slice 2A maps canonical `HostSessionModel` state into immutable
`QueueSessionPresentation` values and applies typed actions through the real
fairness scheduler. Slice 2B-A connects the Host profile, typed Music
eligibility, solo lobby, and start transition to that same owner. Slice 2B-B
connects cancellable Host catalog search and freshly resolved Host-storefront
selections to the same authoritative command boundary. Slice 2B-C adds a Main
Actor Host player, pure queue-diff planning, thin MusicKit execution, and typed
reconciliation recovery around that canonical queue. Slice 2B-D adds one
lifecycle-bound playback observer, pure transition deduplication, current-track
presentation, and Host play/pause/current-track skip controls through the same
player boundary.

The mock coordinators, scenario enums, guest search, admission/invite, guest
playback presentation, lifecycle, and transport surfaces are not
production-connected. Future integration must continue replacing fixture
ownership with canonical mapped state and typed intents rather than promoting
mock coordinators into app architecture.

Canonical gate status remains authoritative in `VERIFICATION_LOG.md`. Revision 7
of the build plan splits feasibility by capability: Slice 2A is complete,
host-only MusicKit work may proceed under 0M, gate 0G is open but guest catalog
still waits for its canonical Slice 2B and Slice 3 prerequisites, and nearby
transport work remains blocked by 0N.

## What is reusable now

- Visual composition, hierarchy, responsive stacks, and status-card treatments.
- Localized user-facing copy as a product-language starting point.
- Queue components driven by production-neutral immutable presentation values,
  including viewer-specific remove/skip actions and typed feedback.
- A Main Actor authoritative local session owner with idempotent commands that
  route every queue mutation through the fairness scheduler.
- A Main Actor Host flow coordinator with a shared validated profile form,
  protocol-isolated Apple Music eligibility check, typed recovery states, and
  immutable solo-lobby presentation.
- A Main Actor Host catalog search model with lifecycle-owned debounce,
  cancellation, request identity, stale-result suppression, typed failures,
  Host-storefront re-resolution, canonical submission, and localized feedback.
- A Main Actor Host player with lifecycle-owned observation/control tasks, pure
  transition deduplication, stable canonical command identities, typed failure
  recovery, and responsive accessible current-track controls.
- Participant identity presentation using name, emoji, and color without relying
  on color alone.
- Empty, loading, denied, offline, failure, departure, host-loss, ending, and
  ended visual states.
- Accessibility adaptations for large Dynamic Type, Reduce Motion semantics, and
  expanded copy.
- Intent closures on several leaf views, including role selection, lobby
  approval/rejection, discovery selection, search-result addition, retry, and
  feedback dismissal.

## What must remain mock-only

- `MockPrototypeStep` and every automatic walkthrough transition.
- All `Mock*Scenario` enums and preview-state menus.
- `Mock*Fixtures`, simulated approval, decorative invite QR, room code, static
  countdown, static progress, and fake track/participant content.
- Scenario-owned `@State` in gallery composition views.
- The feasibility-harness mock routes once production navigation exists.

Do not rename these types to remove `Mock` and then treat them as production
models. Introduce production-neutral values only alongside a real canonical
caller.

## Seam audit

| Area | Current input/state | Current intents | Readiness finding |
|------|---------------------|-----------------|-------------------|
| Role choice | `SessionRole`; mock-only choice navigation | select Host or Join | The value is production-neutral, but production role-choice navigation remains open. The Debug Host route currently selects Host explicitly. |
| Profile | Shared `ProfileSetupView` with local editing state and validated `ProfileDraft` output | submit profile | Production-connected for Host. `HostFlowCoordinator` creates a separate session-scoped identity; local preference persistence remains intentionally absent. |
| Permission explanation | `HostMusicAccessView` plus typed `HostMusicAccessState`; Join mock remains inert | request/check again, open Settings, return to profile | Production-connected for Host through `HostMusicEligibilityChecking`. Each request has an optional UUID task identity owned by `HostFlowView`; leaving the step clears that identity and cancels the in-flight checker before another request can start. Catalog requests revalidate authorization/subscription, while physical system-sheet cancellation and player-state recovery remain open. |
| Host lobby | `HostLobbyPresentation` mapped from solo `HostSessionModel` | start alone or cancel | Production-connected for solo Host start. Role-specific accessibility labels distinguish the Host from future Guest rows. Admission, invite, capacity changes, and nearby participants remain blocked on Slice 3/0N. |
| Admission | Fixture scenario and participant | approve, reject, retry, select room | Leaf intents are useful but ad hoc. Define typed coordinator intents when the authoritative host/guest caller exists. |
| Invite | Decorative QR and hard-coded room code | dismiss | Not production-ready. A production invite value must distinguish shareable room code from sensitive high-entropy join credential and prevent secret exposure in logs/accessibility. |
| Queue | `QueueSessionPresentation` mapped from `HostSessionModel` in the functional harness or Host flow, or constructed from deterministic mock fixtures in galleries | Add Music, remove pending, skip turn, play/pause, current-track skip, dismiss feedback, retry queue sync | Ready and connected for Slice 2A, Host-local Add Music in Slice 2B-B, Host queue reconciliation in Slice 2B-C, and Host playback transitions/controls in Slice 2B-D. Canonical queue identities drive lifecycle-owned reconciliation and observation tasks; pure planning preserves a protected current entry; a pure deduplicator maps managed player transitions to one stable canonical command; and typed failures pause playback and expose retry. Turn-skip and current-track controls bind to canonical submission identities so stale UI cannot mutate a replacement track. Live MusicKit/physical-device behavior and a manual VoiceOver focus pass remain open. |
| Search | Production `HostCatalogSearchState` and `HostCatalogSubmissionOutcome`; mock scenarios remain isolated | query, retry, add, dismiss feedback, close | Production-connected for Host through `HostCatalogServicing`. Structured tasks own debounce/cancellation, request IDs suppress stale work, the service returns only domain values, and every add re-resolves against the Host storefront before `HostSessionModel`. Guest search remains blocked on 0G/Slice 4. |
| Lifecycle | Static scenario, countdown, progress | restart | Presentation only. Production must own grace-period clocks, reconnection, end-session cancellation, and teardown. Host playback-transition deduplication is now owned separately by `HostPlayer`. |
| Connected walkthrough | `MockPrototypeStep` | automatic fixture navigation | Must be replaced wholesale by production coordinators. It is not a session state machine. |

## Hardening backlog allowed before Slice 0 opens

These tasks remain presentation- or pure-value work and do not assume unverified
MusicKit, Network, playback, or lifecycle behavior.

### R1 — Complete the profile value seam — COMPLETE

Create a pure, `Sendable`, production-neutral profile draft containing:

- trimmed display name;
- selected emoji;
- selected color identifier; and
- validation result.

Pass that value from profile completion instead of only `String`. Keep persistence
out of this step. Later, a production caller may remember allowed profile
preferences locally and create a separate session-scoped participant identity.

Implemented on 2026-07-22:

- `ProfileDraft` carries normalized display name, emoji, and `ProfileColorID`.
- `ProfileDraftValidator` is a pure, synchronous, explicitly `nonisolated` type.
- `MockProfileSetupView` emits the complete validated draft.
- `MockPrototypeFlowView` retains the complete draft while presenting the inert
  permission explanation.
- Five focused Swift Testing cases cover normalization, blank input, the exact
  30-character boundary, overflow, and missing emoji.

### R2 — Separate gallery ownership from leaf presentation — COMPLETE

Keep each `Mock*GalleryView` as a debug fixture owner. Where production reuse is
likely, ensure the leaf view accepts:

- immutable presentation values;
- explicit loading/error/status values; and
- closures or typed intents for user actions.

Do not extract abstractions solely to remove `Mock` naming. Require a real caller
or a concrete testing benefit.

Completed on 2026-07-23:

- `MockJoinedQueueView` now owns only fixture scenario selection and Add Music
  sheet presentation.
- `MockJoinedQueuePresentationView` accepts immutable
  `MockSessionPresentation` plus explicit Add Music and optional lifecycle
  closures.
- `MockSessionHeaderView` emits Add Music through a closure instead of mutating a
  parent-owned sheet binding.
- `MockSessionPresentation` is equatable for pure mapping assertions, and
  `MockQueueScenarioPresentationTests` protects populated, empty, and reconnecting
  mappings.
- Lobby, search, and lifecycle galleries already delegate their supplied scenario
  to leaf presentation views; further extraction requires a production caller or
  a new concrete testing benefit.

Superseded for the queue on 2026-07-24: Slice 2A replaced
`MockSessionPresentation` with `QueueSessionPresentation`, extracted shared
non-mock queue components, and added `HostSessionModel` as the first canonical
caller. Mock galleries now construct the shared presentation value only as
fixtures.

### R3 — Stabilize deterministic fixture identity — COMPLETE

Replace launch-random `UUID()` fixture IDs with stable fixture identifiers before
adding snapshot or state-transition tests. This prevents identity churn from
obscuring regressions while keeping production participant and request identity
separate.

Implemented on 2026-07-22:

- `MockFixtureID` defines stable participant and track identifiers for preview and
  test fixtures.
- Lobby and queue fixtures share participant identity where they represent the
  same person.
- Search and queue fixtures share track identity where they represent the same
  catalog result.
- Three focused tests protect shared identity, domain uniqueness, and cross-flow
  track identity.

### R4 — Define intent inventories, not production coordinators — COMPLETE

Record the eventual intents needed by each feature:

- first run: select role, submit profile, cancel;
- lobby: invite, request join, approve, reject, retry, start;
- queue: add music, open lifecycle details;
- search: update query, retry, submit track, dismiss feedback;
- lifecycle: acknowledge terminal state and return home.

Do not implement transport messages, host commands, or actor ownership until the
corresponding canonical slice opens.

Completed on 2026-07-22 in
[`UI_INTENT_INVENTORY.md`](UI_INTENT_INVENTORY.md). The inventory records payload,
eventual owner, validation/result behavior, repetition, and cancellation for each
mock-exposed product intent, and explicitly excludes gallery-only controls from
production.

### R5 — Add high-value presentation tests — COMPLETE

Prefer pure tests for:

- profile validation and normalized output;
- mapping typed rejection cases to correct explanatory presentation;
- scenario completeness so new enum cases cannot silently lack copy; and
- stable fixture construction.

Use UI tests only for connected navigation that cannot be protected below the UI
layer. Do not claim simulator tests prove physical-device behavior.

Implemented on 2026-07-22:

- `MockSubmissionOutcome` maps every typed fixture outcome to a pure
  `MockSubmissionFeedbackPresentation` containing localization keys, symbol, and
  semantic tone.
- `MockSubmissionFeedbackView` renders that presentation without duplicating the
  outcome switch in the view layer.
- Focused tests exhaustively protect all seven feedback outcomes.
- Scenario-completeness tests protect non-empty, unique title keys across queue,
  lobby, search, lifecycle, and feedback cases.

### R6 — Debug-scope provisional routes before release integration — COMPLETE

Before a production entry flow becomes available:

- keep the feasibility harness intact for Slice 0;
- decide whether mock galleries remain in debug builds or previews only;
- ensure fixture controls, decorative credentials, and simulated approval cannot
  appear in release navigation; and
- delete obsolete fixtures once production previews have equivalent safe data.

Completed on 2026-07-23:

- Every feasibility-harness link to a mock gallery or connected mock flow is
  compiled only when `DEBUG` is active.
- `FeasibilityDestination` is itself debug-only, so release navigation cannot
  construct a mock destination.
- Mock views and deterministic fixtures remain compiled for previews and tests;
  they have no release navigation entry point.
- The MusicKit and Network feasibility controls remain intact.
- Both the active Debug build and a generic Release simulator build completed
  successfully.

### Post-backlog connected-flow smoke coverage — COMPLETE

Completed on 2026-07-23:

- `MockConnectedFlowUITests` exercises the debug-only connected flow through both
  Host and Join paths.
- Both paths submit a valid profile, finish the inert permission explanation,
  reach the joined queue, open and dismiss Add Music, and restart to role
  selection.
- The Join path also selects the nearby fixture and applies the clearly labeled
  simulated host approval.
- Stable accessibility identifiers target intent-bearing mock controls without
  relying on localized display copy.
- Both UI tests pass on the iPhone 14 Pro iOS 26.5 simulator. They prove fixture
  navigation only and provide no MusicKit, Network, playback, or physical-device
  evidence.

## Gate-dependent integration order

1. Preserve the completed R1–R6 and Slice 2A seams. Add further leaf extraction
   only when a concrete production caller or testing benefit justifies it.
2. Implement Slice 2B under the open host-MusicKit gate 0M, and retest its
   physical-device behavior at the Slice 2B exit gate.
3. Gate 0G is open for Slice 4, but 0N remains closed pending active-link
   lifecycle verification. Continue the current Slice 2B work; do not begin
   Slice 3 nearby transport/admission until 0N opens, and begin Slice 4 guest
   catalog only after Slice 2B and Slice 3 satisfy their exit gates.
4. Reuse the canonical host owner and immutable queue presentation rather than
   creating a second queue authority.
5. Replace ad-hoc closure seams with typed coordinator intents where production
   ownership is known.
6. Connect MusicKit catalog search and playback only through their designated
   boundaries.
7. Connect transport/admission/lifecycle only after actor ownership,
   idempotency, revisions, cancellation, and teardown behavior are defined.
8. Run fairness tests for every queue-affecting integration and the named
   physical-device checks for behavior that cannot be proven in mocks.
9. Keep provisional navigation debug-scoped and remove obsolete fixtures when
   production previews provide equivalent safe data.

## Definition of ready for the first production connection

The first mock surface is ready to connect only when:

- its canonical production slice is open;
- the state owner and actor isolation are named;
- immutable presentation input is defined;
- every enabled user action has a typed owner and validation path;
- cancellation and repeated-operation behavior are specified;
- success, empty, loading, failure, and terminal states are mapped;
- privacy-sensitive values are excluded from logs and accessibility output;
- relevant unit tests exist; and
- the mock route remains isolated or debug-scoped during transition.

The queue satisfies this definition for Slice 2A. Host profile, Music
eligibility, and solo lobby satisfy it for Slice 2B-A. Host-local catalog search
and submission satisfy it for Slice 2B-B. Host queue reconciliation satisfies it
for Slice 2B-C, and Host playback transitions and controls satisfy it for Slice
2B-D under deterministic automated boundaries. Other surfaces must be evaluated
independently as their owning production slices open.

## Next authorized task

The generic R1–R6 backlog, connected-flow smoke coverage, Slice 2A, and Slice
2B-A through 2B-D are complete in their stated automated scope. Continue only
the remaining bounded Slice 2B work: production role-choice/subscription-offer
handoff and confirmed end-session teardown, followed by the complete
profile → authorization → lobby → search → queue → playback → end
physical-device exit flow with live `ApplicationMusicPlayer`. Select the next
increment explicitly before implementation rather than combining navigation,
lifecycle, and hardware verification. Defer nearby transport to Slice 3 and
guest catalog to Slice 4. Gate 0N remains closed pending active-link lifecycle
verification; gate 0G is open, but the canonical prerequisites and current Slice
2B scope still apply.
