import Foundation
import Testing
@testable import Jamsession

@MainActor
struct HostCatalogSearchModelTests {
    @Test
    func blankQueryStaysIdleWithoutCallingService() async {
        let service = CountingCatalogService()
        let model = HostCatalogSearchModel(service: service, debounce: .zero)

        await model.search(for: "   ")

        #expect(model.state == .idle)
        #expect(await service.searchCount == 0)
    }

    @Test
    func searchPublishesHostStorefrontResults() async {
        let result = HostCatalogSearchResult(
            storefrontCountryCode: "US",
            tracks: [authoritativeTrack]
        )
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(searchResult: result),
            debounce: .zero
        )

        await model.search(for: "Midnight")

        #expect(model.state == .results(result))
    }

    @Test
    func emptySearchPublishesTrimmedQuery() async {
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(
                searchResult: HostCatalogSearchResult(
                    storefrontCountryCode: "US",
                    tracks: []
                )
            ),
            debounce: .zero
        )

        await model.search(for: "  Unknown Song  ")

        #expect(model.state == .empty(query: "Unknown Song"))
    }

    @Test
    func typedSearchFailureIsPreservedForRecoveryUI() async {
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(searchError: .offline),
            debounce: .zero
        )

        await model.search(for: "Midnight")

        #expect(model.state == .failure(.offline))
    }

    @Test
    func staleSearchResponseCannotReplaceNewerResults() async throws {
        let model = HostCatalogSearchModel(
            service: OutOfOrderCatalogService(),
            debounce: .zero
        )

        let oldSearch = Task {
            await model.search(for: "Old")
        }
        try await Task.sleep(for: .milliseconds(10))
        await model.search(for: "New")
        await oldSearch.value

        #expect(
            model.state == .results(
                HostCatalogSearchResult(
                    storefrontCountryCode: "US",
                    tracks: [Self.newTrack]
                )
            )
        )
    }

    @Test
    func submissionReResolvesMetadataBeforeAuthoritativeQueueMutation() async {
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(resolvedTrack: authoritativeTrack),
            debounce: .zero
        )
        let session = makeSession()
        let staleSelection = CatalogTrackSelection(
            id: authoritativeTrack.id,
            title: "Stale Title",
            artistName: "Stale Artist"
        )

        await model.submit(staleSelection, to: session)

        #expect(model.submissionOutcome == .accepted)
        let upcoming = session.presentation(viewedBy: session.hostID).upcoming
        #expect(upcoming.first?.title == "Midnight Drive")
        #expect(upcoming.first?.artist == "Nova Lane")
    }

    @Test
    func duplicateSubmissionReturnsTypedFairnessRejection() async {
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(resolvedTrack: authoritativeTrack),
            debounce: .zero
        )
        let session = makeSession()

        await model.submit(authoritativeTrack, to: session)
        await model.submit(authoritativeTrack, to: session)

        #expect(model.submissionOutcome == .fairnessRejected(.duplicate))
        #expect(
            session.presentation(viewedBy: session.hostID).upcoming.count == 1
        )
    }

    @Test
    func failedStorefrontResolutionDoesNotMutateQueue() async {
        let model = HostCatalogSearchModel(
            service: ImmediateCatalogService(resolveError: .trackUnavailable),
            debounce: .zero
        )
        let session = makeSession()

        await model.submit(authoritativeTrack, to: session)

        #expect(
            model.submissionOutcome == .catalogRejected(.trackUnavailable)
        )
        #expect(
            session.presentation(viewedBy: session.hostID).upcoming.isEmpty
        )
    }

    @Test
    func invalidationIgnoresInFlightSearchAndClearsEphemeralUIState() async throws {
        let model = HostCatalogSearchModel(
            service: DelayedCatalogService(),
            debounce: .zero
        )

        let search = Task {
            await model.search(for: "Midnight")
        }
        try await Task.sleep(for: .milliseconds(10))
        model.invalidateRequests()
        await search.value

        #expect(model.state == .idle)
        #expect(model.submissionOutcome == nil)
        #expect(model.isSubmitting == false)
    }

    nonisolated private var authoritativeTrack: CatalogTrackSelection {
        Self.authoritativeTrack
    }

    nonisolated private static var authoritativeTrack: CatalogTrackSelection {
        CatalogTrackSelection(
            id: TrackID("song-midnight"),
            title: "Midnight Drive",
            artistName: "Nova Lane"
        )
    }

    nonisolated private static var newTrack: CatalogTrackSelection {
        CatalogTrackSelection(
            id: TrackID("song-new"),
            title: "New Result",
            artistName: "Current Artist"
        )
    }

    private func makeSession() -> HostSessionModel {
        let hostID = ParticipantID("host")
        return HostSessionModel(
            sessionName: "Test Session",
            roomCode: "TEST",
            participants: [
                SessionParticipant(
                    id: hostID,
                    displayName: "Maya",
                    emoji: "🎸",
                    colorID: .orange
                )
            ],
            hostID: hostID
        )
    }

    private struct ImmediateCatalogService: HostCatalogServicing {
        var searchResult = HostCatalogSearchResult(
            storefrontCountryCode: "US",
            tracks: []
        )
        var searchError: HostCatalogServiceError?
        var resolvedTrack = HostCatalogSearchModelTests.authoritativeTrack
        var resolveError: HostCatalogServiceError?

        func search(for query: String) async throws -> HostCatalogSearchResult {
            if let searchError {
                throw searchError
            }
            return searchResult
        }

        func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
            if let resolveError {
                throw resolveError
            }
            return resolvedTrack
        }
    }

    private actor CountingCatalogService: HostCatalogServicing {
        private(set) var searchCount = 0

        func search(for query: String) async throws -> HostCatalogSearchResult {
            searchCount += 1
            return HostCatalogSearchResult(
                storefrontCountryCode: "US",
                tracks: []
            )
        }

        func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
            throw HostCatalogServiceError.trackUnavailable
        }
    }

    private struct OutOfOrderCatalogService: HostCatalogServicing {
        func search(for query: String) async throws -> HostCatalogSearchResult {
            if query == "Old" {
                try? await Task.sleep(for: .milliseconds(100))
                return HostCatalogSearchResult(
                    storefrontCountryCode: "GB",
                    tracks: [
                        CatalogTrackSelection(
                            id: TrackID("song-old"),
                            title: "Old Result",
                            artistName: "Past Artist"
                        )
                    ]
                )
            }

            return HostCatalogSearchResult(
                storefrontCountryCode: "US",
                tracks: [HostCatalogSearchModelTests.newTrack]
            )
        }

        func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
            throw HostCatalogServiceError.trackUnavailable
        }
    }

    private struct DelayedCatalogService: HostCatalogServicing {
        func search(for query: String) async throws -> HostCatalogSearchResult {
            try? await Task.sleep(for: .milliseconds(100))
            return HostCatalogSearchResult(
                storefrontCountryCode: "US",
                tracks: [HostCatalogSearchModelTests.authoritativeTrack]
            )
        }

        func resolve(trackID: TrackID) async throws -> CatalogTrackSelection {
            throw HostCatalogServiceError.trackUnavailable
        }
    }
}
