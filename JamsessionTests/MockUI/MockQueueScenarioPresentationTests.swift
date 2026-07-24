import Testing
@testable import Jamsession

struct MockQueueScenarioPresentationTests {
    @Test
    func everyScenarioSuppliesTheExpectedPresentationState() {
        let populated = MockQueueScenario.populated.presentation
        let empty = MockQueueScenario.empty.presentation
        let reconnecting = MockQueueScenario.reconnecting.presentation

        #expect(populated.connectionStatus == .connected)
        #expect(populated.nowPlaying != nil)
        #expect(!populated.upcoming.isEmpty)

        #expect(empty.connectionStatus == .connected)
        #expect(empty.nowPlaying == nil)
        #expect(empty.upcoming.isEmpty)

        #expect(reconnecting.connectionStatus == .reconnecting)
        #expect(reconnecting.nowPlaying == populated.nowPlaying)
        #expect(reconnecting.upcoming == populated.upcoming)
    }
}
