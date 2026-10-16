import Foundation

public protocol TelecomServicing: Sendable {
    func usage() async throws -> PlanUsage
    func invoices() async throws -> [Invoice]
    func offers() async throws -> [Offer]
    func purchase(offerId: String) async throws -> PlanUsage
}

/// In-memory backend used by the showcase app and by UI previews.
public actor MockTelecomService: TelecomServicing {
    private var current: PlanUsage
    private let latency: UInt64

    public init(latencyMs: UInt64 = 500, now: Date = Date()) {
        latency = latencyMs * 1_000_000
        current = PlanUsage(planName: "Controle 25GB", msisdn: "(82) 99999-0000", dataTotalMB: 25_600,
                            dataUsedMB: 21_504, renewsOn: now.addingTimeInterval(9 * 86_400))
    }

    public func usage() async throws -> PlanUsage {
        try await Task.sleep(nanoseconds: latency)
        return current
    }

    public func invoices() async throws -> [Invoice] {
        try await Task.sleep(nanoseconds: latency)
        let now = Date()
        return [
            Invoice(id: "i3", month: "Março", amount: Decimal(string: "59.90")!, dueDate: now.addingTimeInterval(5 * 86_400), status: .open, barcode: "84670000001-5 59900138001-1"),
            Invoice(id: "i2", month: "Fevereiro", amount: Decimal(string: "59.90")!, dueDate: now.addingTimeInterval(-25 * 86_400), status: .paid, barcode: ""),
        ]
    }

    public func offers() async throws -> [Offer] {
        [
            Offer(id: "o1", title: "+1 GB por 7 dias", extraMB: 1_024, price: Decimal(string: "9.99")!),
            Offer(id: "o2", title: "+5 GB por 30 dias", extraMB: 5_120, price: Decimal(string: "29.99")!),
        ]
    }

    public func purchase(offerId: String) async throws -> PlanUsage {
        try await Task.sleep(nanoseconds: latency)
        guard let offer = try await offers().first(where: { $0.id == offerId }) else { throw TelecomError.network }
        current = PlanUsage(planName: current.planName, msisdn: current.msisdn, dataTotalMB: current.dataTotalMB + offer.extraMB,
                            dataUsedMB: current.dataUsedMB, renewsOn: current.renewsOn)
        return current
    }
}
