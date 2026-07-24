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

        app.buttons["mock.flow.queue.addMusic"].tap()
        let duplicateAddButton = app.buttons["queue.catalog.catalog-golden-hour.add"]
        XCTAssertTrue(duplicateAddButton.waitForExistence(timeout: 2))
        duplicateAddButton.tap()

        XCTAssertTrue(
            app.staticTexts["Couldn’t update the queue"].waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            app.staticTexts["That song is already pending in this session."].exists
        )
    }
}
