import Foundation

nonisolated enum SpikeFrameError: Error, Equatable, Sendable {
    case payloadTooLarge(actual: Int, maximum: Int)
    case truncatedHeader
    case truncatedPayload(expected: Int, actual: Int)
    case trailingBytes
    case malformedPayload
}

nonisolated enum SpikeFrameCodec {
    static let headerSize = MemoryLayout<UInt32>.size
    static let maximumPayloadSize = 4_096

    static func encode(_ message: SpikeMessage) throws -> Data {
        let payload = try JSONEncoder().encode(message)
        guard payload.count <= maximumPayloadSize else {
            throw SpikeFrameError.payloadTooLarge(actual: payload.count, maximum: maximumPayloadSize)
        }

        var length = UInt32(payload.count).bigEndian
        var frame = Data(bytes: &length, count: headerSize)
        frame.append(payload)
        return frame
    }

    static func payloadLength(from header: Data) throws -> Int {
        guard header.count == headerSize else {
            throw SpikeFrameError.truncatedHeader
        }

        let length = header.reduce(UInt32.zero) { partial, byte in
            (partial << 8) | UInt32(byte)
        }
        guard length <= maximumPayloadSize else {
            throw SpikeFrameError.payloadTooLarge(actual: Int(length), maximum: maximumPayloadSize)
        }
        return Int(length)
    }

    static func decode(_ frame: Data) throws -> SpikeMessage {
        guard frame.count >= headerSize else {
            throw SpikeFrameError.truncatedHeader
        }

        let expectedLength = try payloadLength(from: frame.prefix(headerSize))
        let payload = frame.dropFirst(headerSize)
        guard payload.count >= expectedLength else {
            throw SpikeFrameError.truncatedPayload(expected: expectedLength, actual: payload.count)
        }
        guard payload.count == expectedLength else {
            throw SpikeFrameError.trailingBytes
        }

        do {
            return try JSONDecoder().decode(SpikeMessage.self, from: payload)
        } catch {
            throw SpikeFrameError.malformedPayload
        }
    }
}
