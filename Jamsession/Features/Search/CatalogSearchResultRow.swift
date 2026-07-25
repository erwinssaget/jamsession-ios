import SwiftUI

struct CatalogSearchResultRow: View {
    let track: CatalogTrackSelection
    let isSubmitting: Bool
    let add: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        QueueArtworkView(title: track.title)
                        Spacer()
                        CatalogSearchAddButton(
                            track: track,
                            isSubmitting: isSubmitting,
                            add: add
                        )
                    }

                    CatalogSearchTrackDescriptionView(track: track)
                }
            } else {
                HStack {
                    QueueArtworkView(title: track.title)
                    CatalogSearchTrackDescriptionView(track: track)
                    Spacer()
                    CatalogSearchAddButton(
                        track: track,
                        isSubmitting: isSubmitting,
                        add: add
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
