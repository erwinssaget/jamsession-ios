import SwiftUI

struct MockAdmissionStatusView: View {
    let scenario: MockLobbyScenario
    let retry: () -> Void

    var body: some View {
        switch scenario {
        case .noNearbySessions:
            VStack {
                ContentUnavailableView(
                    "mockLobby.noNearby.title",
                    systemImage: "wifi.slash",
                    description: Text("mockLobby.noNearby.description")
                )
                Button("mockLobby.tryAgain", systemImage: "arrow.clockwise", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        case .awaitingApproval:
            ContentUnavailableView(
                "mockLobby.awaiting.title",
                systemImage: "hourglass",
                description: Text("mockLobby.awaiting.description")
            )
        case .roomFull:
            VStack {
                ContentUnavailableView(
                    "mockLobby.roomFull.title",
                    systemImage: "person.3.fill",
                    description: Text("mockLobby.roomFull.description")
                )
                Button("mockLobby.done", action: retry)
                    .buttonStyle(.bordered)
            }
        case .rejected:
            VStack {
                ContentUnavailableView(
                    "mockLobby.rejected.title",
                    systemImage: "hand.raised.fill",
                    description: Text("mockLobby.rejected.description")
                )
                Button("mockLobby.done", action: retry)
                    .buttonStyle(.bordered)
            }
        default:
            EmptyView()
        }
    }
}
