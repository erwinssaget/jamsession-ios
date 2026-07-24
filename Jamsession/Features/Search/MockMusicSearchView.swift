import SwiftUI
import UIKit

struct MockMusicSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var showsDoneButton = true

    @State private var query = ""
    @State private var scenario = MockSearchScenario.results
    @State private var outcome: MockSubmissionOutcome?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("mockSearch.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                MockSearchStateView(
                    scenario: scenario,
                    tracks: MockSearchFixtures.tracks,
                    add: { _ in outcome = .pending },
                    retry: { scenario = .results },
                    openSettings: openSettings
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            if let outcome {
                MockSubmissionFeedbackView(outcome: outcome) {
                    self.outcome = nil
                }
                .padding()
            }
        }
        .navigationTitle("mockSearch.title")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "mockSearch.prompt")
        .onChange(of: query) { _, newValue in
            scenario = newValue.isEmpty ? .idle : .results
            outcome = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu("mockSearch.previewState", systemImage: "slider.horizontal.3") {
                    Picker("mockSearch.previewState", selection: $scenario) {
                        ForEach(MockSearchScenario.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey))
                                .accessibilityIdentifier(
                                    "mock.flow.search.scenario.\(option.rawValue)"
                                )
                                .tag(option)
                        }
                    }

                    Menu("mockSearch.previewFeedback") {
                        ForEach(MockSubmissionOutcome.allCases) { option in
                            Button(LocalizedStringKey(option.titleKey)) {
                                outcome = option
                            }
                        }
                    }
                }
                .accessibilityIdentifier("mock.flow.search.previewState")

                if showsDoneButton {
                    Button("mockQueue.done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("mock.flow.search.done")
                }
            }
        }
    }

    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
}

#Preview {
    NavigationStack {
        MockMusicSearchView()
    }
}
