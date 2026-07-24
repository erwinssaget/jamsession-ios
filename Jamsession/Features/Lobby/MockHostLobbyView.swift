import SwiftUI

struct MockHostLobbyView: View {
    let participants: [MockLobbyParticipant]
    let showInvite: () -> Void
    var start: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("mockLobby.host.title")
                    .font(.title2)
                    .bold()
                Text("mockLobby.host.roomCode")
                    .font(.title3.monospaced())
                    .foregroundStyle(.secondary)
                Text("mockLobby.host.orderExplanation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("mockLobby.invite.button", systemImage: "qrcode") {
                showInvite()
            }
            .buttonStyle(.bordered)

            Text("mockLobby.participants.title")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            ForEach(participants.enumerated(), id: \.element.id) { index, participant in
                MockLobbyParticipantRow(participant: participant, position: index + 1)
                if participant.id != participants.last?.id {
                    Divider()
                }
            }

            Button("mockLobby.host.start", systemImage: "play.fill") {
                start?()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(start == nil)
            .accessibilityIdentifier("mock.flow.host.start")

            Text("mockLobby.fixtureNotice")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
