enum MockEntryRole: String, Hashable, Identifiable {
    case host
    case join

    var id: Self { self }
}
