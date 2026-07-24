import SwiftUI

struct MockTrackFailedView: View {
    var body: some View {
        VStack(alignment: .leading) {
            MockLifecycleStatusCard(
                title: "mockLifecycle.trackFailed.title",
                description: "mockLifecycle.trackFailed.description",
                systemImage: "exclamationmark.triangle.fill",
                tint: .red
            )

            HStack {
                MockArtworkView(title: "Afterglow")
                VStack(alignment: .leading) {
                    Text("Afterglow")
                        .font(.headline)
                    Text("Northbound")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("mockLifecycle.trackFailed.badge")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
