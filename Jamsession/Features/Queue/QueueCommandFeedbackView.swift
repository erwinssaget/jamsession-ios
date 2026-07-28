import SwiftUI

struct QueueCommandFeedbackView: View {
    let presentation: QueueCommandFeedbackPresentation
    var accessibilityIdentifierPrefix = "queue.feedback"
    let dismiss: () -> Void

    @AccessibilityFocusState private var isFeedbackFocused: Bool

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: presentation.tone == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(presentation.tone == .success ? .green : .orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(presentation.title)
                    .font(.headline)
                    .accessibilityIdentifier(
                        "\(accessibilityIdentifierPrefix).title"
                    )
                Text(presentation.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier(
                        "\(accessibilityIdentifierPrefix).message"
                    )
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(presentation.title). \(presentation.message)"
            )
            .accessibilityIdentifier(
                "\(accessibilityIdentifierPrefix).summary"
            )
            .accessibilityFocused($isFeedbackFocused)

            Spacer()

            Button("queue.feedback.dismiss", systemImage: "xmark", action: dismiss)
                .labelStyle(.iconOnly)
                .accessibilityIdentifier(
                    "\(accessibilityIdentifierPrefix).dismiss"
                )
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 18))
        .task(id: presentation) {
            isFeedbackFocused = false
            await Task.yield()
            isFeedbackFocused = true
        }
    }
}
