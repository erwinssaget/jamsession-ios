import SwiftUI

struct MockParticipantGoneView: View {
    var body: some View {
        VStack(alignment: .leading) {
            MockLifecycleStatusCard(
                title: "mockLifecycle.gone.title",
                description: "mockLifecycle.gone.description",
                systemImage: "wifi.exclamationmark",
                tint: .orange
            )

            MockLobbyParticipantRow(
                participant: MockLobbyParticipant(
                    id: MockLobbyFixtures.participants[2].id,
                    name: MockLobbyFixtures.participants[2].name,
                    emoji: MockLobbyFixtures.participants[2].emoji,
                    detailKey: "mockLifecycle.gone.participantStatus"
                ),
                position: 3
            )

            Text("mockLifecycle.gone.queueExplanation")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    MockParticipantGoneView()
        .padding()
}
