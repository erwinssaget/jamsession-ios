import Foundation
import Testing

struct MockLifecyclePresentationTests {
    @Test
    func goneScenarioUsesPostGraceSemantics() {
        let title = String(localized: "mockLifecycle.gone.title")
        let description = String(localized: "mockLifecycle.gone.description")
        let queueExplanation = String(localized: "mockLifecycle.gone.queueExplanation")

        #expect(title == "Friend Gone")
        #expect(description.localizedStandardContains("pending songs were removed"))
        #expect(queueExplanation.localizedStandardContains("removed songs do not return"))
    }
}
