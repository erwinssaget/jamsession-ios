import Foundation
@preconcurrency import MusicKit
import Observation

@Observable
@MainActor
final class MusicKitSpike {
    var query = "The Beatles"
    private(set) var status = "Choose a test. Permission is requested only after your choice."
    private(set) var results: MusicItemCollection<Song> = []
    private(set) var needsSettings = false

    private var operationTask: Task<Void, Never>?
    var canPlayFirstResult: Bool {
        results.first != nil
    }

    func startHostTest() {
        runTest(requireSubscription: true)
    }

    func startGuestSearchTest() {
        runTest(requireSubscription: false)
    }

    func queueAndPlayFirstResult() {
        guard let song = results.first else {
            status = "Search returned no playable selection."
            return
        }

        replaceTask {
            do {
                ApplicationMusicPlayer.shared.queue = [song]
                try await ApplicationMusicPlayer.shared.play()
                self.status = "Playback started. Use Pause and Skip to complete the host check."
            } catch {
                self.status = "Playback failed: \(error.localizedDescription)"
            }
        }
    }

    func pause() {
        ApplicationMusicPlayer.shared.pause()
        status = "Pause requested."
    }

    func skip() {
        replaceTask {
            do {
                try await ApplicationMusicPlayer.shared.skipToNextEntry()
                self.status = "Skip completed."
            } catch {
                self.status = "Skip failed: \(error.localizedDescription)"
            }
        }
    }

    func cancel() {
        operationTask?.cancel()
        operationTask = nil
    }

    private func runTest(requireSubscription: Bool) {
        needsSettings = false
        replaceTask {
            let authorization = await MusicAuthorization.request()
            guard authorization == .authorized else {
                self.needsSettings = true
                self.status = authorization == .restricted
                    ? "Music access is restricted. The mock queue remains available."
                    : "Music access was denied. The mock queue remains available."
                return
            }

            if requireSubscription {
                do {
                    let subscription = try await MusicSubscription.current
                    guard subscription.canPlayCatalogContent else {
                        self.status = "Authorization succeeded, but this account cannot host playback."
                        return
                    }
                } catch {
                    self.status = "Subscription check failed: \(error.localizedDescription)"
                    return
                }
            }

            do {
                var request = MusicCatalogSearchRequest(term: self.query, types: [Song.self])
                request.limit = 10
                let response = try await request.response()
                self.results = response.songs
                self.status = response.songs.isEmpty
                    ? "Authorization succeeded; catalog search returned no songs."
                    : "Authorization and catalog search succeeded with \(response.songs.count) result(s)."
            } catch {
                self.status = "Catalog search failed: \(error.localizedDescription)"
            }
        }
    }

    private func replaceTask(_ operation: @escaping @MainActor @Sendable () async -> Void) {
        operationTask?.cancel()
        operationTask = Task {
            await operation()
        }
    }
}
