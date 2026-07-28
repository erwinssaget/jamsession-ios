import SwiftUI

struct QueueContentView: View {
    let upcoming: [QueueSessionPresentation.Track]
    var removeTrack: ((SubmissionID) -> Void)?
    var skipTurn: ((SubmissionID) -> Void)?

    var body: some View {
        if upcoming.isEmpty {
            ContentUnavailableView(
                "queue.empty.title",
                systemImage: "music.note",
                description: Text("queue.empty.description")
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        } else {
            VStack(alignment: .leading) {
                Text("queue.upNext")
                    .font(.title3)
                    .bold()
                    .accessibilityAddTraits(.isHeader)

                Text("queue.fairnessExplanation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(upcoming.enumerated(), id: \.element.id) { index, track in
                    QueueTrackRow(
                        track: track,
                        position: index + 1,
                        remove: removeTrack.map { removeTrack in
                            { removeTrack(track.id) }
                        },
                        skipTurn: skipTurn.map { skipTurn in
                            { skipTurn(track.id) }
                        }
                    )

                    if track.id != upcoming.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}
