import SwiftUI

struct MockNowPlayingView: View {
    let track: MockSessionPresentation.Track

    var body: some View {
        VStack(alignment: .leading) {
            Label("mockQueue.nowPlaying", systemImage: "waveform")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                MockArtworkView(title: track.title, size: 72)

                VStack(alignment: .leading) {
                    Text(track.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Label {
                        Text(
                            String(
                                localized: "mockQueue.addedBy",
                                defaultValue: "Added by \(track.submitter.name)"
                            )
                        )
                    } icon: {
                        Text(track.submitter.emoji)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}
