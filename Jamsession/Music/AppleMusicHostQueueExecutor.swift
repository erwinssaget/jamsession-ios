import Foundation
import MusicKit

@MainActor
final class AppleMusicHostQueueExecutor: HostQueueExecuting {
    private let player: ApplicationMusicPlayer
    private var itemsByEntryID: [String: PlaybackQueueItem] = [:]

    init(player: ApplicationMusicPlayer = .shared) {
        self.player = player
    }

    func snapshot() -> PlaybackQueueSnapshot {
        let context = queueContext()
        return PlaybackQueueSnapshot(
            items: context.items,
            protectedItemID: context.protectedItemID
        )
    }

    func apply(_ plan: QueueReconciliationPlan) async throws {
        guard snapshot() == plan.originalSnapshot else {
            throw HostPlaybackError.queueChanged
        }
        guard !plan.operations.isEmpty else {
            return
        }

        let insertedEntries = try await resolveInsertedEntries(in: plan)
        try Task.checkCancellation()

        var context = queueContext()
        guard PlaybackQueueSnapshot(
            items: context.items,
            protectedItemID: context.protectedItemID
        ) == plan.originalSnapshot else {
            throw HostPlaybackError.queueChanged
        }

        for operation in plan.operations {
            try apply(
                operation,
                entries: &context.entries,
                items: &context.items,
                insertedEntries: insertedEntries
            )
        }

        guard context.items == plan.desiredItems else {
            throw HostPlaybackError.queueChanged
        }

        let originalCurrentEntry = player.queue.currentEntry
        let prefix = Array(player.queue.entries.prefix(context.mutableStartIndex))
        let updatedEntries = prefix + context.entries
        player.queue.entries = .init(updatedEntries)

        if let originalCurrentEntry,
           updatedEntries.contains(where: { $0.id == originalCurrentEntry.id }) {
            player.queue.currentEntry = originalCurrentEntry
        } else {
            player.queue.currentEntry = updatedEntries.first
        }

        itemsByEntryID = Dictionary(
            uniqueKeysWithValues: zip(context.entries, context.items).map {
                ($0.id, $1)
            }
        )
    }

    func pause() {
        player.pause()
    }

    private func queueContext() -> QueueContext {
        let allEntries = Array(player.queue.entries)
        let currentEntryID = player.queue.currentEntry?.id
        let protectsCurrentEntry = currentEntryID != nil && player.state.playbackStatus != .stopped
        let mutableStartIndex: Int

        if protectsCurrentEntry,
           let currentEntryID,
           let currentIndex = allEntries.firstIndex(where: { $0.id == currentEntryID }) {
            mutableStartIndex = currentIndex
        } else {
            mutableStartIndex = 0
        }

        let entries = Array(allEntries.dropFirst(mutableStartIndex))
        let items = entries.map(playbackItem)
        return QueueContext(
            mutableStartIndex: mutableStartIndex,
            entries: entries,
            items: items,
            protectedItemID: protectsCurrentEntry ? items.first?.id : nil
        )
    }

    private func playbackItem(
        for entry: MusicPlayer.Queue.Entry
    ) -> PlaybackQueueItem {
        if let item = itemsByEntryID[entry.id] {
            return item
        }

        let trackID = entry.item?.id.rawValue ?? "unresolved-\(entry.id)"
        return PlaybackQueueItem(
            id: SubmissionID("player-entry-\(entry.id)"),
            trackID: TrackID(trackID)
        )
    }

    private func resolveInsertedEntries(
        in plan: QueueReconciliationPlan
    ) async throws -> [SubmissionID: MusicPlayer.Queue.Entry] {
        let insertedItems = plan.operations.compactMap { operation in
            if case .insert(let item, _) = operation {
                item
            } else {
                nil
            }
        }
        guard !insertedItems.isEmpty else {
            return [:]
        }

        try await verifyHostEligibility()
        var result: [SubmissionID: MusicPlayer.Queue.Entry] = [:]
        for item in insertedItems {
            try Task.checkCancellation()
            result[item.id] = MusicPlayer.Queue.Entry(
                try await resolveSong(trackID: item.trackID)
            )
        }
        return result
    }

    private func resolveSong(trackID: TrackID) async throws -> Song {
        do {
            var request = MusicCatalogResourceRequest<Song>(
                matching: \.id,
                equalTo: MusicItemID(trackID.rawValue)
            )
            request.limit = 1
            let response = try await request.response()
            try Task.checkCancellation()
            guard let song = response.items.first,
                  song.playParameters != nil else {
                throw HostPlaybackError.trackUnavailable
            }
            return song
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HostPlaybackError {
            throw error
        } catch let error as URLError where error.isPlaybackOffline {
            throw HostPlaybackError.offline
        } catch {
            throw HostPlaybackError.unavailable
        }
    }

    private func verifyHostEligibility() async throws {
        guard MusicAuthorization.currentStatus == .authorized else {
            throw HostPlaybackError.authorizationRequired
        }

        do {
            let subscription = try await MusicSubscription.current
            try Task.checkCancellation()
            guard subscription.canPlayCatalogContent else {
                throw HostPlaybackError.subscriptionRequired
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HostPlaybackError {
            throw error
        } catch {
            throw HostPlaybackError.unavailable
        }
    }

    private func apply(
        _ operation: QueueReconciliationOperation,
        entries: inout [MusicPlayer.Queue.Entry],
        items: inout [PlaybackQueueItem],
        insertedEntries: [SubmissionID: MusicPlayer.Queue.Entry]
    ) throws {
        switch operation {
        case .insert(let item, let index):
            guard items.indices.contains(index) || index == items.endIndex,
                  let entry = insertedEntries[item.id] else {
                throw HostPlaybackError.queueChanged
            }
            entries.insert(entry, at: index)
            items.insert(item, at: index)
        case .move(let id, let sourceIndex, let targetIndex):
            guard items.indices.contains(sourceIndex),
                  items[sourceIndex].id == id,
                  items.indices.contains(targetIndex) || targetIndex == items.endIndex else {
                throw HostPlaybackError.queueChanged
            }
            let entry = entries.remove(at: sourceIndex)
            let item = items.remove(at: sourceIndex)
            entries.insert(entry, at: targetIndex)
            items.insert(item, at: targetIndex)
        case .remove(let id, let index):
            guard items.indices.contains(index),
                  items[index].id == id else {
                throw HostPlaybackError.queueChanged
            }
            entries.remove(at: index)
            items.remove(at: index)
        }
    }

    private struct QueueContext {
        let mutableStartIndex: Int
        var entries: [MusicPlayer.Queue.Entry]
        var items: [PlaybackQueueItem]
        let protectedItemID: SubmissionID?
    }
}

private extension URLError {
    var isPlaybackOffline: Bool {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            true
        default:
            false
        }
    }
}
