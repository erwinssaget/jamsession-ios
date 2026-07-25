# Provisional UI Prototype — Continuation Handoff

Last updated: 2026-07-24

## Purpose

This document lets a new Codex context continue the mock-driven SwiftUI track
without inferring backend behavior or reopening settled product decisions.

Before changing UI, read:

1. [`PRODUCT_DECISIONS.md`](PRODUCT_DECISIONS.md)
2. [`BUILD_PLAN.md`](BUILD_PLAN.md), especially **Provisional mock-driven UI track**
3. [`VERIFICATION_LOG.md`](VERIFICATION_LOG.md), especially
   **Provisional mock-UI verification**
4. The repository `AGENTS.md`
5. [`UI_PRODUCTION_READINESS.md`](UI_PRODUCTION_READINESS.md) after P0–P6
   completion
6. [`UI_INTENT_INVENTORY.md`](UI_INTENT_INVENTORY.md) before changing view
   actions or production coordinator seams

The canonical documents remain authoritative. This handoff records implementation
status and design intent only.

## Required update protocol

Update this document in the same change whenever provisional UI work:

- completes or materially changes a P0–P6 slice;
- adds, removes, or renames a mock route, fixture, scenario, or presentation type;
- establishes a production-facing view input or changes an intended integration
  seam;
- verifies a new preview, accessibility variant, build, or warning check; or
- discovers a gap that later production integration must resolve.

Every update must keep these sections current:

1. **Current status** — completed and open slices.
2. **Implementation map** — exact source locations and responsibilities.
3. **Production connection map** — what replaces each fixture and what remains.
4. **Verification baseline** — only checks actually run.
5. **Fresh-context starting prompt** — the next concrete slice or integration
   task.

Also add a dated row to `VERIFICATION_LOG.md` for checks actually performed.
Do not convert mock observations into canonical gate evidence.

## Current status

The provisional galleries remain isolated from production authority. Slice 2A
adds a domain-backed functional queue path, Slice 2B-A adds the first production
Host coordinator through profile, Music eligibility, solo lobby, and canonical
empty queue, and Slice 2B-B connects Host catalog search plus storefront-validated
submission to that queue authority.

- **P0 complete:** the canonical plan authorizes the mock-only track and the
  feasibility harness exposes an explicit mock queue route.
- **P1 foundation complete for the queue shell:** reusable participant badges,
  artwork placeholders, queue rows, now-playing treatment, localized strings, and
  accessibility labels exist.
- **P2 complete:** an explicit mock first-run route covers Host/Join choice,
  display name, emoji and color identity, validation, duplicate-name guidance,
  cancellation, and inert role-specific permission explainers.
- **P3 complete:** an explicit lobby gallery covers host order, admission
  approval/rejection, discovery, no nearby rooms, awaiting approval, room full,
  and a decorative invite presentation with no join credential.
- **P4 shell complete:** the joined-session screen has populated, empty, and
  reconnecting fixture states plus an Add Music placeholder.
- **Connected walkthrough complete for current happy paths:** a fixture-only
  coordinator joins P2, P3, and the P4 shell into Host and Join walkthroughs while
  preserving direct gallery routes for edge states.
- **P5 complete:** Add Music opens a fixture-driven catalog search with idle,
  loading, results, empty, denied, offline, and failure states plus pending,
  accepted, duplicate, pending-limit, inactive, unplayable, and timeout feedback.
- **P6 complete:** an explicit lifecycle gallery covers participant gone/removed,
  track failure, host loss, ending/ended, Reduce Motion, and localization
  expansion fixtures.
- **P0–P6 provisional presentation work is complete.** This does not open or
  satisfy canonical production gates.
- **Readiness R1–R6 complete:** profile completion preserves a validated value,
  joined-queue fixture ownership is separated from its leaf presentation,
  fixture identity is stable across flows, user intents are inventoried, pure
  tests protect presentation mappings, and every mock navigation route is
  debug-only.
- **Connected smoke coverage complete:** debug-only UI tests exercise both Host
  and Join fixture paths through profile, inert permission explanation, queue,
  Add Music presentation, dismissal, and restart. The Host path also exercises
  the scrollable invite sheet at accessibility text sizes and Session Ended →
  Return Home through the lifecycle gallery. The Join path also covers denied
  Music-access Settings recovery plus lower-result submission feedback and its
  separate accessibility dismissal control.
- **Slice 2A complete:** a real Main Actor `HostSessionModel`, idempotent
  `QueueCommand`, canonical fairness state, immutable `QueueSessionPresentation`,
  and localized typed feedback now drive a Debug-only functional queue harness.
  The reusable queue components no longer depend on mock presentation types.
- **Slice 2B-A complete; Slice 2B remains in progress:** the shared
  `ProfileSetupView` feeds `HostFlowCoordinator`; a typed async Music eligibility
  boundary handles eligible, denied, restricted, subscription-required,
  unavailable, and cancellation outcomes; and eligible Hosts create an ephemeral
  solo lobby and start the canonical empty queue.
- **Slice 2B-B complete; Slice 2B remains in progress:** `HostCatalogSearchModel`
  owns debounced lifecycle-bound search state and request identity;
  `AppleMusicHostCatalogService` resolves the Host storefront, maps `Song`, and
  re-resolves every selected ID before the canonical Host command; typed
  authorization, subscription, offline, unavailable, unplayable, and fairness
  feedback drive production-neutral views. The path stays Debug-reachable until
  playback and lifecycle are connected.
- **PR #4 review follow-up complete:** the Debug functional catalog presents
  canonical queue-command feedback above the sheet, including a reachable dismiss
  action, and the production solo-lobby participant rows announce the correct Host
  or Guest role. Turn-skip commands bind to the submission displayed by the
  initiating control and reject stale actions before fairness state changes.
  Asynchronous queue feedback moves VoiceOver focus to a combined title/message
  summary. Host Music eligibility requests now have explicit SwiftUI task identity
  that is cleared when the user leaves the step, cancelling abandoned work before
  another attempt can start. The live MusicKit denial/recovery gate question
  remains open.

“Complete” above means complete only for provisional design exploration. It does
not satisfy or open a canonical Slice 4 gate. Slice 2A is separately complete
under its pure/domain implementation exit gate and does not alter 0M, 0G, or 0N.

## Implementation map

| Area | Location | Responsibility |
|------|----------|----------------|
| Mock entry route | `Jamsession/ContentView.swift` and `Jamsession/FeasibilityDestination.swift` | Keeps the prototype reachable in Debug without replacing Slice 0 tools; no Release navigation route is compiled |
| First-run prototype | `Jamsession/Features/FirstRun/` | Host/Join choice, identity setup, validation, and inert permission explanation |
| Shared profile form | `Jamsession/Features/FirstRun/ProfileSetupView.swift` and `Jamsession/Models/SessionRole.swift` | Production-neutral validated role/profile input shared by the Host coordinator and mock wrapper |
| Production Host flow | `Jamsession/Features/HostFlow/` | Main Actor profile → Music eligibility → solo lobby → canonical queue coordination plus immutable lobby presentation |
| Host Music eligibility boundary | `Jamsession/Music/HostMusicEligibilityChecking.swift` and `AppleMusicHostEligibilityChecker.swift` | Isolates just-in-time Music authorization and subscription capability from the coordinator and SwiftUI |
| Host catalog boundary | `Jamsession/Music/HostCatalogServicing.swift`, `AppleMusicHostCatalogService.swift`, and `AppleMusicCatalogTrackMapper.swift` | Isolates Host storefront resolution, MusicKit search/resource requests, playability checks, and `Song` mapping from state and views |
| Lobby prototype | `Jamsession/Features/Lobby/` | Host participant order, admission state gallery, discovery fixtures, and decorative invite |
| Connected walkthrough | `Jamsession/Features/Prototype/` | Fixture-only navigation state joining first run, lobby/discovery, approval, and joined queue |
| Search presentation | `Jamsession/Features/Search/` | Production Host search model/state/views plus isolated mock catalog-state fixtures and feedback galleries |
| Lifecycle prototype | `Jamsession/Features/Lifecycle/` | Departure, failure, host-loss, teardown, Reduce Motion, and expanded-copy fixtures |
| Joined-session gallery | `Jamsession/MockJoinedQueueView.swift` | Owns fixture scenario selection and Add Music sheet presentation |
| Joined-session leaf | `Jamsession/Features/Queue/MockJoinedQueuePresentationView.swift` | Renders immutable queue presentation and emits Add Music/Lifecycle intents |
| Presentation fixtures | `Jamsession/Features/MockSupport/`, `Jamsession/Features/Queue/Mock/`, and feature fixture files | Stable deterministic mock session, participant, track, and scenario values |
| Canonical queue owner and commands | `Jamsession/Session/` | Owns participant metadata and canonical `RotationState` on the Main Actor; validates idempotent queue commands through `FairnessScheduler` |
| Queue presentation boundary | `Jamsession/Features/Queue/QueueSessionPresentation.swift` and `QueueSessionPresentationMapper.swift` | Maps canonical state into immutable, production-neutral values with viewer-specific action availability |
| Queue components | `Jamsession/Features/Queue/` | Participant badge, artwork, session header, now playing, immutable queue rows, action controls, and typed feedback shared by mock and functional callers |
| Functional queue harness | `Jamsession/Features/Queue/Debug/` | Owns deterministic participants and catalog choices in Debug only while exercising the real session owner, commands, scheduler, and presentation mapper |
| Intent inventory | `docs/UI_INTENT_INVENTORY.md` | Records eventual owners, payloads, validation/results, repetition, cancellation, and mock-only controls |
| Presentation and session tests | `JamsessionTests/MockUI/`, `JamsessionTests/Queue/`, `JamsessionTests/Search/`, and `JamsessionTests/Session/` | Protect fixture behavior plus canonical command, fairness integration, Host search cancellation/stale suppression, storefront resolution outcomes, authorization, replay, mapper, and feedback behavior |
| Connected UI smoke tests | `JamsessionUITests/MockConnectedFlowUITests.swift`, `DomainQueueHarnessUITests.swift`, and `HostFlowUITests.swift` | Exercises mock navigation, canonical fairness-backed queue behavior, and Host profile → solo start → search → canonical submission with Debug-only injected Music boundaries |
| User-facing copy | `Jamsession/Localizable.xcstrings` | Manual English localization keys for provisional and functional queue UI |

The Xcode project uses synchronized groups, so new files under `Jamsession/` should
be discovered automatically. Verify target membership instead of reflexively
editing `project.pbxproj`.

## Current mock route graph

In Debug builds, all provisional routes begin in the existing Slice 0 feasibility
harness:

```text
ContentView
├── Open Host Flow
│   └── HostFlowView
│       ├── shared ProfileSetupView
│       ├── real AppleMusicHostEligibilityChecker (explicit user action only)
│       ├── Host lobby → Start Session
│       └── canonical queue
│           └── Add Music → real Host catalog boundary
│               → fresh Host-storefront resolution → typed submit command
│               (Debug service injected for UI tests; playback pending)
├── Open Functional Queue
│   └── DomainQueueHarnessView
│       ├── real HostSessionModel → FairnessScheduler → QueueSessionPresentation
│       ├── Add Music → deterministic Debug catalog → typed submit command
│       └── remove / skip turn / advance playback → typed commands
├── Open Mock Full Flow
│   └── MockPrototypeFlowView
│       ├── Welcome → Profile → inert permission explanation
│       ├── Host → Host lobby → Start Session → Joined queue
│       └── Join → Discovery → Awaiting approval
│                    → Simulate Host Approval → Joined queue
│                                           ├── Add Music → Mock search
│                                           └── Lifecycle States → Lifecycle gallery
├── Open Mock First Run
│   └── MockEntryView
│       ├── Host a Session
│       └── Join a Session
│           └── MockProfileSetupView
│               └── inert permission explainer
├── Open Mock Lobby Gallery
│   └── MockLobbyGalleryView
│       ├── host lobby / invite
│       ├── approval / rejection
│       └── discovery / awaiting / no nearby / room full
├── Open Mock Joined Queue
│   └── MockJoinedQueueView
│       ├── populated
│       ├── empty
│       ├── reconnecting
│       └── Add Music → MockMusicSearchView
├── Open Mock Search Gallery
│   └── MockMusicSearchView
│       ├── idle / loading / results / empty
│       ├── denied / offline / failed
│       └── pending / accepted / typed rejection feedback
└── Open Mock Lifecycle Gallery
    └── MockLifecycleGalleryView
        ├── participant gone / removed / track failed
        ├── host loss / ending / ended
        └── Reduce Motion / localization expansion
```

These are deliberately separate gallery entries. They demonstrate adjacent
product stages without claiming that a production session transition exists. The
full-flow entry connects their presentation happy paths using
`MockPrototypeStep`; its transitions are fixture navigation, not session,
transport, MusicKit, admission, or fairness behavior.

The mock and functional-harness route buttons and `FeasibilityDestination` are
excluded when `DEBUG` is not active. Mock views and deterministic functional
fixtures remain compiled for previews and tests but cannot be reached from
Release navigation.

## Production connection map

The mock UI is disposable presentation scaffolding. Production integration should
preserve useful views and replace fixture ownership at explicit seams:

| Prototype area | Fixture/state used now | Production source later | Integration action |
|----------------|------------------------|-------------------------|--------------------|
| Connected walkthrough | `MockPrototypeStep` and local sheet state | App-level host/join coordinators and typed navigation destinations | Replace the mock step switch with production coordinator state. Keep reusable screens driven by values and intent closures; do not preserve simulated approval as production behavior. |
| First-run role choice | Production-neutral `SessionRole` with mock-only choice navigation | App navigation plus host/join coordinators | Keep the visual choice surface; production Host routing exists only as an explicit Debug entry while complete role-choice navigation remains open. |
| Profile setup | Shared `ProfileSetupView` emits a validated `ProfileDraft`; mock wrapper retains fixture-only explainer ownership | `HostFlowCoordinator` now creates a session-scoped Host identity; later app coordination may remember only allowed local preferences | Preserve the shared form and validated value. Never persist session identity, room state, credentials, or listening data. |
| Permission explainers | Production `HostMusicAccessView` maps typed Host eligibility state; Join mock explainer remains inert | `AppleMusicHostEligibilityChecker` requests Music access and verifies host playback capability only after explicit action | Preserve protocol injection, lifecycle-owned async work, typed recovery, and Settings/check-again actions. Guest permission behavior remains blocked on its owning slice. |
| Host lobby | `HostLobbyPresentation` mapped from the canonical solo `HostSessionModel`; mock lobby remains for admission/invite states | Host coordinator now starts alone; Slice 3 later extends canonical participants/admission through transport | Preserve immutable order and Main Actor ownership. Do not promote mock invites or admission scenarios. |
| Guest discovery/admission | `MockLobbyScenario` transitions | `SessionTransport` discovery plus revisioned admission state | Replace scenario mutation with read-only presentation state and typed coordinator commands. Do not encode or simulate transport behavior in views. |
| Invite | Decorative SF Symbol QR and `"BEAT"` | Session ID plus high-entropy join secret encoded by the production invite service; short room code remains only a local discovery filter | Replace the placeholder image with a generated invite artifact. Never log, persist, or expose the reusable secret through accessibility text or screenshots. |
| Joined queue | `MockJoinedQueueView` owns scenario/sheet state; `MockJoinedQueuePresentationView` and the functional harness both receive `QueueSessionPresentation` | `HostSessionModel` already maps authoritative local state; a future guest mirror maps revisioned canonical snapshots into the same presentation model | Preserve the shared immutable presentation and visual components. Replace only gallery/harness ownership with Slice 2B host coordination or a later guest mirror; views never run fairness logic. |
| Add Music and search | Production `HostCatalogSearchModel`, state, result rows, and typed outcomes alongside isolated `MockSearchScenario`, fixtures, and galleries | Host uses `AppleMusicHostCatalogService`; a later guest coordinator uses its separately gated catalog/transport boundary | Preserve production-neutral views and typed states. Host search already injects search, retry, submit, dismiss, and close behavior without MusicKit in SwiftUI; guest acknowledgement and cross-storefront peer validation remain open. |
| Lifecycle banners | Mock scenarios such as reconnecting | Revisioned session lifecycle presentation | Map transport/playback outcomes into explicit display states. Views do not own timers, reconnection, teardown, or playback transitions. |
| Lifecycle gallery | `MockLifecycleScenario` plus static countdown/progress fixtures | Host/guest lifecycle state mapped from transport, playback, grace-period clock, and teardown coordinators | Preserve the status views and replace scenario selection with canonical state. Production owns timers and cancellation; disappearance of the screen must not cancel or duplicate authoritative teardown. |

### Intended production data flow

```text
MusicKit / SessionTransport / playback events
                    │
                    ▼
       authoritative host actor or guest mirror
                    │
          maps canonical state to
                    ▼
       immutable presentation values for views
                    │
          user emits typed intent/command
                    ▼
 coordinator / host validation / domain scheduler
```

Views may keep short-lived interaction state such as sheet presentation, text
focus, and selected gallery scenario. They must not become authoritative owners
of participants, queue order, admission, playback, or connection lifecycle.

## Production integration sequence

Do not connect the mock flow end to end merely because its screens exist. Wire it
incrementally as the canonical build plan opens the necessary production slices:

1. Preserve the completed Slice 2A owner, command, presentation, and test
   boundaries while keeping P0–P6 galleries isolated.
2. Continue with Slice 2B under 0M: connect first-run Host navigation, permission
   and subscription state, a single-device lobby, catalog search, and playback
   around the existing canonical queue owner.
3. Keep production-neutral presentation values beside real callers; do not
   promote mock coordinators, scenarios, or deterministic harness fixtures.
4. Connect lobby and admission views to the authoritative host actor or guest
   mirror through mapped presentation state and typed commands.
5. Connect the joined queue to canonical snapshots; keep the fairness scheduler
   and queue mutation entirely outside SwiftUI.
6. Connect search through a cancellable MusicKit boundary and submit commands
   through host validation with typed acknowledgements and rejections.
7. Connect lifecycle presentation only after transport, playback, cancellation,
   and teardown ownership are established.
8. Run the full build, fairness tests for any queue-affecting integration, relevant
   unit/UI tests, accessibility previews, and required physical-device checks.
9. Remove or compile-gate gallery routes and delete fixtures that no longer serve
   previews or tests.

The detailed seam audit and gate-aware hardening backlog live in
[`UI_PRODUCTION_READINESS.md`](UI_PRODUCTION_READINESS.md). Keep it synchronized
with material changes to presentation inputs, intents, or readiness findings.

## Mock retirement criteria

The provisional UI track is ready to retire only when:

- every production screen receives canonical mapped presentation state;
- every enabled action emits a typed production intent with a defined owner,
  validation path, error state, and cancellation behavior;
- no view imports MusicKit or Network merely to obtain its display state;
- no mock scheduler, transport, player, credential, or persistent session store
  exists;
- host and guest state converge through the specified authoritative protocol;
- all fairness and privacy invariants remain enforced below the UI;
- mock-only navigation is removed from release builds or explicitly debug-scoped;
- obsolete fixtures are deleted, while useful deterministic preview fixtures may
  remain clearly named and isolated; and
- canonical build-plan gates and physical-device checks—not mock behavior—provide
  completion evidence.

## Non-negotiable isolation rules

- Do not import MusicKit or Network into provisional UI.
- Do not request real permissions or start discovery from mock flows.
- Do not create a second fairness scheduler or mutate `RotationState` from views.
- Do not let mock state become session authority.
- Treat supplied queue order as canonical and immutable.
- Do not add drag handles, arbitrary reordering, guest playback controls, or
  cross-participant removal.
- Keep fixture state in memory and never persist session or listening data.
- Preserve the existing feasibility controls and physical-device paths.
- Use localized strings, VoiceOver labels, Dynamic Type, contrast, and identity
  that does not rely on color.
- One primary type per Swift file; use modern SwiftUI and Observation conventions
  from `AGENTS.md`.

## Design direction

The Mobbin research established the structural reference, not a visual clone:

- [Spotify Jam queue](https://mobbin.com/screens/438ac8ae-b4cc-4c9e-bfe1-d01c2dd67089):
  session identity, participant attribution, Add Music, and queue hierarchy.
- [Spotify active Jam](https://mobbin.com/screens/ba157542-473b-4841-a29a-722fde6c325d):
  now-playing emphasis and focused session surface.
- [Spotify invite sheet](https://mobbin.com/screens/4301c467-4eeb-4254-a23a-1809d4ac8c6e):
  invitation separated from queue management.
- [Spotify adding songs to a Jam](https://mobbin.com/flows/4eab6760-3773-4a13-b0c6-21ec82581fd7):
  focused search sheet and immediate submission feedback.

Jamsession must diverge wherever those references conflict with locked fair order,
typed rejection feedback, participant ownership, accessibility, or the host-only
playback model.

## Recommended continuation order

### Next: connected accessibility pass, not production integration

The production-readiness review is recorded in
[`UI_PRODUCTION_READINESS.md`](UI_PRODUCTION_READINESS.md). It confirms that
Slice 0 remains closed while its named hardware/account checks are incomplete.
Do not treat the completed gallery as authorization to integrate MusicKit,
Network transport, playback, or session lifecycle.

R1–R6 are complete. Profile completion passes an explicitly nonisolated,
validated `ProfileDraft`; the joined queue has an immutable leaf presentation;
fixture identities are stable across galleries; eventual user intents are
inventoried; focused pure tests protect presentation mapping; and mock navigation
is excluded from Release builds. The connected Host and Join fixture paths now
have passing debug-only UI smoke coverage.

Safe continuation work includes:

- running the connected Host and Join paths at AX5 Dynamic Type in dark
  appearance, checking control hitability, keyboard avoidance, copy expansion,
  and sheet dismissal;
- applying further leaf extraction only when a concrete caller or testing benefit
  warrants it;
- reviewing new presentation inputs and intent closures against
  `UI_INTENT_INVENTORY.md`;
- resolving accessibility or localization defects found during manual review;
- continuing explicitly authorized pure-domain work; and
- preparing an integration checklist tied to canonical gates without implementing
  blocked production dependencies.

## Verification baseline

Through 2026-07-24:

- The Xcode project built successfully with no build errors.
- Xcode Issue Navigator reported no warnings.
- The populated queue rendered at default Dynamic Type in light appearance.
- The queue rendered at AX5 Dynamic Type in dark appearance; the session header
  was changed to stack responsively.
- The first-run entry rendered at default Dynamic Type in light appearance and at
  AX5 Dynamic Type in dark appearance.
- The host profile form rendered at AX5 Dynamic Type in dark appearance and
  remained vertically scrollable.
- The host lobby rendered at default Dynamic Type in light appearance.
- The approval request rendered at AX5 Dynamic Type in dark appearance after its
  explanatory copy was made vertically expanding and scrollable.
- The connected full-flow entry rendered at default Dynamic Type in light
  appearance and AX5 Dynamic Type in dark appearance.
- The search results rendered at default Dynamic Type in light appearance.
- Pending-limit submission feedback rendered at AX5 Dynamic Type in dark
  appearance after switching to an accessibility-specific vertical layout.
- The participant-gone lifecycle gallery rendered at default Dynamic Type in
  light appearance.
- Host-loss rendered at AX5 Dynamic Type in dark appearance inside a scrollable
  surface.
- The Reduce Motion fixture rendered with its explicit deterministic override,
  while the normal gallery reads the system accessibility environment.
- The localization-expansion fixture rendered with deliberately long English
  labels and supporting copy.
- The profile form rendered at default Dynamic Type after its completion seam was
  changed to emit the complete validated `ProfileDraft`.
- Five focused `ProfileDraftValidatorTests` passed on an iPhone 14 Pro simulator.
- The R3–R5 focused suite passed on the iPhone 14 Pro iOS 26.5 simulator: three
  fixture-identity tests, one scenario-completeness test, and one exhaustive
  feedback-presentation test.
- The string catalog parsed as JSON and `git diff --check` passed.
- No launch-random `UUID()` calls remain under `Jamsession/Features`.
- A boundary search found no MusicKit, Network, `FairnessScheduler`, or
  `RotationState` references in the provisional UI.
- Xcode now discovers 55 enabled tests: 50 unit tests and five UI tests. All 50
  unit tests and both connected-flow UI tests are claimed as passing; the three
  template UI tests were not run in the final focused verification.
- The post-R5 feedback preview request timed out in Xcode; no new visual result is
  claimed for that request. Earlier P5 feedback previews remain the visual
  baseline.
- Before R2/R6 changes, the complete `JamsessionTests` unit-test target passed on
  the iPhone 14 Pro iOS 26.5 simulator.
- After R2/R6 changes, all 50 tests in the complete `JamsessionTests` target
  passed on the same simulator, including the new queue-scenario presentation
  mapping test.
- The active Debug build and a generic Release iOS Simulator build both
  succeeded. The Release source path excludes every mock route button and
  `FeasibilityDestination`.
- The extracted joined-queue leaf rendered at default Dynamic Type in light
  appearance with the populated fixture; its hierarchy and Add Music affordance
  remained intact.
- Xcode Issue Navigator reported no warnings after the final build.
- Both `MockConnectedFlowUITests` passed on the iPhone 14 Pro iOS 26.5 simulator:
  Host and Join each reached the queue, opened and dismissed Add Music, and
  restarted to role selection. The Join path also exercised simulated approval.
- A review-follow-up build succeeded with no Issue Navigator warnings. Two
  focused lobby-row accessibility tests passed, proving positioned and
  unpositioned rows announce localized role or admission status. The focused
  connected Host lifecycle test passed through Session Ended → Return Home, and
  the separate toolbar Restart regression test also passed.
- Xcode discovers 58 enabled tests after the review follow-up: 52 unit tests and
  six UI tests. Only the four focused new or affected tests were rerun on
  2026-07-24; the prior complete 50-unit-test result remains the full-suite
  baseline.
- The maximum-capacity participant header has a deterministic eight-person
  fixture. Its badge strip scrolls horizontally while the participant count
  remains pinned and visible. The full-session header rendered successfully at
  default Dynamic Type in light appearance and AX5 in dark appearance.
- Xcode discovers 59 enabled tests after adding the capacity fixture assertion.
  The project built successfully before both previews. The focused test runner
  was cancelled once and then timed out, so no pass is claimed for the new
  capacity assertion.
- Queue rows now use a stacked metadata layout at accessibility Dynamic Type
  sizes, and track titles are no longer constrained to one line at standard
  sizes. A deterministic long-title fixture rendered successfully at standard
  Dynamic Type in light appearance and AX5 in dark appearance with the complete
  title visible.
- An isolated Debug simulator build and build-for-testing both succeeded after
  the queue-row change, compiling the app, unit-test, and UI-test targets. Issue
  Navigator reported no warnings. The focused fixture test was cancelled by the
  active Xcode test runner, so no new test-execution pass is claimed.
- The lifecycle `participantGone` fixture now represents the post-grace
  tombstone state: pending songs are removed, the locked rotation position is
  reserved, and returning does not restore removed songs.
- Now Playing and Search use accessibility-size stacked layouts for long catalog
  metadata. A shared explicit badge exposes the full “Explicit” accessibility
  label in queue, search, and Now Playing presentations.
- The corrected gone fixture rendered at standard Dynamic Type in light
  appearance. Long explicit Now Playing and Search fixtures rendered at AX5 in
  dark appearance with complete titles and artists visible.
- Xcode discovers 62 enabled tests: 56 unit tests and six UI tests. All 56 unit
  tests passed on the iPhone 14 Pro iOS 26.5 simulator after the final review
  fixes, including post-grace lifecycle semantics, explicit Now Playing
  accessibility, full-session capacity, and shared long-track fixture identity.
- The permission explainer uses a scrollable sheet body so expanded title,
  description, fixture notice, and action remain reachable at accessibility
  sizes. Its Host path passed a focused UI test at accessibility XXXL, and the
  AX5 dark preview rendered successfully.
- The invite presentation uses a scrollable sheet body so its decorative QR,
  expanded title and description, room code, and fixture notice remain reachable
  at accessibility sizes. Its connected Host path passed a focused UI test at
  accessibility XXXL, and the AX5 dark preview rendered successfully in portrait
  and landscape.
- The localized participant count now uses singular and plural variations. A
  deterministic solo fixture and the full eight-person fixture assert “1 person”
  and “8 people” respectively.
- Xcode discovers 65 enabled tests: 57 unit tests and eight UI tests. All 57 unit
  tests and the focused invite-sheet accessibility UI test passed on the
  iPhone 14 Pro iOS 26.5 simulator. The project built successfully, Issue
  Navigator reported no warnings, the string catalog parsed, and
  `git diff --check` passed.
- The Music-access-denied search fixture now emits a dedicated app-Settings
  recovery intent. It no longer reuses transient catalog retry, and the mock
  route still does not request authorization or call MusicKit.
- Submission feedback is presented in a bottom safe-area inset so it remains
  visible after adding any result, including the final long-title fixture, and
  accessibility focus moves to the new feedback.
- The denied-access and submission-feedback previews rendered at AX5 Dynamic
  Type in dark appearance with complete content. Both focused connected Join UI
  regressions passed on the iPhone 14 Pro iOS 26.5 simulator, including a
  submission from the lowest result, and all 57 unit tests passed.
- Xcode discovers 67 enabled tests: 57 unit tests and ten UI tests. The project
  built successfully, Issue Navigator reported no warnings, the string catalog
  parsed, the provisional search boundary remained free of MusicKit, Network,
  fairness, and session-authority dependencies, and `git diff --check` passed.
- The submission-feedback card is an accessibility container rather than one
  combined element, keeping its xmark available as a separate dismiss control
  after focus moves to the feedback. The connected Join regression submitted the
  final result, dismissed the visible feedback through that control, and verified
  the bottom inset disappeared.
- After the dismissal follow-up, the focused UI regression and all 57 unit tests
  passed on the iPhone 14 Pro iOS 26.5 simulator. The project built, the AX5 dark
  feedback preview rendered without visual regression, Xcode reported no
  warnings, the string catalog parsed, and `git diff --check` passed.
- Slice 2A added nine unit tests and one focused UI test. All 66 unit tests and
  `DomainQueueHarnessUITests.testQueueActionsUseCanonicalFairnessState` passed on
  the iPhone 14 Pro iOS 26.5 simulator. Debug and generic Release simulator
  builds succeeded; standard light and AX5 dark functional-queue previews
  rendered; Issue Navigator reported no warnings; the string catalog parsed; and
  `git diff --check` passed. These checks prove only the domain-backed local
  queue path and do not claim MusicKit, playback, Network, or physical-device
  behavior.
- Slice 2B-A added eight unit cases and two focused UI flows. All 74 unit tests
  passed. One UI flow stopped at the just-in-time Music explanation without
  requesting permission; the other used a Debug-only eligible checker to reach
  the solo lobby, start, and canonical empty queue. Standard and AX5 lobby
  screenshots were inspected; the AX5 row was corrected to stack and the
  rerun passed. Debug and Release simulator builds succeeded. No real Music
  authorization, subscription, catalog, playback, Network, or physical-device
  pass is claimed.
- Slice 2B-B added eleven unit cases and extended the Host UI flow through search,
  fresh resolution, canonical fairness submission, and updated queue
  presentation. All 85 unit tests passed, including the complete fairness suite.
  Both Host UI tests, the functional queue regression, and all mock connected
  regressions passed on the iPhone 17 Pro iOS 26.5 simulator. The AX5
  search/feedback screenshot was inspected; an initially hidden navigation Done
  item was replaced by a persistent accessible safe-area control, and the
  corrected run passed. Debug and generic Release simulator builds, the
  string-catalog parse, and whitespace/boundary checks passed. Live Apple Music
  search, storefront data, playability resolution, playback, Network, and
  physical-device behavior were not exercised and remain open.
- The PR #4 review follow-up added role-specific solo-lobby accessibility
  coverage and kept queue-command feedback visible and dismissible while the
  Debug functional catalog sheet is presented. The focused catalog UI regression,
  all 87 unit tests, and Debug and Release simulator builds passed. Live MusicKit
  denial/recovery and all previously listed physical-device work remain open.
- A second PR #4 review follow-up bound turn-skip commands to the displayed
  submission identity and added a stale-action regression that proves a
  replacement next track is not skipped. Queue feedback now exposes a combined
  VoiceOver summary and requests accessibility focus whenever the outcome appears
  or changes. The focused model/UI regressions, all 88 unit tests, and Debug and
  Release simulator builds passed. Manual VoiceOver focus confirmation, live
  MusicKit denial/recovery, and the previously listed physical-device work remain
  open.
- A third PR #4 review follow-up replaced the Host eligibility generation counter
  with an optional request identity owned by `.task(id:)`. Returning to profile
  clears the identity and cancels the in-flight checker; a cancellation probe
  confirmed the underlying work receives cancellation and the UI returns to a
  non-loading state. Both Host UI flows, all 88 unit tests, and Debug and Release
  simulator builds passed. Whether an already-presented system Music authorization
  sheet can be withdrawn remains a physical-device verification gap.

Record each later provisional slice in `VERIFICATION_LOG.md`, including exact
preview variants and any fixture-only behavior.

## Fresh-context starting prompt

Use this prompt in a new context:

> Continue with Slice 2B-C, Host playback and queue reconciliation. The P0–P6
> presentation track, R1–R6 hardening backlog, connected mock-flow smoke
> coverage, Slice 2A domain-backed functional queue, Slice 2B-A Host
> profile/Music-eligibility/solo-lobby, and Slice 2B-B Host catalog/search
> increments are complete.
> Read `AGENTS.md`,
> `docs/PRODUCT_DECISIONS.md`, `docs/BUILD_PLAN.md`,
> `docs/VERIFICATION_LOG.md`, `docs/UI_PRODUCTION_READINESS.md`, and this handoff
> before acting. Preserve `HostSessionModel` as the Main Actor authority,
> `FairnessScheduler` as a pure value type, and `QueueSessionPresentation` as the
> SwiftUI boundary. Under gate 0M, add a Main Actor Host player around
> `ApplicationMusicPlayer.shared`, a pure queue-diff reconciliation planner, and
> a thin MusicKit executor that preserves the current track and surfaces typed
> failure state. Add deterministic planner/failure tests before beginning
> playback-transition observation. Do not begin guest catalog or nearby transport
> work while 0G and 0N remain closed. Record only checks actually run and keep
> the readiness review, intent inventory, verification log, and handoff current.
