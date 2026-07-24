import SwiftUI

struct MockLifecycleStatusCard: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(tint)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.12))
        .clipShape(.rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}
