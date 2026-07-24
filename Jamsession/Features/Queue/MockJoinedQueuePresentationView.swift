import SwiftUI

struct MockJoinedQueuePresentationView: View {
    let presentation: MockSessionPresentation
    let addMusic: () -> Void
    var openLifecycle: (() -> Void)?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Label("mockQueue.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)

                MockSessionHeaderView(
                    presentation: presentation,
                    addMusic: addMusic
                )

                if presentation.connectionStatus == .reconnecting {
                    Label("mockQueue.reconnecting", systemImage: "wifi.exclamationmark")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.orange.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 12))
                        .accessibilityAddTraits(.updatesFrequently)
                }

                if let nowPlaying = presentation.nowPlaying {
                    MockNowPlayingView(track: nowPlaying)
                }

                MockQueueContentView(upcoming: presentation.upcoming)
            }
            .padding()
        }
        .background(.background)
        .navigationTitle(presentation.sessionName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let openLifecycle {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        "mockQueue.lifecycle",
                        systemImage: "waveform.path.ecg",
                        action: openLifecycle
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MockJoinedQueuePresentationView(
            presentation: MockSessionFixtures.populated,
            addMusic: {}
        )
    }
}
