#if DEBUG
import Foundation

struct DebugHostCatalogService: HostCatalogServicing {
    private let tracks = [
        CatalogTrackSelection(
            id: TrackID("debug-midnight-drive"),
            title: "Midnight Drive",
            artistName: "Nova Lane"
        ),
        CatalogTrackSelection(
            id: TrackID("debug-golden-hour"),
            title: "Golden Hour",
            artistName: "The Daylights",
            isExplicit: true
        )
    ]

    func search(for query: String) async throws -> HostCatalogSearchResult {
        HostCatalogSearchResult(
            storefrontCountryCode: "US",
            tracks: tracks.filter {
                $0.title.localizedStandardContains(query)
                    || $0.artistName.localizedStandardContains(query)
            }
        )
    }

    func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
        guard let track = tracks.first(where: { $0.id == trackID }) else {
            throw HostCatalogServiceError.trackUnavailable
        }
        return track
    }
}
#endif
