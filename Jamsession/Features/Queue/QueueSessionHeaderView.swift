import SwiftUI

struct QueueSessionHeaderView: View {
    let presentation: QueueSessionPresentation
    var addMusic: (() -> Void)?

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
                                localized: "queue.roomCode",
                                defaultValue: "Room \(presentation.roomCode)"
                            )
                        )
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let addMusic {
                        Button("queue.addMusic", systemImage: "plus", action: addMusic)
                            .accessibilityIdentifier("queue.addMusic")
                            .buttonStyle(.borderedProminent)
                    }
                }

                VStack(alignment: .leading) {
                    Text(presentation.sessionName)
                        .font(.title2)
                        .bold()
                    Text(
                        String(
                            localized: "queue.roomCode",
                            defaultValue: "Room \(presentation.roomCode)"
                        )
                    )
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)

                    if let addMusic {
                        Button("queue.addMusic", systemImage: "plus", action: addMusic)
                            .accessibilityIdentifier("queue.addMusic")
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                    }
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
                    participantCountDescription
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }

    var participantCountDescription: String {
        String(
            localized: "queue.participantCount",
            defaultValue: "\(presentation.participants.count) people"
        )
    }
}

#Preview("Full Session") {
    QueueSessionHeaderView(
        presentation: MockSessionFixtures.fullSession,
        addMusic: {}
    )
    .padding()
}
