import Foundation
import Network
import Observation

@Observable
@MainActor
final class NetworkSpike {
    static let serviceType = "_jamsession-spike._tcp"

    private(set) var status = "Choose Host or Discover. Local-network access is requested only then."
    private(set) var isRunning = false

    private var task: Task<Void, Never>?

    func startHosting() {
        replaceTask {
            do {
                let provider = BonjourListenerProvider(name: "Jamsession Slice 0", type: Self.serviceType)
                let listener = try NetworkListener(for: provider) {
                    TCP()
                }
                listener.onStateUpdate { [weak self] _, state in
                    self?.updateListenerState(state)
                }

                self.status = "Starting host and advertising the spike service…"
                try await listener.run { connection in
                    try await self.handleHostConnection(connection)
                }
                self.status = "Host stopped cleanly."
            } catch is CancellationError {
                self.status = "Host stopped cleanly."
            } catch {
                self.status = "Host failed: \(error.localizedDescription)"
            }
            self.isRunning = false
        }
    }

    func startBrowsing() {
        replaceTask {
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true
            let browser = NetworkBrowser(for: .bonjour(Self.serviceType), using: parameters)
            browser.onStateUpdate { [weak self] _, state in
                self?.updateBrowserState(state)
            }

            do {
                self.status = "Looking for a nearby Slice 0 host…"
                try await browser.run { endpoints -> NetworkBrowser<Bonjour>.RunResult<Void> in
                    guard let endpoint = endpoints.first else {
                        return .continue
                    }
                    try await self.handleGuestConnection(to: endpoint)
                    return .finish(())
                }
            } catch is CancellationError {
                self.status = "Discovery stopped cleanly."
            } catch {
                self.status = "Discovery or connection failed: \(error.localizedDescription)"
            }
            self.isRunning = false
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
        status = "Network spike stopped. Start it again to test reconnection."
    }

    private func handleHostConnection(_ connection: NetworkConnection<TCP>) async throws {
        let incoming = try await receiveMessage(from: connection)
        guard incoming.kind == .ping else {
            throw SpikeFrameError.malformedPayload
        }

        status = "Host received framed ping. Sending framed acknowledgment…"
        let acknowledgment = SpikeMessage(kind: .acknowledgment, text: "host-to-guest")
        try await connection.send(SpikeFrameCodec.encode(acknowledgment), endOfStream: true)
        status = "Bidirectional framed exchange completed. Waiting for another device…"
    }

    private func handleGuestConnection(to endpoint: Bonjour.Endpoint) async throws {
        let connection = NetworkConnection(to: endpoint) {
            TCP()
        }
        let ping = SpikeMessage(kind: .ping, text: "guest-to-host")
        try await connection.send(SpikeFrameCodec.encode(ping))
        status = "Guest sent framed ping. Waiting for host acknowledgment…"

        let incoming = try await receiveMessage(from: connection)
        guard incoming.kind == .acknowledgment else {
            throw SpikeFrameError.malformedPayload
        }
        status = "Bidirectional framed exchange completed and connection terminated cleanly."
    }

    private func receiveMessage(from connection: NetworkConnection<TCP>) async throws -> SpikeMessage {
        let header = try await connection.receive(exactly: SpikeFrameCodec.headerSize).content
        let payloadLength = try SpikeFrameCodec.payloadLength(from: header)
        let payload = try await connection.receive(exactly: payloadLength).content
        return try SpikeFrameCodec.decode(header + payload)
    }

    private func updateListenerState(_ state: NetworkListener<TCP>.State) {
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

    private func updateBrowserState(_ state: NetworkBrowser<Bonjour>.State) {
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

    private func replaceTask(_ operation: @escaping @MainActor @Sendable () async -> Void) {
        task?.cancel()
        isRunning = true
        task = Task {
            await operation()
        }
    }
}
