import SwiftUI

struct MockRoleCard: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let systemImage: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(.tint.opacity(0.14))
                        .clipShape(.circle)

                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(.tint.opacity(0.14))
                        .clipShape(.circle)

                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .contentShape(.rect)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .buttonStyle(.plain)
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 18))
    }
}
