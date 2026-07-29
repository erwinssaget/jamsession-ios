# UI Intent Inventory

Last reviewed: 2026-07-28

## Purpose

This inventory defines the user intents exposed by the UI and records which
queue intents gained a canonical local owner in Slice 2A, which Host setup
intents gained a production owner in Slice 2B-A, and which Host catalog/search
intents gained a production owner in Slice 2B-B. Slice 2B-C gives Host queue
reconciliation and retry a production owner. Slice 2B-D gives Host playback
observation, current-track presentation, play/pause, and current-track skip a
production owner. Transport messages, guest catalog requests, production entry,
and session lifecycle remain unimplemented.

Names remain conceptual until a canonical production caller exists. Slice 2A's
implemented names are called out below. Later production types must preserve the
ownership, validation, repetition, and cancellation expectations recorded here
rather than copying a mock coordinator.

## Intent rules

- A view emits an intent; it does not decide whether the action is authorized.
- The named production owner validates the intent and maps the result back into
  immutable presentation state.
- Commands that can cross a peer boundary require an idempotent request identity.
- Repeated taps, retries, stale responses, and cancellation have explicit
  outcomes.
- Queue order, admission, playback, and lifecycle never become view-owned state.
- User-facing failures map from typed domain/service outcomes; views do not parse
  error strings.

## First run

Slice 2B-A implements Host `submitProfile` and
`continuePermissionExplanation` through `HostFlowCoordinator`. The async
`HostMusicEligibilityChecking` boundary requests access only after explicit user
action, suppresses cancelled/stale outcomes, and maps eligible, denied,
restricted, subscription-required, and unavailable results into typed
presentation state. Production role-choice navigation and the Join permission
path remain open.

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `selectRole` | Host or Join | App flow coordinator | Role must remain changeable until a permission/session action begins. | Re-selecting replaces the uncommitted choice. Back returns to role selection. |
| `submitProfile` | Validated `ProfileDraft` | App flow coordinator | Draft is already normalized locally; production creates or updates allowed local profile preference separately from session identity. | Repeated submission while advancing is ignored or disabled. Cancellation preserves only explicitly allowed local preferences. |
| `cancelFirstRunStep` | Current step | App flow coordinator | No service mutation. | Idempotent; returns to the prior presentation step. |
| `continuePermissionExplanation` | Role | Host or Join coordinator | Begins the role-specific production permission flow only when its canonical slice is open. | One owned task; repeated taps do not start duplicate requests. Cancellation maps back to an actionable explanation state. |
| `retryHostMusicEligibility` | Current Host profile and a new lifecycle-owned request generation | Host flow coordinator / Music eligibility boundary | Rechecks authorization and subscription capability after Settings, subscription changes, or transient failure. | A newer generation cancels/supersedes the old task; stale or cancelled results cannot create a lobby. |

## Host lobby and admission

Slice 2B-A implements the solo form of `startSession`: an eligible Host owns one
ephemeral `HostSessionModel`, the immutable lobby reflects its locked one-person
order, and repeated start calls after leaving the lobby are stable no-ops.
Admission, invite, capacity, and revisioned peer commands remain Slice 3 work.

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `showInvite` | Session identifier | Host coordinator | Produces a shareable invite artifact without exposing the high-entropy secret in logs or accessibility output. | Repeated presentation reuses or safely regenerates current invite state. Dismissal has no session effect. |
| `startSession` | Current host revision | Authoritative host actor | Host is active, capacity/order state is valid, and the command applies once. Locks order and emits a canonical snapshot. | Duplicate start is idempotent. Cancellation is allowed before application only. |
| `approveAdmission` | Admission request ID | Authoritative host actor | Request is pending, participant is not blocked, capacity is available, and credentials are valid. | Replayed approval returns original outcome without duplicating participant state. |
| `rejectAdmission` | Admission request ID | Authoritative host actor | Request is pending and host is authorized. | Replayed rejection returns original outcome. No participant state is created. |
| `retryDiscovery` | Discovery generation | Guest coordinator / transport boundary | Local-network readiness is known before browsing. Starts a new owned discovery generation. | Cancels the prior browse generation; stale results cannot replace newer results. |
| `requestJoin` | Discovered session ID plus admission proof | Guest coordinator / host validation | Discovery result is current; room code alone never bypasses approval; QR secret may. | One pending request per session/request ID. Cancellation clears local pending UI but cannot retract an already applied host decision. |
| `cancelJoinRequest` | Request ID | Guest coordinator | Clears local waiting state; host acknowledgement may still arrive and must be reconciled by canonical revision. | Idempotent. Late results are ignored unless canonical session state proves admission. |

## Joined queue

Slice 2A implements `removeOwnPendingTrack`, `skipOwnNextTurn`, and host
`advancePlayback` through idempotent `QueueCommand` values owned by the Main Actor
`HostSessionModel`. The participant identity on a command is trusted local
context; a future transport boundary must authenticate and validate a peer before
constructing that command. `openAddMusic` remains presentation navigation.
Slice 2B-C automatically reconciles canonical queue identity changes through
`HostPlayer`. Slice 2B-D observes player transitions through that same boundary
and converts each start or departure into one idempotent canonical
`advancePlayback` command.

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `openAddMusic` | None | App/queue coordinator | Presentation-only navigation. Guest may open search even before Music authorization is known. | Repeated presentation is coalesced. Dismissal cancels owned search work. |
| `removeOwnPendingTrack` | Submission ID and current revision | Authoritative host actor | Participant owns the pending submission and it has not started. Returns typed fairness rejection when invalid. | Idempotent request ID; replay returns original outcome. |
| `skipOwnNextTurn` | Participant ID and current revision | Authoritative host actor | Participant owns `nextUp`; track remains pending and skip semantics are applied once. | Idempotent; repeat cannot skip multiple turns. |
| `advancePlayback` | Host identity and stable player-transition request ID | Authoritative host actor | Host authorization is required; the scheduler advances canonical rotation exactly once. Slice 2B-D emits this only after a managed player start or departure matches the canonical current/next identity. | The pure transition deduplicator and authoritative command replay cache share a stable transition identity; repeated callbacks cannot advance twice. |
| `retryQueueReconciliation` | Current canonical playback queue identities and a new attempt ID | Main Actor Host player | Replans from a fresh player snapshot. A protected current entry cannot be removed or replaced; failure pauses playback and returns typed recovery state. | A new lifecycle-owned `.task(id:)` supersedes the prior attempt. Stale completion cannot replace newer state. |
| `playHostPlayback` | Current managed player item and lifecycle-owned control request | Main Actor Host player / Music executor | The real executor rechecks authorization and subscription before calling the app-owned player. Typed failure pauses and returns actionable recovery state. | The view disables/coalesces overlapping controls; cancellation reaches the executor and does not publish a false failure. |
| `pauseHostPlayback` | Current managed player item | Main Actor Host player / Music executor | Host-only and synchronous at the player boundary. Pausing does not mutate canonical fairness state. | Repeated pause is stable; the control is ignored while another control request is in flight. |
| `skipCurrentHostTrack` | Current canonical submission identity plus lifecycle-owned control request | Main Actor Host player / Music executor | The control is enabled only for the canonical current track. Fairness advances from the resulting managed player departure, never directly from the button tap. | Overlapping taps are disabled/coalesced; repeated or duplicated departure callbacks reuse one stable canonical command identity. |
| `openLifecycleDetails` | Current lifecycle presentation | App/queue coordinator | Presentation-only navigation; does not start timers or reconnection. | Repeated presentation is coalesced. |

Host-only moderation and playback controls remain absent from the joined-guest
mock queue. The Debug functional harness exposes authorized host controls solely
to exercise the Slice 2A command boundary. Slice 2B-C connects queue
reconciliation and retry. Slice 2B-D adds Host-only playback controls to the
production Host queue surface through `HostPlayer`; guest controls and
end-session behavior remain absent.

## Search and submission

Slice 2B-B implements the Host-local forms of `updateSearchQuery`,
`retrySearch`, `submitTrack`, `dismissSubmissionFeedback`, and `cancelSearch`.
`HostCatalogSearchModel` is Main Actor isolated, owns request identities and
typed states, and is driven by lifecycle-owned SwiftUI tasks.
`AppleMusicHostCatalogService` resolves the current country storefront, maps
`Song` into `CatalogTrackSelection`, and re-fetches a selected ID before the
authoritative command is constructed. Guest search and remote acknowledgement
remain Slice 4 work.

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `updateSearchQuery` | Normalized query and generation | Search coordinator | Non-empty query; Music authorization handled by coordinator; catalog response maps to current generation only. | Debounced. New input cancels the previous request and suppresses stale results. |
| `retrySearch` | Query and new generation | Search coordinator | Same validation as search. | Starts one new request; repeated taps are disabled/coalesced while loading. |
| `submitTrack` | Music item ID, participant ID, request ID, host revision | Host-local coordinator or guest command boundary | Host resolves item in its storefront, then applies fairness validation. Maps to pending, accepted, or typed rejection presentation. | Idempotent request ID. Repeated taps do not create duplicate pending commands. |
| `dismissSubmissionFeedback` | Feedback/request ID | Search coordinator | Presentation-only dismissal; does not cancel an accepted host mutation. | Idempotent. A newer outcome may supersede dismissed feedback. |
| `cancelSearch` | Active generation and pending local tasks | Search coordinator | Cancels catalog work and closes presentation. Does not retract already-sent submission commands. | Idempotent and lifecycle-owned. |

Slice 2A implements the post-resolution command portion of `submitTrack`.
Slice 2B-B now supplies the Host-local MusicKit lookup, storefront validation,
debounce, cancellation, stale-response suppression, and typed catalog/fairness
feedback before a trusted `CatalogTrackSelection` reaches `HostSessionModel`.
Guest authorization, cross-storefront peer submission, transport identity and
revision validation, and acknowledgement remain Slice 4 work.

## Session lifecycle

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `retryGuestConnection` | Session ID, reconnect credential, generation | Guest transport coordinator | Credential belongs to current participant and grace has not definitively expired. | One owned connection attempt; a newer generation cancels/supersedes older work. |
| `acknowledgeRemoval` | Terminal participant/session state | App/session coordinator | Canonical snapshot proves removal. Clears live mirrored state. | Idempotent; removal is terminal for that identity. |
| `acknowledgeTrackFailure` | Failure event/revision | Host/guest presentation coordinator | Canonical revision proves the failure was applied once. | Presentation acknowledgement never advances fairness a second time. |
| `cancelHostLossWait` | None | Not supported for guests | Guests cannot override host-loss grace or promote themselves. | No UI intent should be exposed. |
| `confirmEndSession` | Host session ID and revision | Authoritative host actor | Host authorization and confirmation required while playback is active. Stops/clears player, notifies guests, then destroys live state. | Idempotent transition; repeated confirmation cannot duplicate teardown. |
| `cancelEndSession` | Pending confirmation only | Host coordinator | Valid only before teardown begins. | Idempotent; once ending starts it cannot restore destroyed state. |
| `returnHomeAfterEnd` | Terminal session ID | App/session coordinator | Live state is already destroyed. | Idempotent navigation; must not recreate the ended session. |

## Mock-only controls with no production equivalent

- Preview-state pickers in queue, lobby, search, and lifecycle galleries.
- `Simulate Host Approval`.
- Connected-flow `Restart`.
- Decorative QR placeholder.
- Static host-loss countdown and ending progress.
- Manual selection of submission feedback outcomes.

These controls must remain debug/previews-only and must not be translated into
production intents.

The feasibility-harness buttons and navigation destinations that expose these
controls are guarded by `DEBUG`. The mock views remain available to previews and
tests, but release navigation has no route to them.

## Introduction checklist for a typed intent

Before adding a production intent type:

1. Name its owner and actor isolation.
2. Define the immutable payload and exclude display-only strings.
3. Identify authorization and canonical revision requirements.
4. Define idempotency/request identity if it can mutate or cross a peer boundary.
5. Specify accepted, rejected, cancellation, stale, and replay outcomes.
6. Map outcomes to presentation values without importing service frameworks into
   leaf views.
7. Add success, boundary, failure, cancellation, and repeated-operation tests.
8. Update `UI_PRODUCTION_READINESS.md` and `UI_PROTOTYPE_HANDOFF.md`.
