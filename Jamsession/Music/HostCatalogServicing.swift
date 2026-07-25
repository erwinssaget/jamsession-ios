nonisolated protocol HostCatalogServicing: Sendable {
    func search(for query: String) async throws -> HostCatalogSearchResult
    func resolve(trackID: TrackID) async throws -> CatalogTrackSelection
}
