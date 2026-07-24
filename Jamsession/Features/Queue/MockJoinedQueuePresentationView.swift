import SwiftUI

struct MockJoinedQueuePresentationView: View {
    let presentation: QueueSessionPresentation
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

                QueueSessionContentView(
                    presentation: presentation,
                    addMusic: addMusic
                )
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
                    .accessibilityIdentifier("mock.flow.queue.lifecycle")
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
