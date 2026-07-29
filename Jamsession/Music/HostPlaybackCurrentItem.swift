nonisolated enum HostPlaybackCurrentItem: Equatable, Sendable {
    case none
    case managed(SubmissionID)
    case unmanaged

    var managedID: SubmissionID? {
        if case .managed(let id) = self {
            id
        } else {
            nil
        }
    }
}
