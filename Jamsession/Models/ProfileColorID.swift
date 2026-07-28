nonisolated enum ProfileColorID: String, CaseIterable, Identifiable, Sendable {
    case purple
    case blue
    case green
    case orange

    var id: Self { self }
}
