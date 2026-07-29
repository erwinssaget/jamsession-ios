import SwiftUI
@preconcurrency import MusicKit

struct AppleMusicSubscriptionOfferModifier: ViewModifier {
    @Binding var isPresented: Bool
    let loadFailed: @MainActor @Sendable () -> Void

    func body(content: Content) -> some View {
        content.musicSubscriptionOffer(
            isPresented: $isPresented,
            options: .default
        ) { error in
            guard error != nil else {
                return
            }
            Task { @MainActor in
                loadFailed()
            }
        }
    }
}

extension View {
    func appleMusicSubscriptionOffer(
        isPresented: Binding<Bool>,
        loadFailed: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        modifier(
            AppleMusicSubscriptionOfferModifier(
                isPresented: isPresented,
                loadFailed: loadFailed
            )
        )
    }
}
