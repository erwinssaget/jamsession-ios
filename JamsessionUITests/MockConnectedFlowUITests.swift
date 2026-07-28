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
        returnHomeFromEndedLifecycle(in: app)
        XCTAssertTrue(
            app.buttons["mock.flow.role.host"].waitForExistence(timeout: 3),
            "Return Home should return the connected mock flow to role selection."
        )
    }

    @MainActor
    func testHostFlowRestartsFromQueue() {
        let app = launchApplication()
        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.host",
            name: "Host Tester"
        )

        tapButton("mock.flow.host.start", in: app)
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
    func testPermissionExplainerIsScrollableAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()

        openConnectedFlow(in: app)
        tapButton(
            "mock.flow.role.host",
            in: app,
            scrollingIfNeeded: true
        )

        let nameField = app.textFields["mock.flow.profile.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("AX Host")

        let keyboardDone = app.keyboards.buttons["Done"]
        XCTAssertTrue(keyboardDone.waitForExistence(timeout: 2))
        keyboardDone.tap()

        tapButton(
            "mock.flow.profile.continue",
            in: app,
            scrollingIfNeeded: true
        )
        tapButton(
            "mock.flow.permission.finish",
            in: app,
            scrollingIfNeeded: true
        )

        XCTAssertTrue(
            app.buttons["mock.flow.host.start"].waitForExistence(timeout: 3),
            "The permission action should remain reachable at accessibility text sizes."
        )
    }

    @MainActor
    func testInviteSheetIsScrollableAtAccessibilityTextSize() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()

        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.host",
            name: "AX Host",
            scrollingIfNeeded: true
        )
        tapButton(
            "mock.flow.host.invite",
            in: app,
            scrollingIfNeeded: true
        )

        let fixtureNotice = app.staticTexts["mock.flow.invite.fixtureNotice"]
        for _ in 0..<8 where !fixtureNotice.exists || !fixtureNotice.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(
            fixtureNotice.waitForExistence(timeout: 3),
            "The invite fixture notice should remain reachable at accessibility text sizes."
        )
        XCTAssertTrue(
            fixtureNotice.isHittable,
            "The invite sheet should scroll until its supporting content is visible."
        )

        tapButton("mock.flow.invite.done", in: app)
        XCTAssertTrue(
            app.buttons["mock.flow.host.start"].waitForExistence(timeout: 3),
            "Dismissing the invite should return to the host lobby."
        )
    }

    @MainActor
    func testMusicAccessDeniedOffersSettingsRecovery() {
        let app = launchApplication()
        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.join",
            name: "Denied Guest"
        )

        tapButton("mock.flow.discovery.session", in: app)
        tapButton("mock.flow.join.approve", in: app)
        tapButton("queue.addMusic", in: app)
        tapButton("mock.flow.search.previewState", in: app)
        tapButton("mock.flow.search.scenario.musicAccessDenied", in: app)

        XCTAssertTrue(
            app.buttons["mock.flow.search.openSettings"].waitForExistence(timeout: 3),
            "Denied Music access should offer a Settings recovery action."
        )
        XCTAssertFalse(
            app.buttons["Try Again"].exists,
            "Denied Music access should not simulate recovery through catalog retry."
        )
    }

    @MainActor
    func testSubmissionFeedbackStaysVisibleForLowerSearchResult() {
        let app = launchApplication()
        openConnectedFlow(in: app)
        completeProfile(
            in: app,
            roleIdentifier: "mock.flow.role.join",
            name: "Feedback Guest"
        )

        tapButton("mock.flow.discovery.session", in: app)
        tapButton("mock.flow.join.approve", in: app)
        tapButton("queue.addMusic", in: app)

        let addButtons = app.buttons.matching(identifier: "mock.flow.search.add")
        let lowerResultAddButton = addButtons.element(boundBy: 3)
        for _ in 0..<8 where !lowerResultAddButton.exists || !lowerResultAddButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(
            lowerResultAddButton.waitForExistence(timeout: 3),
            "The lower search-result Add action should be reachable."
        )
        XCTAssertTrue(
            lowerResultAddButton.isHittable,
            "The lower search-result Add action should be visible before submission."
        )
        lowerResultAddButton.tap()

        let feedback = app.descendants(matching: .any)["mock.flow.search.feedback"]
        XCTAssertTrue(
            feedback.waitForExistence(timeout: 3),
            "Submission feedback should be presented after adding a lower result."
        )
        XCTAssertTrue(
            feedback.isHittable,
            "Submission feedback should stay visible in the search viewport."
        )

        let dismissFeedbackButton = app.buttons["mock.flow.search.feedback.dismiss"]
        XCTAssertTrue(
            dismissFeedbackButton.waitForExistence(timeout: 3),
            "Submission feedback should expose a separate dismiss control."
        )
        XCTAssertTrue(
            dismissFeedbackButton.isHittable,
            "The feedback dismiss control should remain reachable."
        )
        dismissFeedbackButton.tap()
        XCTAssertTrue(
            feedback.waitForNonExistence(timeout: 3),
            "Dismissing submission feedback should remove the bottom inset."
        )
    }

    @MainActor
    private func launchApplication() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func openConnectedFlow(in app: XCUIApplication) {
        tapButton(
            "mock.flow.open",
            in: app,
            scrollingIfNeeded: true
        )
    }

    @MainActor
    private func completeProfile(
        in app: XCUIApplication,
        roleIdentifier: String,
        name: String,
        scrollingIfNeeded: Bool = false
    ) {
        tapButton(
            roleIdentifier,
            in: app,
            scrollingIfNeeded: scrollingIfNeeded
        )

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
        tapButton(
            "mock.flow.permission.finish",
            in: app,
            scrollingIfNeeded: scrollingIfNeeded
        )
    }

    @MainActor
    private func openAndCloseSearch(in app: XCUIApplication) {
        tapButton("queue.addMusic", in: app)
        tapButton("mock.flow.search.done", in: app)
    }

    @MainActor
    private func returnHomeFromEndedLifecycle(in app: XCUIApplication) {
        tapButton("mock.flow.queue.lifecycle", in: app)

        let previewMenu = app.buttons["mock.flow.lifecycle.previewState"]
        XCTAssertTrue(previewMenu.waitForExistence(timeout: 3))
        previewMenu.tap()

        tapButton("mock.flow.lifecycle.scenario.ended", in: app)
        tapButton(
            "mock.flow.lifecycle.returnHome",
            in: app,
            scrollingIfNeeded: true
        )
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

        if scrollingIfNeeded {
            for _ in 0..<8 where !button.exists || !button.isHittable {
                app.swipeUp()
            }
        }

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
