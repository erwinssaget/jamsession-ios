import SwiftUI

struct MockInviteView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .accessibilityLabel("mockLobby.invite.qrAccessibility")

                Text("mockLobby.invite.title")
                    .font(.title2)
                    .bold()
                Text("mockLobby.invite.description")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Text("BEAT")
                    .font(.title.monospaced())
                    .bold()
                    .textSelection(.enabled)
                Label("mockLobby.invite.fixtureNotice", systemImage: "hammer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("mockLobby.invite.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("mockLobby.done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
