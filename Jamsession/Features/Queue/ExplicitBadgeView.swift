import SwiftUI

struct ExplicitBadgeView: View {
    var body: some View {
        Text("mockQueue.explicit")
            .font(.caption2)
            .padding(.horizontal, 4)
            .background(.secondary.opacity(0.2))
            .clipShape(.rect(cornerRadius: 3))
            .accessibilityLabel("mockQueue.explicit.full")
    }
}
