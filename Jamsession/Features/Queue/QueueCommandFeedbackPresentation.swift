import Foundation

nonisolated struct QueueCommandFeedbackPresentation: Equatable, Sendable {
    nonisolated enum Tone: Equatable, Sendable {
        case success
        case warning
    }

    let title: String
    let message: String
    let tone: Tone

    static func map(_ outcome: QueueCommandOutcome) -> Self {
        switch outcome {
        case .accepted:
            Self(
                title: String(localized: "queue.feedback.accepted.title", defaultValue: "Queue updated"),
                message: String(
                    localized: "queue.feedback.accepted.message",
                    defaultValue: "Everyone now sees the latest fair order."
                ),
                tone: .success
            )
        case .rejected(let rejection):
            Self(
                title: String(localized: "queue.feedback.rejected.title", defaultValue: "Couldn’t update the queue"),
                message: rejectionMessage(rejection),
                tone: .warning
            )
        }
    }

    private static func rejectionMessage(_ rejection: FairnessRejection) -> String {
        switch rejection {
        case .duplicate:
            String(
                localized: "queue.rejection.duplicate",
                defaultValue: "That song is already pending in this session."
            )
        case .pendingLimitReached(let limit):
            String(
                localized: "queue.rejection.pendingLimit",
                defaultValue: "You’ve got \(limit) songs queued — wait for one to play."
            )
        case .participantNotFound:
            String(
                localized: "queue.rejection.participantNotFound",
                defaultValue: "This participant is no longer part of the session."
            )
        case .participantNotActive:
            String(
                localized: "queue.rejection.participantNotActive",
                defaultValue: "Reconnect before changing the queue."
            )
        case .participantAlreadyExists:
            String(
                localized: "queue.rejection.participantAlreadyExists",
                defaultValue: "This participant has already joined."
            )
        case .participantRemoved:
            String(
                localized: "queue.rejection.participantRemoved",
                defaultValue: "A removed participant can’t change the queue."
            )
        case .unauthorizedAction:
            String(
                localized: "queue.rejection.unauthorized",
                defaultValue: "You can only change songs you’re allowed to manage."
            )
        case .submissionNotFound:
            String(
                localized: "queue.rejection.submissionNotFound",
                defaultValue: "That song is no longer pending."
            )
        case .notNextUp:
            String(
                localized: "queue.rejection.notNextUp",
                defaultValue: "Only the next turn can be skipped."
            )
        case .nothingPlaying:
            String(
                localized: "queue.rejection.nothingPlaying",
                defaultValue: "Nothing is playing right now."
            )
        }
    }
}
