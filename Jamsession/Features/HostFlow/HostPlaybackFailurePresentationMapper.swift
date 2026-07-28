import Foundation

nonisolated enum HostPlaybackFailurePresentationMapper {
    static func map(
        _ error: HostPlaybackError
    ) -> HostPlaybackFailurePresentation {
        let title: String
        let message: String

        switch error {
        case .authorizationRequired:
            title = String(
                localized: "host.playback.failure.authorization.title",
                defaultValue: "Music access is off"
            )
            message = String(
                localized: "host.playback.failure.authorization.message",
                defaultValue: "Enable Music access in Settings, then retry the queue."
            )
        case .subscriptionRequired:
            title = String(
                localized: "host.playback.failure.subscription.title",
                defaultValue: "Subscription required"
            )
            message = String(
                localized: "host.playback.failure.subscription.message",
                defaultValue: "An active Apple Music subscription is required for Host playback."
            )
        case .offline:
            title = String(
                localized: "host.playback.failure.offline.title",
                defaultValue: "Queue sync is offline"
            )
            message = String(
                localized: "host.playback.failure.offline.message",
                defaultValue: "Check your connection, then retry the queue."
            )
        case .trackUnavailable:
            title = String(
                localized: "host.playback.failure.track.title",
                defaultValue: "A song can’t be played"
            )
            message = String(
                localized: "host.playback.failure.track.message",
                defaultValue: "A queued song is unavailable in the Host storefront. Playback is paused."
            )
        case .queueChanged:
            title = String(
                localized: "host.playback.failure.queue.title",
                defaultValue: "Playback queue changed"
            )
            message = String(
                localized: "host.playback.failure.queue.message",
                defaultValue: "Playback is paused because the Apple Music queue no longer matches this session."
            )
        case .unavailable:
            title = String(
                localized: "host.playback.failure.unavailable.title",
                defaultValue: "Queue sync failed"
            )
            message = String(
                localized: "host.playback.failure.unavailable.message",
                defaultValue: "Apple Music couldn’t update the queue. Playback is paused."
            )
        }

        return HostPlaybackFailurePresentation(
            title: title,
            message: message,
            retryTitle: String(
                localized: "host.playback.failure.retry",
                defaultValue: "Retry Queue Sync"
            )
        )
    }
}
