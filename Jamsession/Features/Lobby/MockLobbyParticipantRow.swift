import SwiftUI

struct MockLobbyParticipantRow: View {
    let participant: MockLobbyParticipant
    let position: Int?

    var body: some View {
        HStack {
            if let position {
                Text(position, format: .number)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 24)
                    .accessibilityHidden(true)
            }

            Text(participant.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(.tint.opacity(0.14))
                .clipShape(.circle)

            VStack(alignment: .leading) {
                Text(participant.name)
                    .font(.headline)
                Text(LocalizedStringKey(participant.detailKey))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            position.map {
                String(
                    localized: "mockLobby.participant.position",
                    defaultValue: "Position \($0), \(participant.name)"
                )
            } ?? participant.name
        )
    }
}
