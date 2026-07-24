import SwiftUI

struct MockSearchResultRow: View {
    let track: MockSearchTrack
    let add: () -> Void

    var body: some View {
        HStack {
            MockArtworkView(title: track.title)

            VStack(alignment: .leading) {
                HStack {
                    Text(track.title)
                        .lineLimit(2)
                    if track.isExplicit {
                        Text("mockQueue.explicit")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(.secondary.opacity(0.2))
                            .clipShape(.rect(cornerRadius: 3))
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
                .accessibilityLabel(
                    String(
                        localized: "mockSearch.add.accessibility",
                        defaultValue: "Add \(track.title) by \(track.artist)"
                    )
                )
        }
        .accessibilityElement(children: .contain)
    }
}
