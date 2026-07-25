import SwiftUI

struct MockProfileSetupView: View {
    let role: SessionRole
    var onContinue: ((ProfileDraft) -> Void)?

    @State private var isShowingExplainer = false
    @State private var completedProfile: ProfileDraft?

    var body: some View {
        ProfileSetupView(
            role: role,
            accessibilityPrefix: "mock.flow.profile"
        ) { profile in
            if let onContinue {
                onContinue(profile)
            } else {
                completedProfile = profile
                isShowingExplainer = true
            }
        }
        .sheet(isPresented: $isShowingExplainer) {
            MockPermissionExplainerView(
                role: role,
                displayName: completedProfile?.displayName ?? ""
            )
        }
    }
}

#Preview {
    NavigationStack {
        MockProfileSetupView(role: .host)
    }
}
