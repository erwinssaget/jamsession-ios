import SwiftUI

struct ContentView: View {
    var body: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-show-feasibility-harness") {
            FeasibilityView()
        } else if ProcessInfo.processInfo.arguments.contains("-host-flow-eligible") {
            AppFlowView(
                eligibilityChecker: DebugHostMusicEligibilityChecker(
                    outcome: .eligible
                ),
                catalogService: DebugHostCatalogService(),
                queueExecutor: DebugHostQueueExecutor()
            )
        } else if ProcessInfo.processInfo.arguments.contains(
            "-host-flow-subscription-offer"
        ) {
            AppFlowView(
                eligibilityChecker: DebugHostMusicEligibilityChecker(
                    outcome: .subscriptionOfferAvailable
                ),
                catalogService: DebugHostCatalogService(),
                queueExecutor: DebugHostQueueExecutor()
            )
        } else {
            AppFlowView()
        }
        #else
        AppFlowView()
        #endif
    }
}

#Preview {
    ContentView()
}
