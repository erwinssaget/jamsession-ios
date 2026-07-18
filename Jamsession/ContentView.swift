import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var musicSpike = MusicKitSpike()
    @State private var networkSpike = NetworkSpike()
    @State private var path: [FeasibilityDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section("feasibility.music.section") {
                    TextField("feasibility.searchPlaceholder", text: $musicSpike.query)
                        .textInputAutocapitalization(.never)

                    Button("feasibility.host") {
                        musicSpike.startHostTest()
                    }
                    Button("feasibility.guest") {
                        musicSpike.startGuestSearchTest()
                    }
                    Button("feasibility.play") {
                        musicSpike.queueAndPlayFirstResult()
                    }
                    .disabled(!musicSpike.canPlayFirstResult)
                    Button("feasibility.pause") {
                        musicSpike.pause()
                    }
                    Button("feasibility.skip") {
                        musicSpike.skip()
                    }
                    Button("feasibility.mockQueue") {
                        path.append(.mockQueue)
                    }
                    if musicSpike.needsSettings {
                        Button("feasibility.settings", systemImage: "gear") {
                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            openURL(settingsURL)
                        }
                    }

                    Text(musicSpike.status)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Apple Music test status: \(musicSpike.status)")
                }

                Section("feasibility.network.section") {
                    Button("feasibility.hostNetwork") {
                        networkSpike.startHosting()
                    }
                    Button("feasibility.joinNetwork") {
                        networkSpike.startBrowsing()
                    }
                    Button("feasibility.stopNetwork") {
                        networkSpike.stop()
                    }
                    .disabled(!networkSpike.isRunning)

                    Text(networkSpike.status)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Local network test status: \(networkSpike.status)")
                }
            }
            .navigationTitle("feasibility.title")
            .navigationDestination(for: FeasibilityDestination.self) { destination in
                switch destination {
                case .mockQueue:
                    MockJoinedQueueView()
                }
            }
        }
        .onDisappear {
            musicSpike.cancel()
            networkSpike.stop()
        }
    }
}

#Preview {
    ContentView()
}
