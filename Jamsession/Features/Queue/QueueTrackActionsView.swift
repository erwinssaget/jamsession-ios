import SwiftUI

struct QueueTrackActionsView: View {
    let track: QueueSessionPresentation.Track
    let axis: Axis
    var remove: (() -> Void)?
    var skipTurn: (() -> Void)?

    var body: some View {
        Group {
            if axis == .horizontal {
                HStack {
                    if track.canSkipTurn, let skipTurn {
                        Button(
                            "queue.skipTurn",
                            systemImage: "arrow.turn.down.right",
                            action: skipTurn
                        )
                        .accessibilityIdentifier("queue.track.\(track.id.rawValue).skip")
                    }

                    if track.canRemove, let remove {
                        Button(
                            "queue.remove",
                            systemImage: "trash",
                            role: .destructive,
                            action: remove
                        )
                        .accessibilityIdentifier("queue.track.\(track.id.rawValue).remove")
                    }
                }
            } else {
                VStack {
                    if track.canSkipTurn, let skipTurn {
                        Button(
                            "queue.skipTurn",
                            systemImage: "arrow.turn.down.right",
                            action: skipTurn
                        )
                        .accessibilityIdentifier("queue.track.\(track.id.rawValue).skip")
                    }

                    if track.canRemove, let remove {
                        Button(
                            "queue.remove",
                            systemImage: "trash",
                            role: .destructive,
                            action: remove
                        )
                        .accessibilityIdentifier("queue.track.\(track.id.rawValue).remove")
                    }
                }
            }
        }
        .buttonStyle(.bordered)
    }
}
