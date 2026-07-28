import SwiftUI

struct ParticipantBadgeView: View {
    let participant: QueueSessionPresentation.Participant
    var showsName = false

    var body: some View {
        HStack(spacing: 6) {
            Text(participant.emoji)
                .frame(width: 32, height: 32)
                .background(participant.colorID.color.gradient)
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
                ? String(localized: "queue.participant.you")
                : participant.name
        )
    }
}
