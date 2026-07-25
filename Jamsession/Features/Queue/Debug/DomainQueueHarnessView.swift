#if DEBUG
import SwiftUI

struct DomainQueueHarnessView: View {
    @State private var session = DomainQueueHarnessFixtures.makeSession()
    @State private var isShowingCatalog = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("queue.harness.notice", systemImage: "function")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)

                QueueSessionContentView(
                    presentation: session.presentation(
                        viewedBy: DomainQueueHarnessFixtures.hostID
                    ),
                    addMusic: { isShowingCatalog = true },
                    removeTrack: removeTrack,
                    skipTurn: { _ in skipNextTurn() }
                )
            }
            .padding()
        }
        .navigationTitle("queue.harness.title")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let outcome = session.lastCommandOutcome {
                QueueCommandFeedbackView(
                    presentation: QueueCommandFeedbackPresentation.map(outcome),
                    dismiss: session.dismissLastCommandOutcome
                )
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("queue.advance", systemImage: "forward.end") {
                    send(.advancePlayback)
                }
                .accessibilityIdentifier("queue.harness.advance")

                Button("queue.harness.reset", systemImage: "arrow.counterclockwise") {
                    session = DomainQueueHarnessFixtures.makeSession()
                }
            }
        }
        .sheet(isPresented: $isShowingCatalog) {
            NavigationStack {
                DomainQueueCatalogView(
                    tracks: DomainQueueHarnessFixtures.catalog,
                    commandOutcome: session.lastCommandOutcome,
                    add: submit,
                    dismissCommandOutcome: session.dismissLastCommandOutcome
                )
            }
        }
    }

    private func submit(_ selection: CatalogTrackSelection) {
        let token = UUID().uuidString
        send(
            .submit(
                selection: selection,
                submissionID: SubmissionID("submission-\(token)")
            ),
            commandID: "submit-\(token)"
        )
    }

    private func removeTrack(_ submissionID: SubmissionID) {
        send(
            .removePending(submissionID),
            commandID: "remove-\(UUID().uuidString)"
        )
    }

    private func skipNextTurn() {
        send(
            .skipNextTurn,
            commandID: "skip-\(UUID().uuidString)"
        )
    }

    private func send(
        _ action: QueueCommand.Action,
        commandID: String = "command-\(UUID().uuidString)"
    ) {
        session.handle(
            QueueCommand(
                id: FairnessEventID(commandID),
                participantID: DomainQueueHarnessFixtures.hostID,
                action: action
            )
        )
    }
}

#Preview {
    NavigationStack {
        DomainQueueHarnessView()
    }
}
#endif
