import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var musicSpike = MusicKitSpike()
    @State private var networkSpike = NetworkSpike()
    @State private var path = NavigationPath()

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
                    .disabled(!musicSpike.canControlPlayback)
                    Button("feasibility.skip") {
                        musicSpike.skip()
                    }
                    .disabled(!musicSpike.canControlPlayback)
                    #if DEBUG
                    Button("feasibility.mockQueue") {
                        path.append(FeasibilityDestination.mockQueue)
                    }
                    Button("feasibility.mockEntry") {
                        path.append(FeasibilityDestination.mockEntry)
                    }
                    Button("feasibility.mockFullFlow") {
                        path.append(FeasibilityDestination.mockFullFlow)
                    }
                    .accessibilityIdentifier("mock.flow.open")
                    Button("feasibility.mockLobby") {
                        path.append(FeasibilityDestination.mockLobby)
                    }
                    Button("feasibility.mockSearch") {
                        path.append(FeasibilityDestination.mockSearch)
                    }
                    Button("feasibility.mockLifecycle") {
                        path.append(FeasibilityDestination.mockLifecycle)
                    }
                    #endif
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
                    if networkSpike.needsSettings {
                        Button("feasibility.networkSettings", systemImage: "gear") {
                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            openURL(settingsURL)
                        }
                    }

                    Text(networkSpike.status)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Local network test status: \(networkSpike.status)")
                }
            }
            .navigationTitle("feasibility.title")
            #if DEBUG
            .navigationDestination(for: FeasibilityDestination.self) { destination in
                switch destination {
                case .mockEntry:
                    MockEntryView()
                case .mockFullFlow:
                    MockPrototypeFlowView()
                case .mockLifecycle:
                    MockLifecycleGalleryView()
                case .mockLobby:
                    MockLobbyGalleryView()
                case .mockQueue:
                    MockJoinedQueueView()
                case .mockSearch:
                    MockMusicSearchView(showsDoneButton: false)
                }
            }
            #endif
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
