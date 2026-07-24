import SwiftUI

struct MockNowPlayingView: View {
    let track: MockSessionPresentation.Track

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    Image(systemName: "waveform")
                    Text("mockQueue.nowPlaying")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.headline)
                .foregroundStyle(.secondary)
            } else {
                Label("mockQueue.nowPlaying", systemImage: "waveform")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    MockArtworkView(title: track.title, size: 72)

                    Text(track.title)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    if track.isExplicit {
                        ExplicitBadgeView()
                    }
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Label {
                        Text(
                            String(
                                localized: "mockQueue.addedBy",
                                defaultValue: "Added by \(track.submitter.name)"
                            )
                        )
                    } icon: {
                        Text(track.submitter.emoji)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    MockArtworkView(title: track.title, size: 72)

                    VStack(alignment: .leading) {
                        Text(track.title)
                            .font(.headline)
                            .lineLimit(2)
                        if track.isExplicit {
                            ExplicitBadgeView()
                        }
                        Text(track.artist)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Label {
                            Text(
                                String(
                                    localized: "mockQueue.addedBy",
                                    defaultValue: "Added by \(track.submitter.name)"
                                )
                            )
                        } icon: {
                            Text(track.submitter.emoji)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    var accessibilityDescription: String {
        let base = String(
            localized: "mockQueue.nowPlaying.accessibility",
            defaultValue: "Now playing \(track.title) by \(track.artist), added by \(track.submitter.name)"
        )
        return track.isExplicit
            ? "\(base), \(String(localized: "mockQueue.explicit.full"))"
            : base
    }
}

#Preview("Long Explicit Track") {
    MockNowPlayingView(track: MockSessionFixtures.longTitleTrack)
        .padding()
}
