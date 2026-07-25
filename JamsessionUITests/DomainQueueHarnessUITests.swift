import XCTest

final class DomainQueueHarnessUITests: XCTestCase {
    @MainActor
    func testQueueActionsUseCanonicalFairnessState() {
        let app = XCUIApplication()
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

        let feedbackTitle = app.staticTexts["queue.catalog.feedback.title"]
        XCTAssertTrue(feedbackTitle.waitForExistence(timeout: 2))
        XCTAssertTrue(feedbackTitle.isHittable)
        XCTAssertEqual(feedbackTitle.label, "Couldn’t update the queue")

        let feedbackMessage = app.staticTexts["queue.catalog.feedback.message"]
        XCTAssertTrue(feedbackMessage.isHittable)
        XCTAssertEqual(
            feedbackMessage.label,
            "That song is already pending in this session."
        )

        let dismissFeedback = app.buttons["queue.catalog.feedback.dismiss"]
        XCTAssertTrue(dismissFeedback.isHittable)
        dismissFeedback.tap()
        XCTAssertFalse(feedbackTitle.exists)
    }
}
