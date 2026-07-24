import SwiftUI

struct MockDiscoveryView: View {
    let join: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Label("mockLobby.discovery.searching", systemImage: "wifi")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("mockLobby.discovery.nearby")
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)

            Button(action: join) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Maya’s Jam")
                            .font(.headline)
                        Text("mockLobby.discovery.roomDetail")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .padding()
                .contentShape(.rect)
            }
            .accessibilityIdentifier("mock.flow.discovery.session")
            .buttonStyle(.plain)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 18))

            Text("mockLobby.discovery.privacy")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
