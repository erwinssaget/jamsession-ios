#if DEBUG
import XCTest

final class MockConnectedFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHostFlowReachesSearchAndRestarts() {
        let app = launchApplication()
        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.host",
            name: "Host Tester"
        )

        tapButton("mock.flow.host.start", in: app)
        openAndCloseSearch(in: app)
        restartAtWelcome(in: app)
    }

    @MainActor
    func testJoinFlowReachesSearchAndRestarts() {
        let app = launchApplication()
        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.join",
            name: "Guest Tester"
        )

        tapButton("mock.flow.discovery.session", in: app)
        tapButton("mock.flow.join.approve", in: app)
        openAndCloseSearch(in: app)
        restartAtWelcome(in: app)
    }

    @MainActor
    private func launchApplication() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func openConnectedFlow(in app: XCUIApplication) {
        tapButton("mock.flow.open", in: app)
    }

    @MainActor
    private func completeProfile(
        in app: XCUIApplication,
        roleIdentifier: String,
        name: String
    ) {
        tapButton(roleIdentifier, in: app)

        let nameField = app.textFields["mock.flow.profile.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)

        let keyboardDone = app.keyboards.buttons["Done"]
        XCTAssertTrue(keyboardDone.waitForExistence(timeout: 2))
        keyboardDone.tap()

        tapButton(
            "mock.flow.profile.continue",
            in: app,
            scrollingIfNeeded: true
        )
        tapButton("mock.flow.permission.finish", in: app)
    }

    @MainActor
    private func openAndCloseSearch(in app: XCUIApplication) {
        tapButton("mock.flow.queue.addMusic", in: app)
        tapButton("mock.flow.search.done", in: app)
    }

    @MainActor
    private func restartAtWelcome(in app: XCUIApplication) {
        tapButton("mock.flow.restart", in: app)
        XCTAssertTrue(
            app.buttons["mock.flow.role.host"].waitForExistence(timeout: 3),
            "Restart should return the connected mock flow to role selection."
        )
    }

    @MainActor
    private func tapButton(
        _ identifier: String,
        in app: XCUIApplication,
        scrollingIfNeeded: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let button = app.buttons[identifier]
        XCTAssertTrue(
            button.waitForExistence(timeout: 3),
            "Expected button \(identifier) to exist.",
            file: file,
            line: line
        )

        if scrollingIfNeeded {
            for _ in 0..<4 where !button.isHittable {
                app.swipeUp()
            }
        }

        XCTAssertTrue(
            button.isHittable,
            "Expected button \(identifier) to be hittable.",
            file: file,
            line: line
        )
        button.tap()
    }
}
#endif
