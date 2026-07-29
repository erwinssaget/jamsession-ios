import XCTest

final class DomainQueueHarnessUITests: XCTestCase {
    @MainActor
    func testQueueActionsUseCanonicalFairnessState() {
        let app = XCUIApplication()
        app.launchArguments.append("-show-feasibility-harness")
        app.launch()

        app.buttons["queue.harness.open"].tap()
        XCTAssertTrue(app.staticTexts["Domain Queue"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Midnight Drive"].exists)

        app.buttons["queue.harness.advance"].tap()
        XCTAssertTrue(app.staticTexts["Now Playing"].waitForExistence(timeout: 2))

        app.buttons["queue.addMusic"].tap()
        let duplicateAddButton = app.buttons["queue.catalog.catalog-golden-hour.add"]
        XCTAssertTrue(duplicateAddButton.waitForExistence(timeout: 2))
        duplicateAddButton.tap()

        let feedbackSummary = app
            .descendants(matching: .any)
            .matching(identifier: "queue.catalog.feedback.summary")
            .firstMatch
        XCTAssertTrue(feedbackSummary.waitForExistence(timeout: 2))
        XCTAssertTrue(feedbackSummary.isHittable)
        XCTAssertEqual(
            feedbackSummary.label,
            "Couldn’t update the queue. That song is already pending in this session."
        )

        let dismissFeedback = app.buttons["queue.catalog.feedback.dismiss"]
        XCTAssertTrue(dismissFeedback.isHittable)
        dismissFeedback.tap()
        XCTAssertFalse(feedbackSummary.exists)
    }
}
