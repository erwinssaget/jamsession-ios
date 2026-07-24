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
        .accessibilityLabel(accessibilityDescription)
    }

    var accessibilityDescription: String {
        let detail = String(localized: String.LocalizationValue(participant.detailKey))

        if let position {
            return String(
                localized: "mockLobby.participant.position",
                defaultValue: "Position \(position), \(participant.name), \(detail)"
            )
        }

        return String(
            localized: "mockLobby.participant.accessibility",
            defaultValue: "\(participant.name), \(detail)"
        )
    }
}
