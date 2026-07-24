import SwiftUI

struct MockQueueRow: View {
    let track: MockSessionPresentation.Track
    let position: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading) {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .top) {
                    Text(position, format: .number)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 20)
                        .accessibilityHidden(true)

                    MockArtworkView(title: track.title)

                    Spacer()

                    ParticipantBadgeView(participant: track.submitter)
                }

                VStack(alignment: .leading) {
                    Text(track.title)
                        .fixedSize(horizontal: false, vertical: true)

                    if track.isExplicit {
                        ExplicitBadgeView()
                    }

                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack {
                    Text(position, format: .number)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 20)
                        .accessibilityHidden(true)

                    MockArtworkView(title: track.title)

                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text(track.title)
                                .fixedSize(horizontal: false, vertical: true)
                            if track.isExplicit {
                                ExplicitBadgeView()
                            }
                        }
                        Text(track.artist)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    ParticipantBadgeView(participant: track.submitter)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let base = String(
            localized: "mockQueue.row.accessibility",
            defaultValue: "Up next \(position), \(track.title) by \(track.artist), added by \(track.submitter.name)"
        )
        return track.isExplicit
            ? "\(base), \(String(localized: "mockQueue.explicit.full"))"
            : base
    }
}

#Preview("Long Title") {
    MockQueueRow(track: MockSessionFixtures.longTitleTrack, position: 8)
        .padding()
}
