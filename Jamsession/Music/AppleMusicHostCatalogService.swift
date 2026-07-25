import Foundation
import MusicKit

actor AppleMusicHostCatalogService: HostCatalogServicing {
    func search(for query: String) async throws -> HostCatalogSearchResult {
        do {
            try await verifyHostEligibility()
            let storefrontCountryCode = try await currentStorefrontCountryCode()

            var request = MusicCatalogSearchRequest(
                term: query,
                types: [Song.self]
            )
            request.limit = 20
            let response = try await request.response()
            try Task.checkCancellation()

            return HostCatalogSearchResult(
                storefrontCountryCode: storefrontCountryCode,
                tracks: response.songs.map(AppleMusicCatalogTrackMapper.map)
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HostCatalogServiceError {
            throw error
        } catch let error as URLError where error.isOffline {
            throw HostCatalogServiceError.offline
        } catch {
            throw HostCatalogServiceError.unavailable
        }
    }

    func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
        do {
            try await verifyHostEligibility()
            _ = try await currentStorefrontCountryCode()

            var request = MusicCatalogResourceRequest<Song>(
                matching: \.id,
                equalTo: MusicItemID(trackID.rawValue)
            )
            request.limit = 1
            let response = try await request.response()
            try Task.checkCancellation()

            guard let song = response.items.first,
                  song.playParameters != nil else {
                throw HostCatalogServiceError.trackUnavailable
            }

            return AppleMusicCatalogTrackMapper.map(song)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HostCatalogServiceError {
            throw error
        } catch let error as URLError where error.isOffline {
            throw HostCatalogServiceError.offline
        } catch {
            throw HostCatalogServiceError.unavailable
        }
    }

    private func verifyHostEligibility() async throws {
        guard MusicAuthorization.currentStatus == .authorized else {
            throw HostCatalogServiceError.authorizationRequired
        }

        let subscription = try await MusicSubscription.current
        try Task.checkCancellation()
        guard subscription.canPlayCatalogContent else {
            throw HostCatalogServiceError.subscriptionRequired
        }
    }

    private func currentStorefrontCountryCode() async throws -> String {
        let countryCode = try await MusicDataRequest.currentCountryCode
        try Task.checkCancellation()
        return countryCode
    }
}

private extension URLError {
    var isOffline: Bool {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            true
        default:
            false
        }
    }
}
