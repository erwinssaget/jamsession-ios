import Testing
@testable import Jamsession

struct HostCatalogSubmissionFeedbackMapperTests {
    @Test
    func everyCatalogFailureHasDistinctActionableFeedback() {
        let errors: [HostCatalogServiceError] = [
            .authorizationRequired,
            .subscriptionRequired,
            .offline,
            .trackUnavailable,
            .unavailable
        ]

        let presentations = errors.map {
            HostCatalogSubmissionFeedbackMapper.map(.catalogRejected($0))
        }

        #expect(presentations.allSatisfy { !$0.title.isEmpty })
        #expect(presentations.allSatisfy { !$0.message.isEmpty })
        #expect(presentations.allSatisfy { $0.tone == .warning })
        #expect(Set(presentations.map(\.message)).count == errors.count)
    }

    @Test
    func acceptedSubmissionUsesCanonicalQueueSuccessFeedback() {
        let presentation = HostCatalogSubmissionFeedbackMapper.map(.accepted)

        #expect(presentation == QueueCommandFeedbackPresentation.map(.accepted))
    }
}
