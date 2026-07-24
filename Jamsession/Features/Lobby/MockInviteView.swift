import SwiftUI

struct MockInviteView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220, maxHeight: 220)
                        .accessibilityLabel("mockLobby.invite.qrAccessibility")

                    Text("mockLobby.invite.title")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("mockLobby.invite.description")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("BEAT")
                        .font(.title.monospaced())
                        .bold()
                        .textSelection(.enabled)
                    Label("mockLobby.invite.fixtureNotice", systemImage: "hammer")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("mock.flow.invite.fixtureNotice")
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .navigationTitle("mockLobby.invite.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("mockLobby.done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("mock.flow.invite.done")
                }
            }
        }
    }
}

#Preview {
    MockInviteView()
        .environment(\.dynamicTypeSize, .accessibility5)
        .preferredColorScheme(.dark)
}
