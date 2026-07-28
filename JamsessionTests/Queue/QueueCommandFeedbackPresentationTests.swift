import Testing
@testable import Jamsession

struct QueueCommandFeedbackPresentationTests {
    @Test
    func acceptedOutcomeUsesSuccessPresentation() {
        let presentation = QueueCommandFeedbackPresentation.map(.accepted)

        #expect(presentation.title == "Queue updated")
        #expect(presentation.tone == .success)
    }

    @Test
    func pendingLimitIncludesTheConfiguredLimit() {
        let presentation = QueueCommandFeedbackPresentation.map(
            .rejected(.pendingLimitReached(limit: 3))
        )

        #expect(presentation.title == "Couldn’t update the queue")
        #expect(presentation.message == "You’ve got 3 songs queued — wait for one to play.")
        #expect(presentation.tone == .warning)
    }

    @Test
    func everyFairnessRejectionHasActionableCopy() {
        let rejections: [FairnessRejection] = [
            .duplicate,
            .pendingLimitReached(limit: 3),
            .participantNotFound,
            .participantNotActive,
            .participantAlreadyExists,
            .participantRemoved,
            .unauthorizedAction,
            .submissionNotFound,
            .notNextUp,
            .nothingPlaying
        ]

        for rejection in rejections {
            let presentation = QueueCommandFeedbackPresentation.map(.rejected(rejection))
            #expect(!presentation.message.isEmpty)
            #expect(presentation.tone == .warning)
        }
    }
}
