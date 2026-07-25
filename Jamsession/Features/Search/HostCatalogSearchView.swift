import SwiftUI
import UIKit

struct HostCatalogSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Bindable var model: HostCatalogSearchModel
    let session: HostSessionModel

    @State private var query = ""
    @State private var retryGeneration = 0
    @State private var submissionRequest: SubmissionRequest?

    var body: some View {
        ScrollView {
            HostCatalogSearchStateView(
                state: model.state,
                isSubmitting: model.isSubmitting,
                add: submit,
                retry: retry,
                openSettings: openMusicSettings
            )
            .padding()
        }
        .navigationTitle("host.search.title")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "host.search.prompt")
        .safeAreaInset(edge: .top) {
            Button("queue.done", systemImage: "xmark") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("host.flow.search.done")
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(.bar)
        }
        .safeAreaInset(edge: .bottom) {
            if let outcome = model.submissionOutcome {
                QueueCommandFeedbackView(
                    presentation: HostCatalogSubmissionFeedbackMapper.map(outcome),
                    dismiss: model.dismissSubmissionOutcome
                )
                .padding()
            }
        }
        .task(id: searchTaskID) {
            await model.search(for: query)
        }
        .task(id: submissionRequest?.id) {
            guard let submissionRequest else {
                return
            }
            await model.submit(submissionRequest.track, to: session)
            if self.submissionRequest?.id == submissionRequest.id {
                self.submissionRequest = nil
            }
        }
        .onDisappear {
            model.invalidateRequests()
        }
    }

    private var searchTaskID: String {
        "\(retryGeneration):\(query)"
    }

    private func submit(_ track: CatalogTrackSelection) {
        guard submissionRequest == nil, !model.isSubmitting else {
            return
        }
        submissionRequest = SubmissionRequest(id: UUID(), track: track)
    }

    private func retry() {
        retryGeneration += 1
    }

    private func openMusicSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
}

private extension HostCatalogSearchView {
    struct SubmissionRequest {
        let id: UUID
        let track: CatalogTrackSelection
    }
}
