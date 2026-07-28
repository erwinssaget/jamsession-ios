import Foundation

nonisolated enum HostCatalogSubmissionFeedbackMapper {
    static func map(
        _ outcome: HostCatalogSubmissionOutcome
    ) -> QueueCommandFeedbackPresentation {
        switch outcome {
        case .accepted:
            QueueCommandFeedbackPresentation.map(.accepted)
        case .fairnessRejected(let rejection):
            QueueCommandFeedbackPresentation.map(.rejected(rejection))
        case .catalogRejected(let error):
            QueueCommandFeedbackPresentation(
                title: String(
                    localized: "host.search.feedback.unavailable.title",
                    defaultValue: "Couldn’t add that song"
                ),
                message: message(for: error),
                tone: .warning
            )
        }
    }

    private static func message(for error: HostCatalogServiceError) -> String {
        switch error {
        case .authorizationRequired:
            String(
                localized: "host.search.failure.authorization",
                defaultValue: "Reconnect Apple Music before adding songs."
            )
        case .subscriptionRequired:
            String(
                localized: "host.search.failure.subscription",
                defaultValue: "An active Apple Music subscription is required to host."
            )
        case .offline:
            String(
                localized: "host.search.failure.offline",
                defaultValue: "Check your connection, then try again."
            )
        case .trackUnavailable:
            String(
                localized: "host.search.failure.trackUnavailable",
                defaultValue: "That song isn’t playable in the Host’s storefront."
            )
        case .unavailable:
            String(
                localized: "host.search.failure.unavailable",
                defaultValue: "Apple Music couldn’t verify that song. Try again."
            )
        }
    }
}
