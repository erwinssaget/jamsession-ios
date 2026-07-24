import SwiftUI

struct MockLifecycleGalleryView: View {
    @State private var scenario = MockLifecycleScenario.participantGone

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("mockLifecycle.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                MockLifecycleContentView(scenario: scenario) {
                    scenario = .participantGone
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("mockLifecycle.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("mockLifecycle.previewState", systemImage: "slider.horizontal.3") {
                    Picker("mockLifecycle.previewState", selection: $scenario) {
                        ForEach(MockLifecycleScenario.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey))
                                .tag(option)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MockLifecycleGalleryView()
    }
}
