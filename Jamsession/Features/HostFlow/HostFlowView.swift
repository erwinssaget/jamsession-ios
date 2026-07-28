import SwiftUI
import UIKit

struct HostFlowView: View {
    @Environment(\.openURL) private var openURL
    @State private var coordinator: HostFlowCoordinator
    @State private var catalogSearchModel: HostCatalogSearchModel
    @State private var hostPlayer: HostPlayer
    @State private var eligibilityRequestID: UUID?

    init(
        eligibilityChecker: any HostMusicEligibilityChecking =
            AppleMusicHostEligibilityChecker(),
        catalogService: any HostCatalogServicing =
            AppleMusicHostCatalogService(),
        queueExecutor: (any HostQueueExecuting)? = nil
    ) {
        _coordinator = State(
            initialValue: HostFlowCoordinator(
                eligibilityChecker: eligibilityChecker
            )
        )
        _catalogSearchModel = State(
            initialValue: HostCatalogSearchModel(service: catalogService)
        )
        _hostPlayer = State(
            initialValue: HostPlayer(
                executor: queueExecutor ?? AppleMusicHostQueueExecutor()
            )
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
                    cancel: returnToProfile
                )
            case .lobby:
                if let session = coordinator.session {
                    HostLobbyView(
                        presentation: HostLobbyPresentationMapper.map(session),
                        start: coordinator.startSession,
                        cancel: returnToProfile
                    )
                }
            case .queue:
                if let session = coordinator.session {
                    HostFlowQueueView(
                        session: session,
                        catalogSearchModel: catalogSearchModel,
                        hostPlayer: hostPlayer,
                        returnToLobby: coordinator.returnToLobby
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(coordinator.step != .profile)
        .task(id: eligibilityRequestID) {
            guard let requestID = eligibilityRequestID else {
                return
            }
            await coordinator.requestMusicEligibility()
            if eligibilityRequestID == requestID {
                eligibilityRequestID = nil
            }
        }
    }

    private func requestMusicEligibility() {
        guard eligibilityRequestID == nil else {
            return
        }
        eligibilityRequestID = UUID()
    }

    private func returnToProfile() {
        eligibilityRequestID = nil
        coordinator.returnToProfile()
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
