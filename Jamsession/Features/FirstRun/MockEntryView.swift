import SwiftUI

struct MockEntryView: View {
    var onSelectRole: ((MockEntryRole) -> Void)?

    @State private var selectedRole: MockEntryRole?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Label("mockEntry.prototypeNotice", systemImage: "hammer")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading) {
                    Image(systemName: "music.note.house.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("mockEntry.hero.title")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityAddTraits(.isHeader)

                    Text("mockEntry.hero.description")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                MockRoleCard(
                    title: "mockEntry.host.title",
                    description: "mockEntry.host.description",
                    systemImage: "hifispeaker.2.fill",
                    accessibilityIdentifier: "mock.flow.role.host"
                ) {
                    select(.host)
                }

                MockRoleCard(
                    title: "mockEntry.join.title",
                    description: "mockEntry.join.description",
                    systemImage: "person.2.fill",
                    accessibilityIdentifier: "mock.flow.role.join"
                ) {
                    select(.join)
                }

                Text("mockEntry.ephemeral")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("mockEntry.title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedRole) { role in
            MockProfileSetupView(role: role)
        }
    }

    private func select(_ role: MockEntryRole) {
        if let onSelectRole {
            onSelectRole(role)
        } else {
            selectedRole = role
        }
    }
}

#Preview {
    NavigationStack {
        MockEntryView()
    }
}
