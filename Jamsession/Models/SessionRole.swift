nonisolated enum SessionRole: String, Hashable, Identifiable, Sendable {
    case host
    case join

    var id: Self { self }
}
