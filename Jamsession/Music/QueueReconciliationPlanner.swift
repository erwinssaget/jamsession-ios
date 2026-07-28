nonisolated struct QueueReconciliationPlanner: Sendable {
    func plan(
        from snapshot: PlaybackQueueSnapshot,
        to desiredItems: [PlaybackQueueItem]
    ) throws(QueueReconciliationPlanningError) -> QueueReconciliationPlan {
        guard identitiesAreUnique(in: snapshot.items),
              identitiesAreUnique(in: desiredItems) else {
            throw .duplicateItemIdentity
        }

        let mutableStartIndex: Int
        if let protectedItemID = snapshot.protectedItemID {
            guard snapshot.items.first?.id == protectedItemID,
                  desiredItems.first == snapshot.items.first else {
                throw .protectedItemMismatch
            }
            mutableStartIndex = 1
        } else {
            mutableStartIndex = 0
        }

        var workingItems = snapshot.items
        var operations: [QueueReconciliationOperation] = []

        if mutableStartIndex < desiredItems.count {
            for targetIndex in mutableStartIndex..<desiredItems.count {
                let desiredItem = desiredItems[targetIndex]

                while targetIndex < workingItems.count,
                      workingItems[targetIndex] != desiredItem {
                    let currentItem = workingItems[targetIndex]
                    let currentItemIsStillNeeded = desiredItems[targetIndex...]
                        .contains(currentItem)
                    guard !currentItemIsStillNeeded else {
                        break
                    }

                    workingItems.remove(at: targetIndex)
                    operations.append(.remove(currentItem.id, at: targetIndex))
                }

                if targetIndex < workingItems.count,
                   workingItems[targetIndex] == desiredItem {
                    continue
                }

                if let sourceIndex = workingItems[targetIndex...]
                    .firstIndex(of: desiredItem) {
                    let item = workingItems.remove(at: sourceIndex)
                    workingItems.insert(item, at: targetIndex)
                    operations.append(
                        .move(item.id, from: sourceIndex, to: targetIndex)
                    )
                    continue
                }

                if let staleIndex = workingItems.firstIndex(where: {
                    $0.id == desiredItem.id
                }) {
                    let staleItem = workingItems.remove(at: staleIndex)
                    operations.append(.remove(staleItem.id, at: staleIndex))
                }

                workingItems.insert(desiredItem, at: targetIndex)
                operations.append(.insert(desiredItem, at: targetIndex))
            }
        }

        if workingItems.count > desiredItems.count {
            for index in stride(
                from: workingItems.count - 1,
                through: desiredItems.count,
                by: -1
            ) {
                guard index >= mutableStartIndex else {
                    throw .protectedItemMismatch
                }
                let removedItem = workingItems.remove(at: index)
                operations.append(.remove(removedItem.id, at: index))
            }
        }

        return QueueReconciliationPlan(
            originalSnapshot: snapshot,
            desiredItems: desiredItems,
            operations: operations
        )
    }

    private func identitiesAreUnique(in items: [PlaybackQueueItem]) -> Bool {
        Set(items.map(\.id)).count == items.count
    }
}
