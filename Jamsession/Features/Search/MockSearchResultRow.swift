import SwiftUI

struct MockSearchResultRow: View {
    let track: MockSearchTrack
    let add: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        QueueArtworkView(title: track.title)

                        Spacer()

                        Button("mockSearch.add", systemImage: "plus", action: add)
                            .labelStyle(.iconOnly)
                            .buttonStyle(.bordered)
                            .accessibilityLabel(addAccessibilityLabel)
                            .accessibilityIdentifier("mock.flow.search.add")
                    }

                    Text(track.title)
                        .fixedSize(horizontal: false, vertical: true)
                    if track.isExplicit {
                        ExplicitBadgeView()
                    }
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack {
                    QueueArtworkView(title: track.title)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(track.title)
                                .lineLimit(2)
                            if track.isExplicit {
                                ExplicitBadgeView()
                            }
                        }
                        Text(track.artist)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("mockSearch.add", systemImage: "plus", action: add)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.bordered)
                        .accessibilityLabel(addAccessibilityLabel)
                        .accessibilityIdentifier("mock.flow.search.add")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var addAccessibilityLabel: String {
        String(
            localized: "mockSearch.add.accessibility",
            defaultValue: "Add \(track.title) by \(track.artist)"
        )
    }
}

#Preview("Long Explicit Track") {
    MockSearchResultRow(track: MockSearchFixtures.longTitleTrack, add: {})
        .padding()
}
