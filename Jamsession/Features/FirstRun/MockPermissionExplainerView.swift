import SwiftUI

struct MockPermissionExplainerView: View {
    @Environment(\.dismiss) private var dismiss

    let role: MockEntryRole
    let displayName: String
    var onContinue: (() -> Void)?

    var body: some View {
        NavigationStack {
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

                Text(
                    role == .host
                        ? "mockEntry.permission.host.description"
                        : "mockEntry.permission.join.description"
                )
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                Label("mockEntry.permission.inert", systemImage: "hammer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

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
