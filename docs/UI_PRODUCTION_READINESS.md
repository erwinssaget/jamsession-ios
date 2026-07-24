# Mock UI Production-Readiness Review

Last reviewed: 2026-07-23

## Outcome

The P0–P6 mock UI is suitable for presentation review and provisional
walkthroughs. It is **not ready to connect directly to production session,
transport, MusicKit, playback, or lifecycle state**.

This is expected. The provisional track intentionally optimized for deterministic
visual exploration while Slice 0 remains closed. Production integration must
replace fixture ownership with canonical mapped state and typed intents rather
than promoting mock coordinators or scenario enums into app architecture.

Canonical gate status remains authoritative in `VERIFICATION_LOG.md`. At this
review, Slice 0 is closed by V0-2, V0-4, V0-5, V0-6B, and V0-7B.

## What is reusable now

- Visual composition, hierarchy, responsive stacks, and status-card treatments.
- Localized user-facing copy as a product-language starting point.
- Queue rows that consume supplied immutable order.
- Search result and typed-feedback presentation concepts.
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
| Role choice | `MockEntryRole`; optional local navigation | select Host or Join | The leaf choice is reusable. Production navigation should own the selected role and permission flow. |
| Profile | Local name, emoji, color, validation | `onContinue(ProfileDraft)` | The pure validated seam preserves normalized name, emoji, and color. Production may map it to local preferences and a separate session-scoped identity when the owning slice opens. |
| Permission explanation | Role and display name | continue or dismiss | Visual content is reusable, but the view owns sheet/navigation behavior. Production coordinators must own authorization, subscription checks, recovery, and cancellation. |
| Host lobby | Immutable participant array | invite and optional start | Suitable presentation seam. Production must also represent admission requests, capacity, and start eligibility without allowing views to reorder participants. |
| Admission | Fixture scenario and participant | approve, reject, retry, select room | Leaf intents are useful but ad hoc. Define typed coordinator intents when the authoritative host/guest caller exists. |
| Invite | Decorative QR and hard-coded room code | dismiss | Not production-ready. A production invite value must distinguish shareable room code from sensitive high-entropy join credential and prevent secret exposure in logs/accessibility. |
| Queue | `MockSessionPresentation`; gallery-owned scenario | Add Music; optional lifecycle gallery | Queue components accept immutable supplied order, but `MockJoinedQueueView` owns fixtures. Create a production queue presentation only beside host/snapshot mapping. |
| Search | Local query, scenario, result fixtures, feedback outcome | add, retry, dismiss | The leaf result callback carries the selected track through its parent, but the composition owns fake state. Production search requires cancellable query intent, request identity, stale-result suppression, and typed submission acknowledgement. |
| Lifecycle | Static scenario, countdown, progress | restart | Presentation only. Production must own grace-period clocks, reconnection, playback transition deduplication, cancellation, and teardown. |
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

1. Preserve the completed R1–R6 hardening seams. Add further leaf extraction only
   when a concrete production caller or testing benefit justifies it.
2. Finish the open Slice 0 physical-device/account checks or deliberately revise
   the canonical product decision and build plan.
3. Implement production slices in `BUILD_PLAN.md` order.
4. Introduce canonical host/guest state owners and map them into immutable
   presentation values.
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

## Next authorized task

The generic R1–R6 backlog and connected-flow smoke coverage are complete. The
next safe mock task is a **connected accessibility pass** at AX5 Dynamic Type and
dark appearance, checking the Host and Join paths for hittable controls, readable
expanded copy, keyboard avoidance, and sheet dismissal. Otherwise, limit work to
targeted accessibility/localization defects until Slice 0 opens.
