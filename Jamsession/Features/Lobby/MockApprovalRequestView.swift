import SwiftUI

struct MockApprovalRequestView: View {
    let participant: MockLobbyParticipant
    let approve: () -> Void
    let reject: () -> Void

    var body: some View {
        VStack {
            Text(participant.emoji)
                .font(.largeTitle)
                .frame(width: 88, height: 88)
                .background(.tint.opacity(0.14))
                .clipShape(.circle)

            Text("mockLobby.approval.title")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            Text(
                String(
                    localized: "mockLobby.approval.description",
                    defaultValue: "\(participant.name) wants to join this session."
                )
            )
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack {
                    Button("mockLobby.approval.reject", role: .destructive, action: reject)
                        .buttonStyle(.bordered)
                    Button("mockLobby.approval.approve", systemImage: "checkmark", action: approve)
                        .buttonStyle(.borderedProminent)
                }

                VStack {
                    Button("mockLobby.approval.approve", systemImage: "checkmark", action: approve)
                        .buttonStyle(.borderedProminent)
                    Button("mockLobby.approval.reject", role: .destructive, action: reject)
                        .buttonStyle(.bordered)
                }
            }

            Text("mockLobby.approval.fixtureNotice")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

#Preview {
    ScrollView {
        MockApprovalRequestView(
            participant: MockLobbyFixtures.pendingParticipant,
            approve: {},
            reject: {}
        )
        .padding()
    }
}
