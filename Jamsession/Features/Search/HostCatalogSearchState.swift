nonisolated enum HostCatalogSearchState: Equatable, Sendable {
    case idle
    case loading
    case results(HostCatalogSearchResult)
    case empty(query: String)
    case failure(HostCatalogServiceError)
}
