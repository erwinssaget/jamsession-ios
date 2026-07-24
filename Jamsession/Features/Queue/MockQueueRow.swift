import SwiftUI

struct MockQueueRow: View {
    let track: MockSessionPresentation.Track
    let position: Int

    var body: some View {
        HStack {
            Text(position, format: .number)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 20)
                .accessibilityHidden(true)

            MockArtworkView(title: track.title)

            VStack(alignment: .leading) {
                HStack {
                    Text(track.title)
                        .lineLimit(1)
                    if track.isExplicit {
                        Text("mockQueue.explicit")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(.secondary.opacity(0.2))
                            .clipShape(.rect(cornerRadius: 3))
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
