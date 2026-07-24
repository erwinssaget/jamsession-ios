import SwiftUI

struct MockLobbyGalleryView: View {
    @State private var scenario = MockLobbyScenario.hostLobby
    @State private var isShowingInvite = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("mockLobby.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                switch scenario {
                case .hostLobby:
                    MockHostLobbyView(
                        participants: MockLobbyFixtures.participants,
                        showInvite: { isShowingInvite = true },
                        start: nil
                    )
                case .approvalRequest:
                    MockApprovalRequestView(
                        participant: MockLobbyFixtures.pendingParticipant,
                        approve: { scenario = .hostLobby },
                        reject: { scenario = .rejected }
                    )
                case .discovery:
                    MockDiscoveryView {
                        scenario = .awaitingApproval
                    }
                case .noNearbySessions, .awaitingApproval, .roomFull, .rejected:
                    MockAdmissionStatusView(scenario: scenario) {
                        scenario = .discovery
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("mockLobby.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("mockLobby.previewState", systemImage: "slider.horizontal.3") {
                    Picker("mockLobby.previewState", selection: $scenario) {
                        ForEach(MockLobbyScenario.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey))
                                .tag(option)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingInvite) {
            MockInviteView()
        }
    }
}

#Preview {
    NavigationStack {
        MockLobbyGalleryView()
    }
}
