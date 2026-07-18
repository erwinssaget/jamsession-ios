import Foundation
import Testing
@testable import Jamsession

struct SpikeFrameCodecTests {
    @Test func roundTrip() throws {
        let message = SpikeMessage(kind: .ping, text: "guest-to-host")

        let frame = try SpikeFrameCodec.encode(message)

        #expect(try SpikeFrameCodec.decode(frame) == message)
    }

    @Test func rejectsOversizedFrameBeforeReadingPayload() throws {
        let oversizedLength = UInt32(SpikeFrameCodec.maximumPayloadSize + 1).bigEndian
        let header = withUnsafeBytes(of: oversizedLength) { Data($0) }

        #expect(throws: SpikeFrameError.payloadTooLarge(
            actual: SpikeFrameCodec.maximumPayloadSize + 1,
            maximum: SpikeFrameCodec.maximumPayloadSize
        )) {
            try SpikeFrameCodec.payloadLength(from: header)
        }
    }

    @Test func rejectsTruncatedHeader() {
        #expect(throws: SpikeFrameError.truncatedHeader) {
            try SpikeFrameCodec.decode(Data([0, 0, 0]))
        }
    }

    @Test func rejectsTruncatedPayload() throws {
        let frame = try SpikeFrameCodec.encode(SpikeMessage(kind: .ping, text: "hello"))

        #expect(throws: (any Error).self) {
            try SpikeFrameCodec.decode(frame.dropLast())
        }
    }

    @Test func rejectsMalformedPayload() {
        let malformed = Data([0, 0, 0, 1, 0xFF])

        #expect(throws: SpikeFrameError.malformedPayload) {
            try SpikeFrameCodec.decode(malformed)
        }
    }

    @Test func rejectsTrailingBytes() throws {
        var frame = try SpikeFrameCodec.encode(SpikeMessage(kind: .ping, text: "hello"))
        frame.append(0)

        #expect(throws: SpikeFrameError.trailingBytes) {
            try SpikeFrameCodec.decode(frame)
        }
    }
}
