import Testing
@testable import Jamsession

struct MockScenarioCompletenessTests {
    @Test
    func scenarioTitleKeysAreCompleteAndUnique() {
        assertCompleteTitleKeys(MockQueueScenario.allCases.map(\.titleKey))
        assertCompleteTitleKeys(MockLobbyScenario.allCases.map(\.titleKey))
        assertCompleteTitleKeys(MockSearchScenario.allCases.map(\.titleKey))
        assertCompleteTitleKeys(MockLifecycleScenario.allCases.map(\.titleKey))
        assertCompleteTitleKeys(MockSubmissionOutcome.allCases.map(\.titleKey))
    }

    private func assertCompleteTitleKeys(_ keys: [String]) {
        #expect(keys.allSatisfy { !$0.isEmpty })
        #expect(Set(keys).count == keys.count)
    }
}
