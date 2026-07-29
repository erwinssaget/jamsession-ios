import SwiftUI

struct HostPlaybackControlButtonsView: View {
    let presentation: HostPlaybackControlsPresentation
    let playOrPause: () -> Void
    let skip: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout())
            : AnyLayout(HStackLayout())

        layout {
            Button(
                presentation.primaryActionTitle,
                systemImage: presentation.primaryActionSystemImage,
                action: playOrPause
            )
            .buttonStyle(.borderedProminent)
            .disabled(presentation.isPrimaryActionDisabled)
            .accessibilityIdentifier("host.playback.playPause")

            Button(
                presentation.skipTitle,
                systemImage: "forward.end.fill",
                action: skip
            )
            .buttonStyle(.bordered)
            .disabled(presentation.isSkipDisabled)
            .accessibilityIdentifier("host.playback.skip")
        }
    }
}
