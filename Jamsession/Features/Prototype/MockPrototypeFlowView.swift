import SwiftUI

struct MockPrototypeFlowView: View {
    @State private var step = MockPrototypeStep.welcome
    @State private var permissionRole: MockEntryRole?
    @State private var profileDraft: ProfileDraft?
    @State private var isShowingInvite = false

    var body: some View {
        Group {
            switch step {
            case .welcome:
                MockEntryView { role in
                    step = .profile(role)
                }
            case let .profile(role):
                MockProfileSetupView(role: role) { profileDraft in
                    self.profileDraft = profileDraft
                    permissionRole = role
                }
            case .hostLobby:
                ScrollView {
                    MockHostLobbyView(
                        participants: MockLobbyFixtures.participants,
                        showInvite: { isShowingInvite = true },
                        start: { step = .joinedQueue }
                    )
                    .padding()
                }
                .navigationTitle("mockFlow.hostLobby.title")
                .navigationBarTitleDisplayMode(.inline)
            case .discovery:
                ScrollView {
                    MockDiscoveryView {
                        step = .awaitingApproval
                    }
                    .padding()
                }
                .navigationTitle("mockFlow.discovery.title")
                .navigationBarTitleDisplayMode(.inline)
            case .awaitingApproval:
                VStack {
                    MockAdmissionStatusView(scenario: .awaitingApproval) {}

                    Button("mockFlow.simulateApproval", systemImage: "checkmark.circle") {
                        step = .joinedQueue
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("mock.flow.join.approve")

                    Text("mockFlow.fixtureTransition")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .navigationTitle("mockFlow.awaiting.title")
                .navigationBarTitleDisplayMode(.inline)
            case .joinedQueue:
                MockJoinedQueueView {
                    step = .lifecycle
                }
            case .lifecycle:
                MockLifecycleGalleryView {
                    restart()
                }
            }
        }
        .toolbar {
            if step != .welcome {
                ToolbarItem(placement: .topBarLeading) {
                    Button("mockFlow.restart", systemImage: "arrow.counterclockwise") {
                        restart()
                    }
                    .accessibilityIdentifier("mock.flow.restart")
                }
            }
        }
        .sheet(item: $permissionRole) { role in
            MockPermissionExplainerView(
                role: role,
                displayName: profileDraft?.displayName ?? "",
                onContinue: {
                    permissionRole = nil
                    step = role == .host ? .hostLobby : .discovery
                }
            )
        }
        .sheet(isPresented: $isShowingInvite) {
            MockInviteView()
        }
    }

    private func restart() {
        permissionRole = nil
        isShowingInvite = false
        profileDraft = nil
        step = .welcome
    }
}

#Preview {
    NavigationStack {
        MockPrototypeFlowView()
    }
}
