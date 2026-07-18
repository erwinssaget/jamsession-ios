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
| Slice 0 | **CLOSED — hardware/account verification incomplete** | V0-1 through V0-7 as applicable; V0-2, V0-4, V0-5, V0-6B, and V0-7B need additional hardware or account conditions | Remaining Slice 0 work and the pure Slice 1 fairness engine under the provisional-work rule in `BUILD_PLAN.md`. No dependent transport, playback, permission, or lifecycle integration may treat Slice 0 assumptions as proven. |
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

| ID | Verification | Needs | Blocks | Status | Date | Build / result / evidence |
|----|--------------|-------|--------|--------|------|---------------------------|
| V0-1 | Subscriber host authorizes, searches, queues, plays, pauses, and skips with `ApplicationMusicPlayer` | 1 physical iPhone; subscribed account | Slice 0 | TODO | | |
| V0-2 | Non-subscriber authorizes MusicKit and searches the catalog | 1 physical iPhone; non-subscriber account | Slice 0 and guest product promise | BLOCKED | | Need a non-subscriber account/device condition. If it fails, revise `PRODUCT_DECISIONS.md` before changing the guest model. |
| V0-3 | Guest denied Music access can still reach the mock joined-queue screen | 1 physical iPhone; Music access denied | Slice 0 | TODO | | |
| V0-4 | Two devices discover through Bonjour, connect host-and-spoke, exchange one framed `Codable` message in each direction, and terminate cleanly | 2 physical iPhones | Slice 0 | BLOCKED | | Need second device. Verify actual iOS 26 concurrency-native Network API availability before treating the spike as complete. |
| V0-5 | Peer link behavior across guest and host foreground/background transitions is observed; reconnection terminates cleanly | 2 physical iPhones | Slice 0 | BLOCKED | | Need second device. Record each transition tested and whether the connection persisted, disconnected, or reconnected. |
| V0-6A | Local-network denial produces the intended denial UI and recovery guidance | 1 physical iPhone; local-network access denied | Slice 0 | TODO | | UI/state handling only; this does not prove discovery behavior. |
| V0-6B | Local-network denial is behaviorally distinguishable from an allowed device with no nearby room | 2 physical iPhones; one discoverable host | Slice 0 | BLOCKED | | Need second device for the contrast case. |
| V0-7A | Host audio continues as designed under device lock; playback controls remain deterministic | 1 physical iPhone; subscribed account | Slice 0/open verification | TODO | | Record whether background-audio capability is required before retaining it. |
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
