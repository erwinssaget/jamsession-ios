# UI Intent Inventory

Last reviewed: 2026-07-23

## Purpose

This inventory defines the user intents exposed by the completed mock UI without
implementing production coordinators, transport messages, MusicKit requests,
playback commands, or session lifecycle.

Names are conceptual until a canonical production caller exists. When production
types are introduced, preserve the ownership, validation, repetition, and
cancellation expectations recorded here rather than copying the mock coordinator.

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

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `selectRole` | Host or Join | App flow coordinator | Role must remain changeable until a permission/session action begins. | Re-selecting replaces the uncommitted choice. Back returns to role selection. |
| `submitProfile` | Validated `ProfileDraft` | App flow coordinator | Draft is already normalized locally; production creates or updates allowed local profile preference separately from session identity. | Repeated submission while advancing is ignored or disabled. Cancellation preserves only explicitly allowed local preferences. |
| `cancelFirstRunStep` | Current step | App flow coordinator | No service mutation. | Idempotent; returns to the prior presentation step. |
| `continuePermissionExplanation` | Role | Host or Join coordinator | Begins the role-specific production permission flow only when its canonical slice is open. | One owned task; repeated taps do not start duplicate requests. Cancellation maps back to an actionable explanation state. |

## Host lobby and admission

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

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `openAddMusic` | None | App/queue coordinator | Presentation-only navigation. Guest may open search even before Music authorization is known. | Repeated presentation is coalesced. Dismissal cancels owned search work. |
| `removeOwnPendingTrack` | Submission ID and current revision | Authoritative host actor | Participant owns the pending submission and it has not started. Returns typed fairness rejection when invalid. | Idempotent request ID; replay returns original outcome. |
| `skipOwnNextTurn` | Participant ID and current revision | Authoritative host actor | Participant owns `nextUp`; track remains pending and skip semantics are applied once. | Idempotent; repeat cannot skip multiple turns. |
| `openLifecycleDetails` | Current lifecycle presentation | App/queue coordinator | Presentation-only navigation; does not start timers or reconnection. | Repeated presentation is coalesced. |

Host-only moderation and playback controls are intentionally absent from the
current joined-guest mock queue. Add them only in the correct host production
surface with explicit authorization.

## Search and submission

| Conceptual intent | Payload | Production owner | Validation and result | Repeat/cancel behavior |
|-------------------|---------|------------------|-----------------------|------------------------|
| `updateSearchQuery` | Normalized query and generation | Search coordinator | Non-empty query; Music authorization handled by coordinator; catalog response maps to current generation only. | Debounced. New input cancels the previous request and suppresses stale results. |
| `retrySearch` | Query and new generation | Search coordinator | Same validation as search. | Starts one new request; repeated taps are disabled/coalesced while loading. |
| `submitTrack` | Music item ID, participant ID, request ID, host revision | Host-local coordinator or guest command boundary | Host resolves item in its storefront, then applies fairness validation. Maps to pending, accepted, or typed rejection presentation. | Idempotent request ID. Repeated taps do not create duplicate pending commands. |
| `dismissSubmissionFeedback` | Feedback/request ID | Search coordinator | Presentation-only dismissal; does not cancel an accepted host mutation. | Idempotent. A newer outcome may supersede dismissed feedback. |
| `cancelSearch` | Active generation and pending local tasks | Search coordinator | Cancels catalog work and closes presentation. Does not retract already-sent submission commands. | Idempotent and lifecycle-owned. |

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
