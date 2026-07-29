import SwiftUI

struct AppFlowView: View {
    @State private var selectedRole: SessionRole?

    private let eligibilityChecker: any HostMusicEligibilityChecking
    private let catalogService: any HostCatalogServicing
    private let queueExecutor: (any HostQueueExecuting)?

    init(
        eligibilityChecker: any HostMusicEligibilityChecking =
            AppleMusicHostEligibilityChecker(),
        catalogService: any HostCatalogServicing =
            AppleMusicHostCatalogService(),
        queueExecutor: (any HostQueueExecuting)? = nil
    ) {
        self.eligibilityChecker = eligibilityChecker
        self.catalogService = catalogService
        self.queueExecutor = queueExecutor
    }

    var body: some View {
        NavigationStack {
            RoleSelectionView { role in
                selectedRole = role
            }
            .navigationDestination(item: $selectedRole) { role in
                switch role {
                case .host:
                    HostFlowView(
                        eligibilityChecker: eligibilityChecker,
                        catalogService: catalogService,
                        queueExecutor: queueExecutor
                    ) {
                        selectedRole = nil
                    }
                case .join:
                    JoinUnavailableView {
                        selectedRole = nil
                    }
                }
            }
        }
    }
}

#Preview {
    AppFlowView()
}
