import SwiftUI

struct HostLobbyParticipantRow: View {
    let participant: HostLobbyPresentation.Participant
    let position: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text(position, format: .number)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 24)
                    .accessibilityHidden(true)

                Text(participant.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(participant.colorID.color.gradient)
                    .clipShape(.circle)

                VStack(alignment: .leading) {
                    Text(participant.name)
                        .font(.headline)
                    if participant.isHost {
                        Text("host.lobby.participant.host")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(position, format: .number)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    Text(participant.emoji)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(participant.colorID.color.gradient)
                        .clipShape(.circle)
                }

                Text(participant.name)
                    .font(.headline)
                if participant.isHost {
                    Text("host.lobby.participant.host")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            HostLobbyParticipantAccessibility.label(
                for: participant,
                position: position
            )
        )
    }
}
