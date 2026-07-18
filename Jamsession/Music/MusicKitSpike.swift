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
    private(set) var isHostEligible = false

    private var operationTask: Task<Void, Never>?
    var canPlayFirstResult: Bool {
        isHostEligible && results.first != nil
    }

    var canControlPlayback: Bool {
        isHostEligible
    }

    func startHostTest() {
        runTest(requireSubscription: true)
    }

    func startGuestSearchTest() {
        runTest(requireSubscription: false)
    }

    func queueAndPlayFirstResult() {
        guard isHostEligible else {
            status = "Host playback requires a verified Apple Music subscription."
            return
        }
        guard let song = results.first else {
            status = "Search returned no playable selection."
            return
        }

        replaceTask {
            do {
                let subscription = try await MusicSubscription.current
                guard !Task.isCancelled else {
                    return
                }
                guard subscription.canPlayCatalogContent else {
                    self.isHostEligible = false
                    self.status = "This account can no longer host Apple Music playback."
                    return
                }
                ApplicationMusicPlayer.shared.queue = [song]
                try await ApplicationMusicPlayer.shared.play()
                guard !Task.isCancelled else {
                    return
                }
                self.status = "Playback started. Use Pause and Skip to complete the host check."
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                self.isHostEligible = false
                self.status = "Playback failed: \(error.localizedDescription)"
            }
        }
    }

    func pause() {
        guard isHostEligible else {
            status = "Host playback requires a verified Apple Music subscription."
            return
        }
        replaceTask {
            guard await self.revalidateHostSubscription() else {
                return
            }
            ApplicationMusicPlayer.shared.pause()
            self.status = "Pause requested."
        }
    }

    func skip() {
        guard isHostEligible else {
            status = "Host playback requires a verified Apple Music subscription."
            return
        }
        replaceTask {
            do {
                guard await self.revalidateHostSubscription() else {
                    return
                }
                try await ApplicationMusicPlayer.shared.skipToNextEntry()
                guard !Task.isCancelled else {
                    return
                }
                self.status = "Skip completed."
            } catch {
                guard !Task.isCancelled else {
                    return
                }
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
        isHostEligible = false
        replaceTask {
            let authorization = await MusicAuthorization.request()
            guard !Task.isCancelled else {
                return
            }
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
                    guard !Task.isCancelled else {
                        return
                    }
                    guard subscription.canPlayCatalogContent else {
                        self.status = "Authorization succeeded, but this account cannot host playback."
                        return
                    }
                    self.isHostEligible = true
                } catch {
                    guard !Task.isCancelled else {
                        return
                    }
                    self.status = "Subscription check failed: \(error.localizedDescription)"
                    return
                }
            }

            do {
                var request = MusicCatalogSearchRequest(term: self.query, types: [Song.self])
                request.limit = 10
                let response = try await request.response()
                guard !Task.isCancelled else {
                    return
                }
                self.results = response.songs
                self.status = response.songs.isEmpty
                    ? "Authorization succeeded; catalog search returned no songs."
                    : "Authorization and catalog search succeeded with \(response.songs.count) result(s)."
            } catch {
                guard !Task.isCancelled else {
                    return
                }
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

    private func revalidateHostSubscription() async -> Bool {
        do {
            let subscription = try await MusicSubscription.current
            guard !Task.isCancelled else {
                return false
            }
            guard subscription.canPlayCatalogContent else {
                isHostEligible = false
                status = "This account can no longer host Apple Music playback."
                return false
            }
            return true
        } catch {
            guard !Task.isCancelled else {
                return false
            }
            isHostEligible = false
            status = "Subscription check failed: \(error.localizedDescription)"
            return false
        }
    }
}
