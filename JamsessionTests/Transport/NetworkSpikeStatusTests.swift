import Testing
@testable import Jamsession

struct NetworkSpikeStatusTests {
    @Test func completedGuestExchangeSurvivesBrowserCancellation() {
        let stoppedStatus = NetworkSpike.discoveryStoppedStatus(didCompleteExchange: true)

        #expect(stoppedStatus == nil)
    }

    @Test func cancellationWithoutExchangeReportsCleanStop() {
        let stoppedStatus = NetworkSpike.discoveryStoppedStatus(didCompleteExchange: false)

        #expect(stoppedStatus == "Discovery stopped cleanly.")
    }
}
