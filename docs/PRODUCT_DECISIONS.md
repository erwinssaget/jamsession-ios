# Product Decisions — Ephemeral Shared-Queue Music Sessions

Last updated: 2026-07-18

## Authority

This is the canonical product decision record for the repository. It supersedes
the earlier `PRODUCT_DECISIONS.txt` drafts kept outside the repository. Future
agents must read this file and [`BUILD_PLAN.md`](BUILD_PLAN.md) before designing
or implementing product behavior.

When implementation and this document disagree, stop and resolve the discrepancy
instead of silently changing product behavior. Preserve material changes in the
decision history at the end of this file.

## Product definition

- Jamsession is an iPhone-first, native SwiftUI app for live, co-located Apple
  Music sessions.
- One host device owns authoritative session state and plays audio through
  `ApplicationMusicPlayer.shared`. The host needs an active Apple Music
  subscription.
- Guests are remote controls: they join locally, search the catalog, submit and
  remove their own pending tracks, and see a mirrored queue. They do not play
  audio.
- Sessions are ephemeral. Participant state, submissions, queue contents, and
  play history exist only in memory and are destroyed when the session ends.
- The MVP is free. It has no accounts, backend, chat, reactions, paywall, cloud
  history, remote sessions, or host migration.
- The MVP release target is a closed TestFlight, not yet a public App Store
  launch.

## Platform and transport

- Deployment target: iOS 26.0 or later. The project currently says 26.5; Slice 0
  must lower it to 26.0 unless an API requirement proves 26.5 necessary.
- Use the iOS 26 concurrency-native Network framework APIs:
  `NetworkListener`, `NetworkBrowser`, and `NetworkConnection`.
- Do not use deprecated MultipeerConnectivity or mix in callback-oriented
  `NWListener`/`NWBrowser`/`NWConnection` unless a verified capability gap is
  documented first.
- Topology is host-and-spoke. Each guest connects only to the host.
- Bonjour/local peer-to-peer discovery and transport live behind a
  `SessionTransport` protocol.
- Maximum capacity is eight devices total, including the host.
- Add the required local-network usage description and Bonjour service types via
  the project's generated Info.plist build settings.
- Networking is foreground-oriented in the MVP. Host background audio may
  continue, but session management requires the host to remain foregrounded.
  Guests reconnect when returning to the foreground.

## MusicKit and permissions

- Use MusicKit's automatic developer-token management after enabling the MusicKit
  capability. Never copy, inject, or bundle an `AuthKey_*.p8` private key.
- Do not request MusicKit or local-network permission at app launch.
- When the user chooses Host, explain why MusicKit is needed, request
  authorization, then verify subscription and playback capability.
- When the user chooses Join, explain local-network access before starting
  discovery. A guest needs MusicKit authorization only when opening catalog
  search; denied guests may still join and view the queue.
- The host re-resolves every submitted `MusicItemID` against the host's storefront
  and accepts it only when playable.
- Guest catalog search without a personal Apple Music subscription remains a
  physical-device feasibility gate. Do not claim it works until the test passes.
- The host is the only device that controls playback. Authorization or
  subscription loss pauses the session, produces a clear error, and offers a
  graceful end.

## Participant identity and admission

- A participant has a random on-device identifier and a session-scoped reconnect
  credential. Display name is never identity.
- Display name plus color and emoji represent the participant. Duplicate names are
  allowed. Color alone must never carry meaning.
- The app may remember name and avatar locally, but no session or listening data.
- The first screen offers **Host a Session** and **Join a Session**.
- The host creates a lobby, arranges the initial order, and explicitly starts the
  session. The host may start alone. Guests may pre-submit while in the lobby.
- The host is a full participant and follows the same rotation, pending cap, and
  duplicate rules as guests.
- The order locks at session start. Existing entries never move or disappear.
  Late joiners append to the tail and become eligible when the current rotation
  reaches them.
- A discovered join requires host approval. A QR code containing the session ID
  and a high-entropy join secret may bypass approval.
- A short room code only filters locally discovered sessions and still requires
  host approval. It is not a high-entropy credential and cannot locate a remote
  session without a backend.
- The host may reject, remove, or block a participant for the remainder of the
  session.

## Fairness model

The scheduler is a pure, synchronous, deterministic, `Sendable` value type with
no MusicKit, SwiftUI, transport, clock, or I/O dependency.

- Each participant owns a FIFO of pending tracks.
- The global queue is the round-robin interleave of those FIFOs in locked order,
  one track per eligible participant per round.
- Empty, reconnecting, gone, removed, or current-round-skipped participants are
  bypassed. Playback never waits on an empty turn.
- A submission may happen at any time and appends to the submitter's FIFO.
- `maxPendingPerParticipant` is 3. The currently playing track does not count.
- A track already pending anywhere in the session is rejected as a duplicate.
  Different `MusicItemID` values are distinct. A track may be submitted again
  after no pending copy remains.
- There is no submission cooldown in the MVP.
- Participants may remove only their own pending tracks. They may not reorder.
- The host may remove any pending track as an explicit moderation action.
- Explicit tracks show a badge. There is no app-level clean-only filter in MVP.

### Rotation representation

- The locked order is append-only for the life of a session.
- Gone and removed participants remain as tombstones and are skipped when deriving
  playback. This preserves their historical position.
- `gone` may be undone, restoring the original position; songs deleted when the
  participant became gone are not restored.
- `removed` is terminal for that participant identity during the session.
- Current-round skip state is cleared at the round boundary.

### Exact skip semantics

`turnSkipped`:

- A participant may skip only when their pending track is `nextUp` and has not
  started playing. The host may perform the same action for `nextUp`.
- The track stays at the front of that participant's FIFO and is reconsidered in
  the next round.
- It remains pending, counts toward the cap, and continues blocking duplicates.
- The skip takes effect immediately and cannot be undone.
- Removing `nextUp` removes the track; it does not retain it as a turn skip.
- If no other eligible participant has a track, the skipped participant may become
  `nextUp` again immediately rather than producing artificial silence.

`playingTrackSkipped`:

- Only the host can skip the currently playing track.
- The track is consumed, no longer blocks duplicates, and counts in play history.
- This is a playback action, not a turn skip.

`trackFailed`:

- An unplayable track is removed, does not count as played, and no longer blocks
  duplicates. It is not retried automatically.
- Everyone briefly sees a clear failure status, and rotation advances once.

### Fairness invariants

- No participant plays twice consecutively while another eligible participant has
  a pending track at that transition.
- FIFO order within every participant is preserved.
- Existing rotation positions never reorder; late joiners append only.
- Given equal supply and eligibility, play-count differences are at most one.
- A playback transition advances rotation at most once.
- Replayed commands do not mutate state more than once.

## Validation and rejection taxonomy

The host validates every inbound command before state mutation. Guests send
commands, never replacement state.

Keep failure layers separate:

```swift
enum FairnessRejection: Sendable {
    case duplicate
    case pendingLimitReached(limit: Int)
    case participantNotActive
    case unauthorizedAction
    case submissionNotFound
}

enum TrackValidationRejection: Sendable {
    case unknownTrack
    case notPlayableInHostStorefront
    case explicitContentRestricted
    case validationTimedOut
}

enum SubmissionRejection: Sendable {
    case fairness(FairnessRejection)
    case validation(TrackValidationRejection)
    case session(SessionCommandRejection)
}
```

Exact names may evolve with implementation, but MusicKit/network failures must not
leak into the pure fairness scheduler. Every rejection has localized explanatory
copy; nothing is silently dropped.

## Protocol and reconnection

- Every message contains `protocolVersion`, `sessionID`, `participantID`,
  `requestID`, `hostStateRevision`, and a typed payload.
- Use explicit length-prefixed framing and enforce a documented maximum message
  size before decoding.
- Guest commands are idempotent by `requestID`. The host acknowledges acceptance
  or returns a typed rejection.
- A reconnecting guest receives a complete canonical snapshot. Newer host revision
  wins; guests never merge or replace host state.
- Protocol-version mismatch is rejected with an update-required message.
- Reconnect grace is 45 seconds by default. Pending tracks remain, but the
  reconnecting participant's turns auto-skip with their tracks retained.
- A reconnecting participant reserves their capacity slot and original position.
- Host-loss grace is 30 seconds by default. On definitive loss, guests clear
  pending commands and destroy mirrored session state.
- Snapshots never expose another participant's reconnect credential or reusable
  admission secret.
- Malformed, oversized, replayed, unauthorized, or rate-limited messages cannot
  mutate state and are logged without private payload data.

## Playback and lifecycle

- The fair logical queue is authoritative. Reconciliation changes the
  `ApplicationMusicPlayer` queue minimally and preserves the current track.
- A full player-queue rebuild is allowed only when no track is actively playing.
- One owned playback-transition observer deduplicates completion and skip events.
- Calls, Siri, route changes, AirPods/AirPlay changes, and Control Center actions
  keep the session active and produce deterministic playback state.
- An empty queue leaves the session active and playback resumes after the next
  accepted song.
- Inactivity means an empty queue and stopped playback for five minutes. Warn the
  host with a cancelable countdown before ending. Paused playback with queued songs
  is not inactivity.
- Manual end requires confirmation while music plays, notifies guests, stops and
  clears the player, then destroys live in-memory state.
- A track enters play history when playback starts. Host-skipped playing tracks are
  included; failed-before-play tracks are excluded; duplicates are preserved.
- Playlist export is post-MVP. Its future end-session flow must receive an immutable
  history snapshot before live state is destroyed.

## Privacy, accessibility, and localization

- Never log participant names, track IDs, search terms, listening history, join
  secrets, reconnect credentials, full peer payloads, tokens, or private keys.
- No listening-content analytics. Aggregate operational metrics are deferred until
  a privacy-safe collection mechanism is explicitly selected.
- Sessions and listening history are never persisted locally or in the cloud.
- MVP supports VoiceOver, Dynamic Type, sufficient contrast, Reduce Motion, and
  identity that does not rely on color.
- Launch language is English. Use `Localizable.xcstrings` with stable symbol keys
  from the beginning, and design layouts for localization expansion.

## MVP release gate

The closed TestFlight is ready only after ten successful sessions with at least
three people across at least three device/network setups. Collect this result
manually unless an analytics mechanism is separately approved.

The physical-device matrix includes:

- Subscriber host and non-subscriber guest catalog search.
- Host plus two guests and the eight-device capacity boundary.
- MusicKit and local-network denial/recovery.
- Different storefronts and unplayable content.
- Guest and host disconnect/reconnect, foreground/background, and host loss.
- Audio interruption and route changes.
- Empty queue and automatic resume.
- Pending-cap and duplicate rejection.
- Turn skip, playing-track skip, gone/return, removal/block, late join, and end.

The authoritative execution status and evidence for this matrix live in
[`VERIFICATION_LOG.md`](VERIFICATION_LOG.md).

## Explicitly deferred

- Host migration.
- Remote/internet sessions and backend accounts.
- Chat, reactions, profiles, StoreKit, and monetization.
- Persistent or cloud listening history.
- iPad-specific design, Android, advanced playlist editing, clean-only mode,
  cooldowns, and full translation.

## Open verification

1. Confirm on physical hardware that a guest without an Apple Music subscription
   can authorize MusicKit and search the catalog.
2. Confirm the selected iOS 26 Network APIs support the required Bonjour plus
   peer-to-peer behavior on the minimum supported OS and devices.
3. Confirm host background audio and foreground-only session-management behavior
   under device lock and common interruptions.

## Decision history

- 2026-07-18: Initial product direction selected MultipeerConnectivity.
- 2026-07-18: Replaced it with iOS 26 concurrency-native Network framework,
  host-and-spoke topology.
- 2026-07-18: Confirmed the host participates fairly, pending cap is three, empty
  turns auto-skip, and all session content is ephemeral.
- 2026-07-18: Clarified turn skip versus playing-track skip versus track failure;
  retained tombstones in locked order; separated fairness and Music validation;
  adopted automatic MusicKit token management and just-in-time permissions.
