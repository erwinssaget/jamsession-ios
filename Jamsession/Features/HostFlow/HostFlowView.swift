import SwiftUI
import UIKit

struct HostFlowView: View {
    @Environment(\.openURL) private var openURL
    @State private var coordinator: HostFlowCoordinator
    @State private var catalogSearchModel: HostCatalogSearchModel
    @State private var eligibilityRequestGeneration = 0

    init(
        eligibilityChecker: any HostMusicEligibilityChecking =
            AppleMusicHostEligibilityChecker(),
        catalogService: any HostCatalogServicing =
            AppleMusicHostCatalogService()
    ) {
        _coordinator = State(
            initialValue: HostFlowCoordinator(
                eligibilityChecker: eligibilityChecker
            )
        )
        _catalogSearchModel = State(
            initialValue: HostCatalogSearchModel(service: catalogService)
        )
    }

    var body: some View {
        Group {
            switch coordinator.step {
            case .profile:
                ProfileSetupView(
                    role: .host,
                    accessibilityPrefix: "host.flow.profile",
                    onContinue: coordinator.submitProfile
                )
            case .musicAccess:
                HostMusicAccessView(
                    displayName: coordinator.profile?.displayName ?? "",
                    state: coordinator.musicAccessState,
                    requestAccess: requestMusicEligibility,
                    openSettings: openMusicSettings,
                    cancel: coordinator.returnToProfile
                )
            case .lobby:
                if let session = coordinator.session {
                    HostLobbyView(
                        presentation: HostLobbyPresentationMapper.map(session),
                        start: coordinator.startSession,
                        cancel: coordinator.returnToProfile
                    )
                }
            case .queue:
                if let session = coordinator.session {
                    HostFlowQueueView(
                        session: session,
                        catalogSearchModel: catalogSearchModel,
                        returnToLobby: coordinator.returnToLobby
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(coordinator.step != .profile)
        .task(id: eligibilityRequestGeneration) {
            guard eligibilityRequestGeneration > 0 else {
                return
            }
            await coordinator.requestMusicEligibility()
        }
    }

    private func requestMusicEligibility() {
        eligibilityRequestGeneration += 1
    }

    private func openMusicSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }
}

#Preview {
    NavigationStack {
        HostFlowView()
    }
}
