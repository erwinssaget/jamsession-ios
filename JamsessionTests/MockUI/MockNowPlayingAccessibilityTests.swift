import Testing
@testable import Jamsession

struct MockNowPlayingAccessibilityTests {
    @Test @MainActor
    func explicitTrackAnnouncesExplicitStatus() {
        let view = QueueNowPlayingView(track: MockSessionFixtures.longTitleTrack)

        #expect(view.accessibilityDescription.hasSuffix(", Explicit"))
    }

    @Test @MainActor
    func cleanTrackDoesNotAnnounceExplicitStatus() throws {
        let track = try #require(MockSessionFixtures.populated.nowPlaying)
        let view = QueueNowPlayingView(track: track)

        #expect(!view.accessibilityDescription.contains("Explicit"))
    }
}
