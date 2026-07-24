import SwiftUI

struct QueueTrackRow: View {
    let track: QueueSessionPresentation.Track
    let position: Int
    var remove: (() -> Void)?
    var skipTurn: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text(position, format: .number)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 20)
                                .accessibilityHidden(true)

                            QueueArtworkView(title: track.title)

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
                    }
                } else {
                    HStack {
                        Text(position, format: .number)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 20)
                            .accessibilityHidden(true)

                        QueueArtworkView(title: track.title)

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

            if (track.canSkipTurn && skipTurn != nil) || (track.canRemove && remove != nil) {
                ViewThatFits(in: .horizontal) {
                    QueueTrackActionsView(
                        track: track,
                        axis: .horizontal,
                        remove: remove,
                        skipTurn: skipTurn
                    )

                    QueueTrackActionsView(
                        track: track,
                        axis: .vertical,
                        remove: remove,
                        skipTurn: skipTurn
                    )
                }
            }
        }
    }

    var accessibilityDescription: String {
        let base = String(
            localized: "queue.row.accessibility",
            defaultValue: "Up next \(position), \(track.title) by \(track.artist), added by \(track.submitter.name)"
        )
        return track.isExplicit
            ? "\(base), \(String(localized: "queue.explicit.full"))"
            : base
    }
}

#Preview("Long Title") {
    QueueTrackRow(track: MockSessionFixtures.longTitleTrack, position: 8)
        .padding()
}
