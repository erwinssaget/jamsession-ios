import SwiftUI

struct MockReduceMotionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var reduceMotionOverride: Bool?

    private var isReduceMotionEnabled: Bool {
        reduceMotionOverride ?? reduceMotion
    }

    var body: some View {
        VStack(alignment: .leading) {
            MockLifecycleStatusCard(
                title: "mockLifecycle.reduceMotion.title",
                description: "mockLifecycle.reduceMotion.description",
                systemImage: "figure.walk.motion",
                tint: .blue
            )

            Label(
                isReduceMotionEnabled
                    ? "mockLifecycle.reduceMotion.enabled"
                    : "mockLifecycle.reduceMotion.preview",
                systemImage: isReduceMotionEnabled ? "checkmark.circle.fill" : "eye"
            )
            .font(.headline)

            Text("mockLifecycle.reduceMotion.behavior")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    MockReduceMotionView(reduceMotionOverride: true)
        .padding()
}
