import SwiftUI

struct HostFlowQueueView: View {
    let session: HostSessionModel
    let returnToLobby: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("host.queue.catalogPending", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                QueueSessionContentView(
                    presentation: session.presentation(viewedBy: session.hostID)
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
    }
}
