import SwiftUI

struct HostCatalogSearchStateView: View {
    let state: HostCatalogSearchState
    let isSubmitting: Bool
    let add: (CatalogTrackSelection) -> Void
    let retry: () -> Void
    let openSettings: () -> Void

    var body: some View {
        switch state {
        case .idle:
            ContentUnavailableView(
                "host.search.idle.title",
                systemImage: "magnifyingglass",
                description: Text("host.search.idle.description")
            )
        case .loading:
            VStack {
                ProgressView()
                Text("host.search.loading")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .accessibilityIdentifier("host.flow.search.loading")
        case .results(let result):
            LazyVStack(alignment: .leading) {
                Text("host.search.results.title")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                ForEach(result.tracks) { track in
                    CatalogSearchResultRow(
                        track: track,
                        isSubmitting: isSubmitting
                    ) {
                        add(track)
                    }

                    if track.id != result.tracks.last?.id {
                        Divider()
                    }
                }
            }
        case .empty(let query):
            ContentUnavailableView.search(text: query)
        case .failure(let error):
            failureView(for: error)
        }
    }

    @ViewBuilder
    private func failureView(for error: HostCatalogServiceError) -> some View {
        VStack {
            ContentUnavailableView(
                failureTitle(for: error),
                systemImage: failureSymbol(for: error),
                description: Text(failureDescription(for: error))
            )

            if error == .authorizationRequired {
                Button(
                    "host.search.openSettings",
                    systemImage: "gear",
                    action: openSettings
                )
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("host.flow.search.openSettings")
            }

            Button("host.search.tryAgain", systemImage: "arrow.clockwise", action: retry)
                .buttonStyle(.bordered)
                .accessibilityIdentifier("host.flow.search.retry")
        }
    }

    private func failureTitle(
        for error: HostCatalogServiceError
    ) -> LocalizedStringKey {
        switch error {
        case .authorizationRequired:
            "host.search.authorization.title"
        case .subscriptionRequired:
            "host.search.subscription.title"
        case .offline:
            "host.search.offline.title"
        case .trackUnavailable, .unavailable:
            "host.search.unavailable.title"
        }
    }

    private func failureDescription(
        for error: HostCatalogServiceError
    ) -> LocalizedStringKey {
        switch error {
        case .authorizationRequired:
            "host.search.authorization.description"
        case .subscriptionRequired:
            "host.search.subscription.description"
        case .offline:
            "host.search.offline.description"
        case .trackUnavailable:
            "host.search.trackUnavailable.description"
        case .unavailable:
            "host.search.unavailable.description"
        }
    }

    private func failureSymbol(for error: HostCatalogServiceError) -> String {
        switch error {
        case .authorizationRequired:
            "music.note.slash"
        case .subscriptionRequired:
            "person.crop.circle.badge.exclamationmark"
        case .offline:
            "wifi.slash"
        case .trackUnavailable, .unavailable:
            "exclamationmark.triangle"
        }
    }
}
