import SwiftUI

struct HostFlowQueueView: View {
    let session: HostSessionModel
    let catalogSearchModel: HostCatalogSearchModel
    let hostPlayer: HostPlayer
    let returnToLobby: () -> Void
    @State private var isShowingCatalog = false
    @State private var reconciliationAttemptID = UUID()

    var body: some View {
        ScrollView {
            VStack {
                if case .failed(let error) = hostPlayer.state {
                    HostPlaybackFailureView(
                        presentation: HostPlaybackFailurePresentationMapper.map(error),
                        retry: retryReconciliation
                    )
                }

                QueueSessionContentView(
                    presentation: session.presentation(viewedBy: session.hostID),
                    addMusic: { isShowingCatalog = true }
                )
            }
            .padding()
        }
        .navigationTitle("host.queue.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    "host.queue.returnToLobby",
                    systemImage: "person.2",
                    action: returnToLobby
                )
                .accessibilityIdentifier("host.flow.queue.lobby")
            }
        }
        .sheet(isPresented: $isShowingCatalog) {
            NavigationStack {
                HostCatalogSearchView(
                    model: catalogSearchModel,
                    session: session
                )
            }
        }
        .task(
            id: ReconciliationTaskID(
                queueRevision: session.queueRevision,
                attemptID: reconciliationAttemptID
            )
        ) {
            await hostPlayer.reconcile(with: session.playbackQueueItems)
        }
    }

    private func retryReconciliation() {
        reconciliationAttemptID = UUID()
    }

    private struct ReconciliationTaskID: Equatable {
        let queueRevision: Int
        let attemptID: UUID
    }
}
