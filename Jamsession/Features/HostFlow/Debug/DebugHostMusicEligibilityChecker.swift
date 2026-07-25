#if DEBUG
nonisolated struct DebugHostMusicEligibilityChecker: HostMusicEligibilityChecking {
    let outcome: HostMusicEligibilityOutcome

    func requestEligibility() async -> HostMusicEligibilityOutcome {
        outcome
    }
}
#endif
