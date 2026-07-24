import SwiftUI

struct MockLifecycleContentView: View {
    let scenario: MockLifecycleScenario
    let restart: () -> Void

    var body: some View {
        switch scenario {
        case .participantGone:
            MockParticipantGoneView()
        case .participantRemoved:
            ContentUnavailableView(
                "mockLifecycle.removed.title",
                systemImage: "person.crop.circle.badge.xmark",
                description: Text("mockLifecycle.removed.description")
            )
        case .trackFailed:
            MockTrackFailedView()
        case .hostLoss:
            MockHostLossView()
        case .ending:
            MockEndingSessionView()
        case .ended:
            VStack {
                ContentUnavailableView(
                    "mockLifecycle.ended.title",
                    systemImage: "music.note.house",
                    description: Text("mockLifecycle.ended.description")
                )
                Button("mockLifecycle.ended.returnHome", systemImage: "house", action: restart)
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("mock.flow.lifecycle.returnHome")
            }
        case .reduceMotion:
            MockReduceMotionView(reduceMotionOverride: nil)
        case .localizationExpansion:
            MockLocalizationExpansionView()
        }
    }
}
