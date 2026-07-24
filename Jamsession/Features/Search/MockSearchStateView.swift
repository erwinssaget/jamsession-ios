import SwiftUI

struct MockSearchStateView: View {
    let scenario: MockSearchScenario
    let tracks: [MockSearchTrack]
    let add: (MockSearchTrack) -> Void
    let retry: () -> Void

    var body: some View {
        switch scenario {
        case .idle:
            ContentUnavailableView(
                "mockSearch.idle.title",
                systemImage: "magnifyingglass",
                description: Text("mockSearch.idle.description")
            )
        case .loading:
            VStack {
                ProgressView()
                Text("mockSearch.loading")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        case .results:
            LazyVStack(alignment: .leading) {
                Text("mockSearch.results.title")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                ForEach(tracks) { track in
                    MockSearchResultRow(track: track) {
                        add(track)
                    }
                    if track.id != tracks.last?.id {
                        Divider()
                    }
                }
            }
        case .empty:
            ContentUnavailableView.search(text: "After Midnight")
        case .musicAccessDenied:
            status(
                title: "mockSearch.denied.title",
                systemImage: "music.note.slash",
                description: "mockSearch.denied.description"
            )
        case .offline:
            status(
                title: "mockSearch.offline.title",
                systemImage: "wifi.slash",
                description: "mockSearch.offline.description"
            )
        case .failed:
            status(
                title: "mockSearch.failed.title",
                systemImage: "exclamationmark.triangle",
                description: "mockSearch.failed.description"
            )
        }
    }

    private func status(
        title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey
    ) -> some View {
        VStack {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text(description)
            )
            Button("mockSearch.tryAgain", systemImage: "arrow.clockwise", action: retry)
                .buttonStyle(.bordered)
        }
    }
}
