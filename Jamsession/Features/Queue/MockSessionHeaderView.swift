import SwiftUI

struct MockSessionHeaderView: View {
    let presentation: MockSessionPresentation
    let addMusic: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(presentation.sessionName)
                            .font(.title2)
                            .bold()
                        Text(
                            String(
                                localized: "mockQueue.roomCode",
                                defaultValue: "Room \(presentation.roomCode)"
                            )
                        )
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("mockQueue.addMusic", systemImage: "plus", action: addMusic)
                    .accessibilityIdentifier("mock.flow.queue.addMusic")
                    .buttonStyle(.borderedProminent)
                }

                VStack(alignment: .leading) {
                    Text(presentation.sessionName)
                        .font(.title2)
                        .bold()
                    Text(
                        String(
                            localized: "mockQueue.roomCode",
                            defaultValue: "Room \(presentation.roomCode)"
                        )
                    )
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)

                    Button("mockQueue.addMusic", systemImage: "plus", action: addMusic)
                    .accessibilityIdentifier("mock.flow.queue.addMusic")
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }

            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(presentation.participants) { participant in
                            ParticipantBadgeView(participant: participant)
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Text(
                    String(
                        localized: "mockQueue.participantCount",
                        defaultValue: "\(presentation.participants.count) people"
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

#Preview("Full Session") {
    MockSessionHeaderView(
        presentation: MockSessionFixtures.fullSession,
        addMusic: {}
    )
    .padding()
}
