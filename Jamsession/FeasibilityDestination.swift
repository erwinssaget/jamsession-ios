#if DEBUG
enum FeasibilityDestination: Hashable {
    case domainQueue
    case hostFlow
    case mockEntry
    case mockFullFlow
    case mockLifecycle
    case mockLobby
    case mockQueue
    case mockSearch
}
#endif
