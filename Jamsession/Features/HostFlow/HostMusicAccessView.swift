import SwiftUI

struct HostMusicAccessView: View {
    let displayName: String
    let state: HostMusicAccessState
    let requestAccess: () -> Void
    let openSettings: () -> Void
    let cancel: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "music.note")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                    .frame(width: 88, height: 88)
                    .background(.tint.opacity(0.14))
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                Text("host.music.title")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("host.music.description")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                switch state {
                case .explanation:
                    Label("host.music.justInTime", systemImage: "hand.raised")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                case .checking:
                    ProgressView("host.music.checking")
                case .authorizationDenied:
                    Label("host.music.denied", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                case .authorizationRestricted:
                    Label("host.music.restricted", systemImage: "lock.fill")
                        .foregroundStyle(.orange)
                case .subscriptionRequired:
                    Label(
                        "host.music.subscriptionRequired",
                        systemImage: "person.crop.circle.badge.exclamationmark"
                    )
                    .foregroundStyle(.orange)
                case .unavailable:
                    Label(
                        "host.music.unavailable",
                        systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
                    )
                    .foregroundStyle(.orange)
                }

                if state == .authorizationDenied || state == .authorizationRestricted {
                    VStack {
                        Button(
                            "host.music.openSettings",
                            systemImage: "gear",
                            action: openSettings
                        )
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("host.flow.music.settings")

                        Button(
                            "host.music.tryAgain",
                            systemImage: "arrow.clockwise",
                            action: requestAccess
                        )
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("host.flow.music.retry")
                    }
                } else if state == .explanation {
                    Button(
                        "host.music.continue",
                        systemImage: "music.note",
                        action: requestAccess
                    )
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("host.flow.music.continue")
                } else if state != .checking {
                    Button(
                        "host.music.tryAgain",
                        systemImage: "arrow.clockwise",
                        action: requestAccess
                    )
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("host.flow.music.retry")
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("host.flow.back", action: cancel)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HostMusicAccessView(
            displayName: "Maya",
            state: .explanation,
            requestAccess: {},
            openSettings: {},
            cancel: {}
        )
    }
}
