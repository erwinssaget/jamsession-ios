import SwiftUI

struct HostPlaybackControlsView: View {
    let presentation: HostPlaybackControlsPresentation
    let playOrPause: () -> Void
    let skip: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading) {
            Label(presentation.heading, systemImage: "waveform")
                .font(.headline)
                .foregroundStyle(.secondary)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    HostPlaybackTrackMetadataView(track: presentation.track)
                    HostPlaybackControlButtonsView(
                        presentation: presentation,
                        playOrPause: playOrPause,
                        skip: skip
                    )
                }
            } else {
                HStack {
                    HostPlaybackTrackMetadataView(track: presentation.track)
                    Spacer()
                    HostPlaybackControlButtonsView(
                        presentation: presentation,
                        playOrPause: playOrPause,
                        skip: skip
                    )
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("host.playback.controls")
    }
}
