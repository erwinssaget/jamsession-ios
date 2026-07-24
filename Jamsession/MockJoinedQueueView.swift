import SwiftUI

struct MockJoinedQueueView: View {
    var onOpenLifecycle: (() -> Void)?

    @State private var scenario = MockQueueScenario.populated
    @State private var isShowingAddMusic = false

    var body: some View {
        MockJoinedQueuePresentationView(
            presentation: scenario.presentation,
            addMusic: { isShowingAddMusic = true },
            openLifecycle: onOpenLifecycle
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("mockQueue.previewState", systemImage: "slider.horizontal.3") {
                    Picker("mockQueue.previewState", selection: $scenario) {
                        ForEach(MockQueueScenario.allCases) { scenario in
                            Text(LocalizedStringKey(scenario.titleKey))
                                .tag(scenario)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddMusic) {
            NavigationStack {
                MockMusicSearchView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MockJoinedQueueView()
    }
}
