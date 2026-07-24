import Testing
@testable import Jamsession

struct MockSessionHeaderPresentationTests {
    @Test @MainActor
    func participantCountUsesSingularAndPluralForms() {
        let solo = QueueSessionHeaderView(
            presentation: MockSessionFixtures.solo,
            addMusic: {}
        )
        let full = QueueSessionHeaderView(
            presentation: MockSessionFixtures.fullSession,
            addMusic: {}
        )

        #expect(solo.participantCountDescription == "1 person")
        #expect(full.participantCountDescription == "8 people")
    }
}
