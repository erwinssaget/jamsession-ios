nonisolated enum MockSearchScenario: String, CaseIterable, Identifiable {
    case idle
    case loading
    case results
    case empty
    case musicAccessDenied
    case offline
    case failed

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .idle:
            "mockSearch.scenario.idle"
        case .loading:
            "mockSearch.scenario.loading"
        case .results:
            "mockSearch.scenario.results"
        case .empty:
            "mockSearch.scenario.empty"
        case .musicAccessDenied:
            "mockSearch.scenario.denied"
        case .offline:
            "mockSearch.scenario.offline"
        case .failed:
            "mockSearch.scenario.failed"
        }
    }
}
