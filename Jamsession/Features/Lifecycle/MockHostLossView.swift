import SwiftUI

struct MockHostLossView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text("mockLifecycle.hostLoss.title")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            Text("mockLifecycle.hostLoss.description")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("00:24")
                .font(.title.monospacedDigit())
                .accessibilityLabel("mockLifecycle.hostLoss.countdownAccessibility")

            Label("mockLifecycle.hostLoss.fixtureNotice", systemImage: "hammer")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        MockHostLossView()
            .padding()
    }
}
