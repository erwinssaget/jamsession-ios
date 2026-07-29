import SwiftUI

struct JoinUnavailableView: View {
    let chooseAnotherRole: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("app.join.unavailable.title", systemImage: "person.2.slash")
        } description: {
            Text("app.join.unavailable.description")
        } actions: {
            Button(
                "app.join.unavailable.back",
                systemImage: "chevron.backward",
                action: chooseAnotherRole
            )
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("app.join.unavailable.back")
        }
        .navigationTitle("app.role.join.title")
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        JoinUnavailableView(chooseAnotherRole: {})
    }
}
