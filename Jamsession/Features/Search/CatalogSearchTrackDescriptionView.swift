import SwiftUI

struct CatalogSearchTrackDescriptionView: View {
    let track: CatalogTrackSelection

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(track.title)
                    .fixedSize(horizontal: false, vertical: true)
                if track.isExplicit {
                    ExplicitBadgeView()
                }
            }
            Text(track.artistName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
