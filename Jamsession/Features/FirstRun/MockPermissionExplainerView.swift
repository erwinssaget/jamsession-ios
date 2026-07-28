import SwiftUI

struct MockPermissionExplainerView: View {
    @Environment(\.dismiss) private var dismiss

    let role: SessionRole
    let displayName: String
    var onContinue: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(systemName: role == .host ? "music.note" : "wifi")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .frame(width: 88, height: 88)
                        .background(.tint.opacity(0.14))
                        .clipShape(.circle)
                        .accessibilityHidden(true)

                    Text(
                        role == .host
                            ? "mockEntry.permission.host.title"
                            : "mockEntry.permission.join.title"
                    )
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(
                        role == .host
                            ? "mockEntry.permission.host.description"
                            : "mockEntry.permission.join.description"
                    )
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                    Label("mockEntry.permission.inert", systemImage: "hammer")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("mockEntry.permission.preview", systemImage: "checkmark") {
                        if let onContinue {
                            onContinue()
                        } else {
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("mock.flow.permission.finish")
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .navigationTitle(displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("mockEntry.cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    MockPermissionExplainerView(
        role: .host,
        displayName: "Maya"
    )
}
