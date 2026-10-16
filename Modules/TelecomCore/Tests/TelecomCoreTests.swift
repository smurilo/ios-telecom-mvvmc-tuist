import XCTest
@testable import TelecomCore

final class TelecomCoreTests: XCTestCase {

    func testDeepLinkParsing() {
        XCTAssertEqual(DeepLink(url: URL(string: "minhalinha://faturas")!), .invoices)
        XCTAssertEqual(DeepLink(url: URL(string: "minhalinha://ofertas/o2")!), .offer(id: "o2"))
        XCTAssertEqual(DeepLink(url: URL(string: "minhalinha://")!), .home)
        XCTAssertNil(DeepLink(url: URL(string: "https://faturas")!))
        XCTAssertNil(DeepLink(url: URL(string: "minhalinha://ofertas")!))
    }

    func testFormatters() {
        XCTAssertEqual(Formatters.gigabytes(fromMB: 4_096), "4,0 GB")
        XCTAssertEqual(Formatters.gigabytes(fromMB: 25_600), "25 GB")
        XCTAssertEqual(Formatters.money(Decimal(string: "1234.5")!), "R$ 1.234,50")
    }

    func testPurchaseIncreasesAllowance() async throws {
        let service = MockTelecomService(latencyMs: 0)
        let before = try await service.usage()
        let after = try await service.purchase(offerId: "o2")
        XCTAssertEqual(after.dataTotalMB - before.dataTotalMB, 5_120)
    }
}
