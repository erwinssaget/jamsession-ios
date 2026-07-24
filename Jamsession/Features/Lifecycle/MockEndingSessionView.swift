import SwiftUI

struct MockEndingSessionView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("mockLifecycle.ending.title")
                .font(.title2)
                .bold()
            Text("mockLifecycle.ending.description")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("mockLifecycle.ending.fixtureNotice")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
