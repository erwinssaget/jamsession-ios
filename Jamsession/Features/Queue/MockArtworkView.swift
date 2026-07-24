import SwiftUI

struct MockArtworkView: View {
    let title: String
    var size: CGFloat = 52

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.9), .blue.opacity(0.7), .pink.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "music.note")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .accessibilityLabel(
                String(
                    localized: "mockQueue.artwork.accessibility",
                    defaultValue: "Artwork for \(title)"
                )
            )
    }
}
