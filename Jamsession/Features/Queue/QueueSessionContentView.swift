import SwiftUI

struct QueueSessionContentView: View {
    let presentation: QueueSessionPresentation
    var addMusic: (() -> Void)?
    var removeTrack: ((SubmissionID) -> Void)?
    var skipTurn: ((SubmissionID) -> Void)?
    var showsNowPlaying = true

    var body: some View {
        LazyVStack(alignment: .leading) {
            QueueSessionHeaderView(
                presentation: presentation,
                addMusic: addMusic
            )

            if presentation.connectionStatus == .reconnecting {
                Label("queue.reconnecting", systemImage: "wifi.exclamationmark")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 12))
                    .accessibilityAddTraits(.updatesFrequently)
            }

            if showsNowPlaying, let nowPlaying = presentation.nowPlaying {
                QueueNowPlayingView(track: nowPlaying)
            }

            QueueContentView(
                upcoming: presentation.upcoming,
                removeTrack: removeTrack,
                skipTurn: skipTurn
            )
        }
    }
}
