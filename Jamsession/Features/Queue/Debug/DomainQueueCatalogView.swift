#if DEBUG
import SwiftUI

struct DomainQueueCatalogView: View {
    let tracks: [CatalogTrackSelection]
    let commandOutcome: QueueCommandOutcome?
    let add: (CatalogTrackSelection) -> Void
    let dismissCommandOutcome: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(tracks) { track in
            HStack {
                QueueArtworkView(title: track.title)

                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(track.title)
                        if track.isExplicit {
                            ExplicitBadgeView()
                        }
                    }
                    Text(track.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("queue.addTrack", systemImage: "plus") {
                    add(track)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .accessibilityIdentifier("queue.catalog.\(track.id.rawValue).add")
                .accessibilityLabel(
                    String(
                        localized: "queue.addTrack.accessibility",
                        defaultValue: "Add \(track.title)"
                    )
                )
            }
        }
        .navigationTitle("queue.catalog.title")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            Label("queue.harness.catalogNotice", systemImage: "hammer")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
        }
        .safeAreaInset(edge: .bottom) {
            if let commandOutcome {
                QueueCommandFeedbackView(
                    presentation: QueueCommandFeedbackPresentation.map(
                        commandOutcome
                    ),
                    accessibilityIdentifierPrefix: "queue.catalog.feedback",
                    dismiss: dismissCommandOutcome
                )
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("queue.done") {
                    dismiss()
                }
            }
        }
    }
}
#endif
