import SwiftUI

struct QueueCommandFeedbackView: View {
    let presentation: QueueCommandFeedbackPresentation
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: presentation.tone == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(presentation.tone == .success ? .green : .orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(presentation.title)
                    .font(.headline)
                Text(presentation.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button("queue.feedback.dismiss", systemImage: "xmark", action: dismiss)
                .labelStyle(.iconOnly)
                .accessibilityIdentifier("queue.feedback.dismiss")
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 18))
    }
}
