import SwiftUI

struct MockLocalizationExpansionView: View {
    var body: some View {
        VStack(alignment: .leading) {
            MockLifecycleStatusCard(
                title: "mockLifecycle.localization.title",
                description: "mockLifecycle.localization.description",
                systemImage: "character.bubble.fill",
                tint: .purple
            )

            Button("mockLifecycle.localization.expandedPrimaryAction", systemImage: "person.2.fill") {}
                .buttonStyle(.borderedProminent)

            Text("mockLifecycle.localization.expandedSupportingCopy")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ScrollView {
        MockLocalizationExpansionView()
            .padding()
    }
}
