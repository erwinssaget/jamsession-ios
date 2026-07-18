import SwiftUI

struct MockJoinedQueueView: View {
    var body: some View {
        ContentUnavailableView(
            "mockQueue.title",
            systemImage: "music.note.list",
            description: Text("mockQueue.empty")
        )
        .navigationTitle("mockQueue.title")
    }
}
