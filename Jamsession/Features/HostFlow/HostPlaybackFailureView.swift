import SwiftUI

struct HostPlaybackFailureView: View {
    let presentation: HostPlaybackFailurePresentation
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Label(presentation.title, systemImage: "exclamationmark.triangle.fill")
                .bold()

            Text(presentation.message)
                .fixedSize(horizontal: false, vertical: true)

            Button(
                presentation.retryTitle,
                systemImage: "arrow.clockwise",
                action: retry
            )
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.primary)
        .background(.orange.opacity(0.14))
        .clipShape(.rect(cornerRadius: 16))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("host.playback.failure")
    }
}
