import SwiftUI

struct MockQueueContentView: View {
    let upcoming: [MockSessionPresentation.Track]

    var body: some View {
        if upcoming.isEmpty {
            ContentUnavailableView(
                "mockQueue.empty.title",
                systemImage: "music.note",
                description: Text("mockQueue.empty.description")
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        } else {
            VStack(alignment: .leading) {
                Text("mockQueue.upNext")
                    .font(.title3)
                    .bold()
                    .accessibilityAddTraits(.isHeader)

                Text("mockQueue.fairnessExplanation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(upcoming.enumerated(), id: \.element.id) { index, track in
                    MockQueueRow(track: track, position: index + 1)

                    if track.id != upcoming.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}
