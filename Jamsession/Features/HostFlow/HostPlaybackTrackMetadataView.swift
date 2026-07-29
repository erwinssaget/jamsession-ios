import SwiftUI

struct HostPlaybackTrackMetadataView: View {
    let track: QueueSessionPresentation.Track

    var body: some View {
        VStack(alignment: .leading) {
            Text(track.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            Text(track.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
