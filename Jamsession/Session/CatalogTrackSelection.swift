nonisolated struct CatalogTrackSelection: Identifiable, Sendable, Equatable {
    let id: TrackID
    let title: String
    let artistName: String
    let isExplicit: Bool

    init(
        id: TrackID,
        title: String,
        artistName: String,
        isExplicit: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.isExplicit = isExplicit
    }
}
