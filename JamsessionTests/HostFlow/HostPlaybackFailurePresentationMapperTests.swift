import Testing
@testable import Jamsession

struct HostPlaybackFailurePresentationMapperTests {
    @Test(
        arguments: [
            HostPlaybackError.authorizationRequired,
            .subscriptionRequired,
            .offline,
            .trackUnavailable,
            .queueChanged,
            .unavailable
        ]
    )
    func everyFailureHasActionablePresentation(_ error: HostPlaybackError) {
        let presentation = HostPlaybackFailurePresentationMapper.map(error)

        #expect(!presentation.title.isEmpty)
        #expect(!presentation.message.isEmpty)
        #expect(!presentation.retryTitle.isEmpty)
    }

    @Test
    func failureMessagesRemainDistinct() {
        let errors: [HostPlaybackError] = [
            .authorizationRequired,
            .subscriptionRequired,
            .offline,
            .trackUnavailable,
            .queueChanged,
            .unavailable
        ]
        let messages = errors.map {
            HostPlaybackFailurePresentationMapper.map($0).message
        }

        #expect(Set(messages).count == errors.count)
    }
}
