# Provisional UI Prototype — Continuation Handoff

Last updated: 2026-07-23

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

The provisional track is intentionally isolated from production session logic.

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
  Session Ended → Return Home through the lifecycle gallery.

“Complete” above means complete only for provisional design exploration. It does
not satisfy or open a canonical Slice 4 gate.

## Implementation map

| Area | Location | Responsibility |
|------|----------|----------------|
| Mock entry route | `Jamsession/ContentView.swift` and `Jamsession/FeasibilityDestination.swift` | Keeps the prototype reachable in Debug without replacing Slice 0 tools; no Release navigation route is compiled |
| First-run prototype | `Jamsession/Features/FirstRun/` | Host/Join choice, identity setup, validation, and inert permission explanation |
| Lobby prototype | `Jamsession/Features/Lobby/` | Host participant order, admission state gallery, discovery fixtures, and decorative invite |
| Connected walkthrough | `Jamsession/Features/Prototype/` | Fixture-only navigation state joining first run, lobby/discovery, approval, and joined queue |
| Search prototype | `Jamsession/Features/Search/` | Catalog-state fixtures, result rows, and typed submission feedback presentation |
| Lifecycle prototype | `Jamsession/Features/Lifecycle/` | Departure, failure, host-loss, teardown, Reduce Motion, and expanded-copy fixtures |
| Joined-session gallery | `Jamsession/MockJoinedQueueView.swift` | Owns fixture scenario selection and Add Music sheet presentation |
| Joined-session leaf | `Jamsession/Features/Queue/MockJoinedQueuePresentationView.swift` | Renders immutable queue presentation and emits Add Music/Lifecycle intents |
| Presentation fixtures | `Jamsession/Features/MockSupport/`, `Jamsession/Features/Queue/Mock/`, and feature fixture files | Stable deterministic mock session, participant, track, and scenario values |
| Queue components | `Jamsession/Features/Queue/` | Participant badge, artwork, session header, now playing, and immutable queue rows |
| Intent inventory | `docs/UI_INTENT_INVENTORY.md` | Records eventual owners, payloads, validation/results, repetition, cancellation, and mock-only controls |
| Presentation tests | `JamsessionTests/MockUI/` | Protects stable fixture identity, feedback presentation mapping, and scenario-copy completeness |
| Connected UI smoke tests | `JamsessionUITests/MockConnectedFlowUITests.swift` | Exercises debug-only Host and Join fixture navigation without invoking services |
| User-facing copy | `Jamsession/Localizable.xcstrings` | Manual English localization keys for provisional UI |

The Xcode project uses synchronized groups, so new files under `Jamsession/` should
be discovered automatically. Verify target membership instead of reflexively
editing `project.pbxproj`.

## Current mock route graph

In Debug builds, all provisional routes begin in the existing Slice 0 feasibility
harness:

```text
ContentView
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

The route buttons and `FeasibilityDestination` are excluded when `DEBUG` is not
active. Mock views remain compiled for deterministic previews and tests but cannot
be reached from Release navigation.

## Production connection map

The mock UI is disposable presentation scaffolding. Production integration should
preserve useful views and replace fixture ownership at explicit seams:

| Prototype area | Fixture/state used now | Production source later | Integration action |
|----------------|------------------------|-------------------------|--------------------|
| Connected walkthrough | `MockPrototypeStep` and local sheet state | App-level host/join coordinators and typed navigation destinations | Replace the mock step switch with production coordinator state. Keep reusable screens driven by values and intent closures; do not preserve simulated approval as production behavior. |
| First-run role choice | `MockEntryRole` and local navigation state | App navigation plus host/join coordinators | Keep the visual choice surface; route actions into production permission and session flows only after their canonical slices open. |
| Profile setup | Local `@State` name, emoji, and color | Local non-session profile preferences plus session-scoped participant creation | Extract a validated profile value at the boundary. Remember only allowed profile preferences; never persist session identity, credentials, or listening data. |
| Permission explainers | `MockPermissionExplainerView` with inert completion | Music authorization/subscription flow for Host; local-network preparation for Join; guest Music authorization only when search opens | Replace the inert completion action with coordinator intents. Permission APIs and failure recovery stay outside reusable presentation views. |
| Host lobby | `MockLobbyFixtures.participants` | Authoritative host session presentation mapped from host-owned actor state | Supply locked participant order as immutable presentation input. Host commands perform start, approve, reject, remove, and block after validation. |
| Guest discovery/admission | `MockLobbyScenario` transitions | `SessionTransport` discovery plus revisioned admission state | Replace scenario mutation with read-only presentation state and typed coordinator commands. Do not encode or simulate transport behavior in views. |
| Invite | Decorative SF Symbol QR and `"BEAT"` | Session ID plus high-entropy join secret encoded by the production invite service; short room code remains only a local discovery filter | Replace the placeholder image with a generated invite artifact. Never log, persist, or expose the reusable secret through accessibility text or screenshots. |
| Joined queue | `MockJoinedQueueView` owns scenario/sheet state; `MockJoinedQueuePresentationView` receives `MockSessionPresentation` | Host authoritative state or guest canonical snapshot mapped into a shared queue presentation model | Replace the gallery owner with a production coordinator while retaining the leaf’s immutable input and Add Music/Lifecycle intent seams. Queue ordering remains immutable and views never run fairness logic. |
| Add Music and search | `MockSearchScenario`, `MockSearchFixtures`, and `MockSubmissionOutcome` | Cancellable MusicKit catalog search plus typed guest command acknowledgement or host-local validation result | Map external search state and typed submission outcomes into production-neutral presentation values. Inject search, retry, submit, and dismiss intents; never import MusicKit, transport, or fairness logic into queue/search views. |
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

1. Keep the completed P0–P6 galleries isolated and use the intent inventory when
   changing actions or production seams.
2. Define additional shared, production-neutral presentation values only when a production
   caller exists; do not prematurely rename mock fixtures into domain models.
3. Connect first-run navigation to real role coordinators while preserving the
   Slice 0 feasibility harness until its gate is complete.
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

Record each later provisional slice in `VERIFICATION_LOG.md`, including exact
preview variants and any fixture-only behavior.

## Fresh-context starting prompt

Use this prompt in a new context:

> Continue the provisional mock-driven UI track. The P0–P6 presentation track,
> R1–R6 hardening backlog, and connected-flow UI smoke coverage are complete.
> Read `AGENTS.md`,
> `docs/PRODUCT_DECISIONS.md`, `docs/BUILD_PLAN.md`,
> `docs/VERIFICATION_LOG.md`, `docs/UI_PRODUCTION_READINESS.md`, and this handoff
> before acting. Run a connected accessibility pass at AX5 Dynamic Type in dark
> appearance through the Host and Join mock paths, checking control hitability,
> keyboard avoidance, expanded copy, Add Music presentation, sheet dismissal, and
> restart. Do not integrate MusicKit, Network, playback, persistence, or session
> lifecycle while Slice 0 remains closed. Record only checks actually run, and
> keep the readiness review, intent inventory, verification log, and handoff
> current.
