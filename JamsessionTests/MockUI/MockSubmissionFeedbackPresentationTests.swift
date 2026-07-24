import Testing
@testable import Jamsession

struct MockSubmissionFeedbackPresentationTests {
    @Test
    func everyOutcomeHasExpectedPresentation() {
        let expected: [(MockSubmissionOutcome, MockSubmissionFeedbackPresentation)] = [
            (
                .pending,
                .init(
                    titleKey: "mockSearch.feedback.pending.title",
                    descriptionKey: "mockSearch.feedback.pending.description",
                    systemImage: "clock",
                    tone: .pending
                )
            ),
            (
                .accepted,
                .init(
                    titleKey: "mockSearch.feedback.accepted.title",
                    descriptionKey: "mockSearch.feedback.accepted.description",
                    systemImage: "checkmark.circle.fill",
                    tone: .accepted
                )
            ),
            (
                .duplicate,
                .init(
                    titleKey: "mockSearch.feedback.duplicate.title",
                    descriptionKey: "mockSearch.feedback.duplicate.description",
                    systemImage: "exclamationmark.circle.fill",
                    tone: .warning
                )
            ),
            (
                .pendingLimit,
                .init(
                    titleKey: "mockSearch.feedback.pendingLimit.title",
                    descriptionKey: "mockSearch.feedback.pendingLimit.description",
                    systemImage: "exclamationmark.circle.fill",
                    tone: .warning
                )
            ),
            (
                .participantInactive,
                .init(
                    titleKey: "mockSearch.feedback.inactive.title",
                    descriptionKey: "mockSearch.feedback.inactive.description",
                    systemImage: "exclamationmark.circle.fill",
                    tone: .warning
                )
            ),
            (
                .unplayable,
                .init(
                    titleKey: "mockSearch.feedback.unplayable.title",
                    descriptionKey: "mockSearch.feedback.unplayable.description",
                    systemImage: "xmark.circle.fill",
                    tone: .failure
                )
            ),
            (
                .timedOut,
                .init(
                    titleKey: "mockSearch.feedback.timeout.title",
                    descriptionKey: "mockSearch.feedback.timeout.description",
                    systemImage: "xmark.circle.fill",
                    tone: .failure
                )
            ),
        ]

        #expect(MockSubmissionOutcome.allCases.count == expected.count)

        for (outcome, presentation) in expected {
            #expect(outcome.presentation == presentation)
            #expect(outcome.titleKey == presentation.titleKey)
        }
    }
}
