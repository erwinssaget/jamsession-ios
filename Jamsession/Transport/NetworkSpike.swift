import Foundation
import Network
import Observation

@Observable
@MainActor
final class NetworkSpike {
    static let serviceType = "_jamsession._tcp"

    private(set) var status = "Choose Host or Discover. Local-network access is requested only then."
    private(set) var isRunning = false

    private var task: Task<Void, Never>?
    private var runGeneration = 0

    func startHosting() {
        replaceTask { generation in
            do {
                let provider = BonjourListenerProvider(name: "Jamsession Slice 0", type: Self.serviceType)
                let listener = try NetworkListener(for: provider) {
                    TCP()
                }
                listener.onStateUpdate { [weak self] _, state in
                    self?.updateListenerState(state, generation: generation)
                }

                self.updateStatus(
                    "Starting host and advertising the spike service…",
                    generation: generation
                )
                try await listener.run { connection in
                    try await self.handleHostConnection(connection, generation: generation)
                }
                self.updateStatus("Host stopped cleanly.", generation: generation)
            } catch is CancellationError {
                self.updateStatus("Host stopped cleanly.", generation: generation)
            } catch {
                self.updateStatus("Host failed: \(error.localizedDescription)", generation: generation)
            }
            self.finishRun(generation)
        }
    }

    func startBrowsing() {
        replaceTask { generation in
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true
            let browser = NetworkBrowser(for: .bonjour(Self.serviceType), using: parameters)
            browser.onStateUpdate { [weak self] _, state in
                self?.updateBrowserState(state, generation: generation)
            }

            do {
                self.updateStatus("Looking for a nearby Slice 0 host…", generation: generation)
                try await browser.run { endpoints -> NetworkBrowser<Bonjour>.RunResult<Void> in
                    guard let endpoint = endpoints.first else {
                        return .continue
                    }
                    try await self.handleGuestConnection(to: endpoint, generation: generation)
                    return .finish(())
                }
            } catch is CancellationError {
                self.updateStatus("Discovery stopped cleanly.", generation: generation)
            } catch {
                self.updateStatus(
                    "Discovery or connection failed: \(error.localizedDescription)",
                    generation: generation
                )
            }
            self.finishRun(generation)
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        runGeneration += 1
        isRunning = false
        status = "Network spike stopped. Start it again to test reconnection."
    }

    private func handleHostConnection(
        _ connection: NetworkConnection<TCP>,
        generation: Int
    ) async throws {
        let incoming = try await receiveMessage(from: connection)
        guard incoming.kind == .ping else {
            throw SpikeFrameError.malformedPayload
        }

        updateStatus(
            "Host received framed ping. Sending framed acknowledgment…",
            generation: generation
        )
        let acknowledgment = SpikeMessage(kind: .acknowledgment, text: "host-to-guest")
        try await connection.send(SpikeFrameCodec.encode(acknowledgment), endOfStream: true)
        updateStatus(
            "Bidirectional framed exchange completed. Waiting for another device…",
            generation: generation
        )
    }

    private func handleGuestConnection(
        to endpoint: Bonjour.Endpoint,
        generation: Int
    ) async throws {
        let connection = NetworkConnection(to: endpoint) {
            TCP()
        }
        let ping = SpikeMessage(kind: .ping, text: "guest-to-host")
        try await connection.send(SpikeFrameCodec.encode(ping))
        updateStatus(
            "Guest sent framed ping. Waiting for host acknowledgment…",
            generation: generation
        )

        let incoming = try await receiveMessage(from: connection)
        guard incoming.kind == .acknowledgment else {
            throw SpikeFrameError.malformedPayload
        }
        updateStatus(
            "Bidirectional framed exchange completed and connection terminated cleanly.",
            generation: generation
        )
    }

    private func receiveMessage(from connection: NetworkConnection<TCP>) async throws -> SpikeMessage {
        let header = try await connection.receive(exactly: SpikeFrameCodec.headerSize).content
        let payloadLength = try SpikeFrameCodec.payloadLength(from: header)
        let payload = try await connection.receive(exactly: payloadLength).content
        return try SpikeFrameCodec.decode(header + payload)
    }

    private func updateListenerState(_ state: NetworkListener<TCP>.State, generation: Int) {
        guard generation == runGeneration else {
            return
        }

        switch state {
        case .ready:
            status = "Host is advertising and ready for a nearby device."
        case .waiting(let error):
            status = "Host is waiting: \(error.localizedDescription)"
        case .failed(let error):
            status = "Host failed: \(error.localizedDescription)"
        case .cancelled:
            status = "Host stopped cleanly."
        case .setup:
            break
        @unknown default:
            status = "Host entered an unknown state."
        }
    }

    private func updateBrowserState(_ state: NetworkBrowser<Bonjour>.State, generation: Int) {
        guard generation == runGeneration else {
            return
        }

        switch state {
        case .ready:
            status = "Local-network access is available; no nearby host has been selected yet."
        case .waiting(let error):
            status = "Discovery is waiting: \(error.localizedDescription)"
        case .failed(let error):
            status = "Discovery failed (permission or network error): \(error.localizedDescription)"
        case .cancelled:
            status = "Discovery stopped cleanly."
        case .setup:
            break
        @unknown default:
            status = "Discovery entered an unknown state."
        }
    }

    private func updateStatus(_ newStatus: String, generation: Int) {
        guard generation == runGeneration else {
            return
        }
        status = newStatus
    }

    private func finishRun(_ generation: Int) {
        guard generation == runGeneration else {
            return
        }
        isRunning = false
        task = nil
    }

    private func replaceTask(
        _ operation: @escaping @MainActor @Sendable (_ generation: Int) async -> Void
    ) {
        task?.cancel()
        runGeneration += 1
        let generation = runGeneration
        isRunning = true
        task = Task {
            await operation(generation)
        }
    }
}
