nonisolated enum MockSubmissionOutcome: String, CaseIterable, Identifiable {
    case pending
    case accepted
    case duplicate
    case pendingLimit
    case participantInactive
    case unplayable
    case timedOut

    var id: Self { self }

    var titleKey: String {
        presentation.titleKey
    }

    var presentation: MockSubmissionFeedbackPresentation {
        switch self {
        case .pending:
            .init(
                titleKey: "mockSearch.feedback.pending.title",
                descriptionKey: "mockSearch.feedback.pending.description",
                systemImage: "clock",
                tone: .pending
            )
        case .accepted:
            .init(
                titleKey: "mockSearch.feedback.accepted.title",
                descriptionKey: "mockSearch.feedback.accepted.description",
                systemImage: "checkmark.circle.fill",
                tone: .accepted
            )
        case .duplicate:
            .init(
                titleKey: "mockSearch.feedback.duplicate.title",
                descriptionKey: "mockSearch.feedback.duplicate.description",
                systemImage: "exclamationmark.circle.fill",
                tone: .warning
            )
        case .pendingLimit:
            .init(
                titleKey: "mockSearch.feedback.pendingLimit.title",
                descriptionKey: "mockSearch.feedback.pendingLimit.description",
                systemImage: "exclamationmark.circle.fill",
                tone: .warning
            )
        case .participantInactive:
            .init(
                titleKey: "mockSearch.feedback.inactive.title",
                descriptionKey: "mockSearch.feedback.inactive.description",
                systemImage: "exclamationmark.circle.fill",
                tone: .warning
            )
        case .unplayable:
            .init(
                titleKey: "mockSearch.feedback.unplayable.title",
                descriptionKey: "mockSearch.feedback.unplayable.description",
                systemImage: "xmark.circle.fill",
                tone: .failure
            )
        case .timedOut:
            .init(
                titleKey: "mockSearch.feedback.timeout.title",
                descriptionKey: "mockSearch.feedback.timeout.description",
                systemImage: "xmark.circle.fill",
                tone: .failure
            )
        }
    }
}
