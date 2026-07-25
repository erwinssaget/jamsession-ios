import SwiftUI

struct HostLobbyView: View {
    let presentation: HostLobbyPresentation
    let start: () -> Void
    let cancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(presentation.sessionName)
                        .font(.title2)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    Text(
                        String(
                            localized: "host.lobby.roomCode",
                            defaultValue: "Room \(presentation.roomCode)"
                        )
                    )
                    .font(.title3.monospaced())
                    .foregroundStyle(.secondary)
                    Text("host.lobby.ready")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("host.lobby.participants")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                ForEach(presentation.participants.enumerated(), id: \.element.id) {
                    index,
                    participant in
                    HostLobbyParticipantRow(
                        participant: participant,
                        position: index + 1
                    )
                    if participant.id != presentation.participants.last?.id {
                        Divider()
                    }
                }

                Label("host.lobby.soloReady", systemImage: "person.fill.checkmark")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("host.lobby.start", systemImage: "play.fill", action: start)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("host.flow.lobby.start")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("host.lobby.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("host.flow.cancel", action: cancel)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostLobbyView(
            presentation: HostLobbyPresentation(
                sessionName: "Maya’s Session",
                roomCode: "A17F",
                participants: [
                    HostLobbyPresentation.Participant(
                        id: ParticipantID("preview-host"),
                        name: "Maya",
                        emoji: "🎸",
                        colorID: .orange,
                        isHost: true
                    )
                ]
            ),
            start: {},
            cancel: {}
        )
    }
}
