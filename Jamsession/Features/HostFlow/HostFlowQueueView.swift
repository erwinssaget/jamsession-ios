import SwiftUI

struct HostFlowQueueView: View {
    let session: HostSessionModel
    let catalogSearchModel: HostCatalogSearchModel
    let returnToLobby: () -> Void
    @State private var isShowingCatalog = false

    var body: some View {
        ScrollView {
            QueueSessionContentView(
                presentation: session.presentation(viewedBy: session.hostID),
                addMusic: { isShowingCatalog = true }
            )
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
    }
}
