import SwiftUI

struct MockSearchStateView: View {
    let scenario: MockSearchScenario
    let tracks: [MockSearchTrack]
    let add: (MockSearchTrack) -> Void
    let retry: () -> Void
    let openSettings: () -> Void

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
            VStack {
                ContentUnavailableView(
                    "mockSearch.denied.title",
                    systemImage: "music.note.slash",
                    description: Text("mockSearch.denied.description")
                )
                Button(
                    "mockSearch.openSettings",
                    systemImage: "gear",
                    action: openSettings
                )
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("mock.flow.search.openSettings")
            }
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

#Preview("Music Access Denied") {
    MockSearchStateView(
        scenario: .musicAccessDenied,
        tracks: MockSearchFixtures.tracks,
        add: { _ in },
        retry: {},
        openSettings: {}
    )
    .padding()
}
