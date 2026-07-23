# Slice 0 Friend Test Runbook

Use this runbook with `VERIFICATION_LOG.md`. Slice 0 does not pass until every
required physical-device row has current evidence. Do not record Apple IDs,
device identifiers, search terms, track IDs, credentials, or full peer payloads.

## What to bring

- The development Mac with Xcode 26.6 or later and this repository.
- Two unlocked iPhones running iOS 26.0 or later, with Developer Mode enabled.
- USB cables for first installation. Wireless debugging is optional.
- Both phones connected to the same ordinary Wi-Fi network. Avoid guest Wi-Fi,
  VPNs, Private Relay troubleshooting variables, and networks with client
  isolation for the first run.
- One Apple Music subscriber account on the host phone.
- Preferably, a non-subscriber account on the friend's phone for V0-2. Do not
  start or cancel a trial merely to manufacture this state without the account
  owner's agreement.

## One-time Xcode and signing setup

1. In the Apple Developer portal, confirm the explicit App ID
   `com.jamsession.jamsession` has the MusicKit App Service enabled. MusicKit
   does not require a code-signing entitlement or a private `.p8` key in this
   project.
2. Open `Jamsession.xcodeproj` and select the **Jamsession** target.
3. Under **Signing & Capabilities**, confirm Team is set to the intended team
   and **Automatically manage signing** is enabled. Do not add Background
   Modes; the existing lock-screen result did not show it was required.
4. Connect each iPhone by cable, accept **Trust This Computer**, enable
   **Settings > Privacy & Security > Developer Mode** if prompted, restart, and
   confirm Developer Mode after restart.
5. Select each phone as the run destination and press **Run** once. If Xcode
   offers to register the phone or repair the provisioning profile, allow it.
6. Keep both phones unlocked during installation. Launch Jamsession and verify
   the title **Slice 0 Feasibility** appears.

The checked-in configuration already declares Apple Music usage, local-network
usage, and `_jamsession._tcp` Bonjour discovery in `Jamsession/Info.plist`.

## Reset permissions between scenarios

Permission prompts normally appear only once. On a test phone, use
**Settings > Privacy & Security > Media & Apple Music** and
**Settings > Privacy & Security > Local Network** to change Jamsession access.
After changing a permission, fully stop and relaunch Jamsession before retrying.
Record the starting permission state for each scenario.

## Test A — non-subscriber catalog search (V0-2)

Run only when the friend's phone is signed into a genuinely non-subscribed Apple
Music account.

1. On the friend's phone, enter a generic catalog query without recording it in
   evidence.
2. Tap **Test Guest Search** and allow Media & Apple Music access.
3. PASS if authorization succeeds and the status reports catalog results without
   requiring playback or starting a subscription.
4. FAIL if authorization succeeds but catalog search cannot be performed. Save a
   privacy-safe screenshot of the status and the exact error text, then stop:
   the guest product promise must be revised before dependent implementation.

If the friend is a subscriber, leave V0-2 BLOCKED; network testing is still useful.

## Test B — discovery and two-way framed exchange (V0-4)

1. Put both phones on the same Wi-Fi network with Bluetooth enabled. Keep both
   apps foregrounded and both screens awake.
2. On phone A tap **Host Network Spike** and allow Local Network access.
3. On phone B tap **Discover and Connect** and allow Local Network access.
4. PASS only when phone A reports receiving the guest's `hello` and phone B
   reports receiving the host's `acknowledgement`. This proves one framed
   `Codable` message traveled in each direction.
5. Tap **Stop Network Spike** on phone B, then phone A. PASS termination only if
   both report a clean stop and neither app hangs or crashes.
6. Repeat with phone B hosting and phone A browsing.

If discovery does not occur within 15 seconds, verify both Local Network toggles,
disable VPNs, confirm the same Wi-Fi SSID, and try a personal hotspot. Record the
failure before changing networks; do not treat a simulator exchange as a pass.

## Test C — denial versus no nearby room (V0-6B)

1. Stop the host. On phone B, disable Jamsession's Local Network access and tap
   **Discover and Connect**. Confirm the explicit denied status and Settings
   recovery button.
2. Re-enable Local Network access and relaunch Jamsession. With no host running,
   tap **Discover and Connect** again.
3. PASS only if the second state says local-network access is available with no
   selected nearby host, visibly distinct from denial.
4. Start the host and confirm the browser can subsequently connect.

## Test D — foreground, background, lock, and reconnect (V0-5 and V0-7B)

Start from a successful connection and record the status shown on both phones
after each step.

1. Background the guest for 10 seconds, return it to foreground, and reconnect if
   necessary. Exchange must work again and **Stop** must terminate cleanly.
2. Repeat with the host backgrounded for 10 seconds.
3. Lock the guest for 10 seconds, unlock, foreground the app, and reconnect if
   necessary.
4. Repeat with the host locked for 10 seconds.
5. Repeat one guest transition and one host transition for 45 seconds to expose
   longer suspension behavior.

The expected MVP behavior is foreground-oriented. A disconnect is not itself a
failure; failure means the observed state is ambiguous, the app cannot reconnect,
or tasks do not terminate cleanly. Record whether each transition persisted,
disconnected, and/or reconnected rather than summarizing all transitions together.

## Evidence template

Add results to the matching row in `VERIFICATION_LOG.md` using this shape:

```text
Tester(s): initials or roles. App commit: <short SHA>. Devices: <models and exact
iOS versions/builds>. Accounts: subscriber/non-subscriber and storefront only.
Network: <home Wi-Fi/personal hotspot and relevant conditions>. Expected: <brief>.
Observed: <brief>. Repeats: <count>. Evidence: <privacy-safe relative path or note>.
```

Split mixed results rather than marking a row PASS when only part ran. If any
gate fails, record FAIL and preserve the observation before changing the spike or
the canonical product decision.
