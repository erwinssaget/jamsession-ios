nonisolated enum MockQueueScenario: String, CaseIterable, Identifiable {
    case populated
    case empty
    case reconnecting

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .populated:
            "mockQueue.scenario.populated"
        case .empty:
            "mockQueue.scenario.empty"
        case .reconnecting:
            "mockQueue.scenario.reconnecting"
        }
    }

    var presentation: MockSessionPresentation {
        switch self {
        case .populated:
            .init(
                sessionName: MockSessionFixtures.populated.sessionName,
                roomCode: MockSessionFixtures.populated.roomCode,
                participants: MockSessionFixtures.populated.participants,
                nowPlaying: MockSessionFixtures.populated.nowPlaying,
                upcoming: MockSessionFixtures.populated.upcoming,
                connectionStatus: MockSessionFixtures.populated.connectionStatus
            )
        case .empty:
            MockSessionFixtures.empty
        case .reconnecting:
            MockSessionFixtures.reconnecting
        }
    }
}
