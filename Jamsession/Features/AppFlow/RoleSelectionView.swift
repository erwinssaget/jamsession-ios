import SwiftUI

struct RoleSelectionView: View {
    let selectRole: (SessionRole) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Image(systemName: "music.note.house.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("app.role.hero.title")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityAddTraits(.isHeader)

                    Text("app.role.hero.description")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                RoleSelectionCard(
                    title: "app.role.host.title",
                    description: "app.role.host.description",
                    systemImage: "hifispeaker.2.fill",
                    accessibilityIdentifier: "app.role.host"
                ) {
                    selectRole(.host)
                }

                RoleSelectionCard(
                    title: "app.role.join.title",
                    description: "app.role.join.description",
                    systemImage: "person.2.fill",
                    accessibilityIdentifier: "app.role.join"
                ) {
                    selectRole(.join)
                }

                Label("app.role.ephemeral", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("app.role.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView(selectRole: { _ in })
    }
}
