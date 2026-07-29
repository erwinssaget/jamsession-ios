import SwiftUI

struct RoleSelectionCard: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let systemImage: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(.tint.opacity(0.14))
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .padding()
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
