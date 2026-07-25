import Foundation
import Observation

@MainActor
@Observable
final class HostCatalogSearchModel {
    private(set) var state = HostCatalogSearchState.idle
    private(set) var submissionOutcome: HostCatalogSubmissionOutcome?
    private(set) var isSubmitting = false

    private let service: any HostCatalogServicing
    private let debounce: Duration
    private var searchRequestID: UUID?
    private var submissionRequestID: UUID?

    init(
        service: any HostCatalogServicing,
        debounce: Duration = .milliseconds(350)
    ) {
        self.service = service
        self.debounce = debounce
    }

    func search(for rawQuery: String) async {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchRequestID = nil
            state = .idle
            return
        }

        let requestID = UUID()
        searchRequestID = requestID

        do {
            try await Task.sleep(for: debounce)
            guard searchRequestID == requestID else {
                return
            }
            state = .loading

            let result = try await service.search(for: query)
            guard searchRequestID == requestID, !Task.isCancelled else {
                return
            }

            state = result.tracks.isEmpty
                ? .empty(query: query)
                : .results(result)
        } catch is CancellationError {
            return
        } catch let error as HostCatalogServiceError {
            guard searchRequestID == requestID, !Task.isCancelled else {
                return
            }
            state = .failure(error)
        } catch {
            guard searchRequestID == requestID, !Task.isCancelled else {
                return
            }
            state = .failure(.unavailable)
        }
    }

    func submit(
        _ selection: CatalogTrackSelection,
        to session: HostSessionModel
    ) async {
        guard !isSubmitting else {
            return
        }

        let requestID = UUID()
        submissionRequestID = requestID
        submissionOutcome = nil
        isSubmitting = true
        defer {
            if submissionRequestID == requestID {
                submissionRequestID = nil
                isSubmitting = false
            }
        }

        do {
            let resolvedSelection = try await service.resolve(trackID: selection.id)
            guard submissionRequestID == requestID, !Task.isCancelled else {
                return
            }

            let token = UUID().uuidString
            let outcome = session.handle(
                QueueCommand(
                    id: FairnessEventID("host-submit-\(token)"),
                    participantID: session.hostID,
                    action: .submit(
                        selection: resolvedSelection,
                        submissionID: SubmissionID("host-submission-\(token)")
                    )
                )
            )

            switch outcome {
            case .accepted:
                submissionOutcome = .accepted
            case .rejected(let rejection):
                submissionOutcome = .fairnessRejected(rejection)
            }
        } catch is CancellationError {
            return
        } catch let error as HostCatalogServiceError {
            guard submissionRequestID == requestID, !Task.isCancelled else {
                return
            }
            submissionOutcome = .catalogRejected(error)
        } catch {
            guard submissionRequestID == requestID, !Task.isCancelled else {
                return
            }
            submissionOutcome = .catalogRejected(.unavailable)
        }
    }

    func dismissSubmissionOutcome() {
        submissionOutcome = nil
    }

    func invalidateRequests() {
        searchRequestID = nil
        submissionRequestID = nil
        state = .idle
        submissionOutcome = nil
        isSubmitting = false
    }
}
