import SwiftUI

struct HostFlowQueueView: View {
    let session: HostSessionModel
    let catalogSearchModel: HostCatalogSearchModel
    let hostPlayer: HostPlayer
    let returnToLobby: () -> Void
    let endSession: () -> Void
    @State private var isShowingCatalog = false
    @State private var isConfirmingEnd = false
    @State private var removalOutcome: QueueCommandOutcome?
    @State private var reconciliationAttemptID = UUID()
    @State private var controlRequest: ControlRequest?

    var body: some View {
        let queuePresentation = session.presentation(viewedBy: session.hostID)

        ScrollView {
            VStack {
                if case .failed(let error) = hostPlayer.state {
                    HostPlaybackFailureView(
                        presentation: HostPlaybackFailurePresentationMapper.map(error),
                        retry: retryReconciliation
                    )
                }

                if let controls = HostPlaybackControlsPresentationMapper.map(
                    queue: queuePresentation,
                    currentItemID: hostPlayer.currentItemID,
                    playbackStatus: hostPlayer.playbackStatus,
                    playerState: hostPlayer.state,
                    isControlRequestInFlight: hostPlayer.isControlRequestInFlight
                ) {
                    HostPlaybackControlsView(
                        presentation: controls,
                        playOrPause: playOrPause,
                        skip: requestSkip
                    )
                }

                QueueSessionContentView(
                    presentation: queuePresentation,
                    addMusic: { isShowingCatalog = true },
                    removeTrack: removeTrack,
                    showsNowPlaying: false
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

            ToolbarItem(placement: .topBarTrailing) {
                Button("host.end.button", systemImage: "xmark.circle") {
                    isConfirmingEnd = true
                }
                .tint(.red)
                .accessibilityIdentifier("host.end.button")
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
        .task {
            await hostPlayer.observePlaybackTransitions(for: session)
        }
        .task(id: controlRequest) {
            guard let request = controlRequest else {
                return
            }

            switch request.action {
            case .play:
                await hostPlayer.play()
            case .skip:
                await hostPlayer.skipCurrentTrack()
            }

            if controlRequest == request {
                controlRequest = nil
            }
        }
        .confirmationDialog(
            "host.end.confirm.title",
            isPresented: $isConfirmingEnd,
            titleVisibility: .visible
        ) {
            Button("host.end.confirm.action", role: .destructive) {
                endSession()
            }
            .accessibilityIdentifier("host.end.confirm")

            Button("host.end.cancel", role: .cancel) {
            }
            .accessibilityIdentifier("host.end.cancel")
        } message: {
            Text("host.end.confirm.message")
        }
        .safeAreaInset(edge: .bottom) {
            if let removalOutcome {
                QueueCommandFeedbackView(
                    presentation: QueueCommandFeedbackPresentation.map(removalOutcome),
                    dismiss: { self.removalOutcome = nil }
                )
                .padding()
            }
        }
    }

    private func removeTrack(_ submissionID: SubmissionID) {
        removalOutcome = session.handle(
            QueueCommand(
                id: FairnessEventID("host-remove-\(UUID().uuidString)"),
                participantID: session.hostID,
                action: .removePending(submissionID)
            )
        )
    }

    private func retryReconciliation() {
        reconciliationAttemptID = UUID()
    }

    private func playOrPause() {
        if hostPlayer.playbackStatus.isActivelyPlaying {
            hostPlayer.pause()
        } else {
            requestControl(.play)
        }
    }

    private func requestSkip() {
        requestControl(.skip)
    }

    private func requestControl(_ action: ControlAction) {
        guard controlRequest == nil else {
            return
        }
        controlRequest = ControlRequest(id: UUID(), action: action)
    }

    private struct ReconciliationTaskID: Equatable {
        let queueRevision: Int
        let attemptID: UUID
    }

    private struct ControlRequest: Equatable {
        let id: UUID
        let action: ControlAction
    }

    private enum ControlAction: Equatable {
        case play
        case skip
    }
}
