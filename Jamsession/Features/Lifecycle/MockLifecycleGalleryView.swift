import SwiftUI

struct MockLifecycleGalleryView: View {
    var returnHome: () -> Void = {}

    @State private var scenario = MockLifecycleScenario.participantGone

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("mockLifecycle.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                MockLifecycleContentView(scenario: scenario) {
                    scenario = .participantGone
                    returnHome()
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
                                .accessibilityIdentifier(
                                    "mock.flow.lifecycle.scenario.\(option.rawValue)"
                                )
                                .tag(option)
                        }
                    }
                }
                .accessibilityIdentifier("mock.flow.lifecycle.previewState")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MockLifecycleGalleryView()
    }
}
