import XCTest
import TelecomCore
@testable import TelecomFeatures

@MainActor
final class SpyHomeCoordinator: HomeCoordinating {
    var showedInvoices = false
    var offer: Offer?
    var purchaseCallback: ((PlanUsage) -> Void)?
    func showInvoices() { showedInvoices = true }
    func showOffer(_ offer: Offer, onPurchased: @escaping (PlanUsage) -> Void) {
        self.offer = offer
        purchaseCallback = onPurchased
    }
}

@MainActor
final class SpyOfferCoordinator: OfferCoordinating {
    var finished: [PlanUsage?] = []
    func offerDidFinish(purchased usage: PlanUsage?) { finished.append(usage) }
}

struct FailingService: TelecomServicing {
    func usage() async throws -> PlanUsage { throw TelecomError.network }
    func invoices() async throws -> [Invoice] { [] }
    func offers() async throws -> [Offer] { [] }
    func purchase(offerId: String) async throws -> PlanUsage { throw TelecomError.insufficientCredit }
}

@MainActor
final class ViewModelTests: XCTestCase {

    func testHomeLoadsAndFlagsNearLimit() async {
        let vm = HomeViewModel(service: MockTelecomService(latencyMs: 0))
        var phases: [HomeState.Phase] = []
        let token = vm.state.bind { phases.append($0.phase) }

        await vm.load()

        XCTAssertEqual(phases, [.loading, .loading, .loaded])
        XCTAssertEqual(vm.state.value.usageText, "Restam 4,0 GB de 25 GB")
        XCTAssertTrue(vm.state.value.isNearLimit)
        XCTAssertEqual(vm.state.value.openInvoiceText, "Fatura de Março: R$ 59,90")
        withExtendedLifetime(token) {}
    }

    func testHomeFailureMessage() async {
        let vm = HomeViewModel(service: FailingService())
        await vm.load()
        guard case .failed = vm.state.value.phase else { return XCTFail("expected failure") }
    }

    func testNavigationGoesThroughCoordinatorAndPurchaseUpdatesHome() async {
        let service = MockTelecomService(latencyMs: 0)
        let vm = HomeViewModel(service: service)
        let coordinator = SpyHomeCoordinator()
        vm.coordinator = coordinator
        await vm.load()

        vm.didTapInvoices()
        vm.didTapOffer(id: "o2")
        XCTAssertTrue(coordinator.showedInvoices)
        XCTAssertEqual(coordinator.offer?.id, "o2")

        coordinator.purchaseCallback?(try! await service.purchase(offerId: "o2"))
        XCTAssertEqual(vm.state.value.usageText, "Restam 9,0 GB de 30 GB")
        XCTAssertFalse(vm.state.value.isNearLimit)
    }

    func testOfferFailureKeepsScreenWithMessage() async {
        let vm = OfferViewModel(offer: Offer(id: "o1", title: "+1 GB", extraMB: 1024, price: 9.99), service: FailingService())
        let coordinator = SpyOfferCoordinator()
        vm.coordinator = coordinator

        await vm.confirm()

        XCTAssertTrue(coordinator.finished.isEmpty)
        XCTAssertEqual(vm.state.value.error, "Não foi possível concluir a compra. Nada foi cobrado.")
        XCTAssertFalse(vm.state.value.isPurchasing)
    }

    func testObservationStopsWhenTokenIsReleased() async {
        let vm = HomeViewModel(service: MockTelecomService(latencyMs: 0))
        var calls = 0
        var token: ObservationToken? = vm.state.bind { _ in calls += 1 }
        XCTAssertEqual(calls, 1)
        token = nil
        await vm.load()
        XCTAssertEqual(calls, 1)
        _ = token
    }
}
