import SwiftUI

struct MockSubmissionFeedbackView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let outcome: MockSubmissionOutcome
    let dismiss: () -> Void

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Image(systemName: presentation.systemImage)
                            .foregroundStyle(tint)
                            .accessibilityHidden(true)

                        Text(LocalizedStringKey(presentation.titleKey))
                            .font(.headline)

                        Spacer()

                        Button("mockSearch.feedback.dismiss", systemImage: "xmark", action: dismiss)
                            .labelStyle(.iconOnly)
                    }

                    Text(LocalizedStringKey(presentation.descriptionKey))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack(alignment: .top) {
                    Image(systemName: presentation.systemImage)
                        .foregroundStyle(tint)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(presentation.titleKey))
                            .font(.headline)
                        Text(LocalizedStringKey(presentation.descriptionKey))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("mockSearch.feedback.dismiss", systemImage: "xmark", action: dismiss)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .padding()
        .background(tint.opacity(0.12))
        .clipShape(.rect(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }

    private var presentation: MockSubmissionFeedbackPresentation {
        outcome.presentation
    }

    private var tint: Color {
        switch presentation.tone {
        case .pending:
            .blue
        case .accepted:
            .green
        case .warning:
            .orange
        case .failure:
            .red
        }
    }
}

#Preview {
    ScrollView {
        MockSubmissionFeedbackView(outcome: .pendingLimit, dismiss: {})
            .padding()
    }
}
