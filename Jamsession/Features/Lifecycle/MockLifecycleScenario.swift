nonisolated enum MockLifecycleScenario: String, CaseIterable, Identifiable {
    case participantGone
    case participantRemoved
    case trackFailed
    case hostLoss
    case ending
    case ended
    case reduceMotion
    case localizationExpansion

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .participantGone:
            "mockLifecycle.scenario.gone"
        case .participantRemoved:
            "mockLifecycle.scenario.removed"
        case .trackFailed:
            "mockLifecycle.scenario.trackFailed"
        case .hostLoss:
            "mockLifecycle.scenario.hostLoss"
        case .ending:
            "mockLifecycle.scenario.ending"
        case .ended:
            "mockLifecycle.scenario.ended"
        case .reduceMotion:
            "mockLifecycle.scenario.reduceMotion"
        case .localizationExpansion:
            "mockLifecycle.scenario.localizationExpansion"
        }
    }
}
