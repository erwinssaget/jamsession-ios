import SwiftUI

struct CatalogSearchAddButton: View {
    let track: CatalogTrackSelection
    let isSubmitting: Bool
    let add: () -> Void

    var body: some View {
        Button("queue.addTrack", systemImage: "plus", action: add)
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .disabled(isSubmitting)
            .accessibilityIdentifier("host.flow.search.\(track.id.rawValue).add")
            .accessibilityLabel(
                String(
                    localized: "host.search.add.accessibility",
                    defaultValue: "Add \(track.title) by \(track.artistName)"
                )
            )
    }
}
