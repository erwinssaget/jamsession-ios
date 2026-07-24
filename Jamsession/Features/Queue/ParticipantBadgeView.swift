import SwiftUI

struct ParticipantBadgeView: View {
    let participant: MockSessionPresentation.Participant
    var showsName = false

    var body: some View {
        HStack(spacing: 6) {
            Text(participant.emoji)
                .frame(width: 32, height: 32)
                .background(participant.color.swiftUIColor.gradient)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(.background, lineWidth: 2)
                }

            if showsName {
                Text(participant.name)
                    .font(.subheadline)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            participant.isCurrentUser
                ? String(localized: "mockQueue.participant.you")
                : participant.name
        )
    }
}

private extension MockSessionPresentation.ParticipantColor {
    var swiftUIColor: Color {
        switch self {
        case .blue:
            .blue
        case .green:
            .green
        case .orange:
            .orange
        case .purple:
            .purple
        }
    }
}
