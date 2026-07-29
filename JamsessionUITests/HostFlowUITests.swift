import XCTest

final class HostFlowUITests: XCTestCase {
    @MainActor
    func testHostProfileReachesJustInTimeMusicExplanationWithoutRequestingAccess() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["host.flow.open"].tap()

        let nameField = app.textFields["host.flow.profile.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Maya")

        app.buttons["host.flow.profile.continue"].tap()

        XCTAssertTrue(
            app.staticTexts["Connect Apple Music"].waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.buttons["host.flow.music.continue"].exists)
        XCTAssertTrue(
            app.staticTexts["Access is requested only after you continue."].exists
        )
    }

    @MainActor
    func testEligibleHostCanStartSoloSessionThroughCanonicalCoordinator() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-host-flow-eligible",
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()

        tapButton("host.flow.open", in: app, scrollingIfNeeded: true)

        let nameField = app.textFields["host.flow.profile.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Maya")
        app.keyboards.buttons["Done"].tap()
        tapButton("host.flow.profile.continue", in: app, scrollingIfNeeded: true)
        tapButton("host.flow.music.continue", in: app, scrollingIfNeeded: true)

        XCTAssertTrue(app.staticTexts["Host Lobby"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Maya"].exists)
        XCTAssertTrue(app.staticTexts["Host"].exists)

        let lobbyScreenshot = XCTAttachment(screenshot: app.screenshot())
        lobbyScreenshot.name = "Host solo lobby"
        lobbyScreenshot.lifetime = .keepAlways
        add(lobbyScreenshot)

        tapButton("host.flow.lobby.start", in: app, scrollingIfNeeded: true)

        XCTAssertTrue(app.staticTexts["Host Session"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["The queue is wide open"].exists)
        tapButton("queue.addMusic", in: app, scrollingIfNeeded: true)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("Midnight")
        app.keyboards.buttons["Search"].tap()

        let addButton = app.buttons["host.flow.search.debug-midnight-drive.add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()

        XCTAssertTrue(app.staticTexts["Queue updated"].waitForExistence(timeout: 2))

        let searchScreenshot = XCTAttachment(screenshot: app.screenshot())
        searchScreenshot.name = "Host catalog search at AX5"
        searchScreenshot.lifetime = .keepAlways
        add(searchScreenshot)

        tapButton("host.flow.search.done", in: app, scrollingIfNeeded: true)

        XCTAssertTrue(app.staticTexts["Midnight Drive"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Nova Lane"].exists)
        XCTAssertTrue(app.staticTexts["Ready to Play"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["host.playback.skip"].isEnabled)

        tapButton("host.playback.playPause", in: app, scrollingIfNeeded: true)
        XCTAssertTrue(app.staticTexts["Now Playing"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["host.playback.playPause"].label, "Pause")
        XCTAssertTrue(app.buttons["host.playback.skip"].isEnabled)

        let playbackScreenshot = XCTAttachment(screenshot: app.screenshot())
        playbackScreenshot.name = "Host playback controls at AX5"
        playbackScreenshot.lifetime = .keepAlways
        add(playbackScreenshot)

        tapButton("host.playback.playPause", in: app, scrollingIfNeeded: true)
        XCTAssertEqual(app.buttons["host.playback.playPause"].label, "Play")
        tapButton("host.playback.playPause", in: app, scrollingIfNeeded: true)
        XCTAssertEqual(app.buttons["host.playback.playPause"].label, "Pause")

        tapButton("host.playback.skip", in: app, scrollingIfNeeded: true)
        XCTAssertTrue(app.staticTexts["The queue is wide open"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["host.playback.controls"].exists)
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
        XCTAssertTrue(
            button.isHittable,
            "Expected button \(identifier) to be hittable.",
            file: file,
            line: line
        )
        button.tap()
    }
}
