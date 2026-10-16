import Foundation
import TelecomCore

/// MVVM-C: the view model never navigates by itself; it asks its coordinator.
@MainActor
public protocol HomeCoordinating: AnyObject {
    func showInvoices()
    func showOffer(_ offer: Offer, onPurchased: @escaping (PlanUsage) -> Void)
}

public struct HomeState: Equatable {
    public enum Phase: Equatable { case loading, loaded, failed(String) }
    public var phase: Phase = .loading
    public var planName = ""
    public var phone = ""
    public var usageText = ""
    public var usedRatio = 0.0
    public var isNearLimit = false
    public var openInvoiceText: String?
    public var offers: [Offer] = []
}

@MainActor
public final class HomeViewModel {
    public let state = Observable(HomeState())
    public weak var coordinator: HomeCoordinating?
    private let service: TelecomServicing

    public init(service: TelecomServicing) {
        self.service = service
    }

    public func load() async {
        var s = state.value
        s.phase = .loading
        state.send(s)
        do {
            async let usage = service.usage()
            async let invoices = service.invoices()
            async let offers = service.offers()
            apply(try await usage, invoices: try await invoices, offers: try await offers)
        } catch {
            s.phase = .failed("Não foi possível carregar seus dados. Puxe para tentar de novo.")
            state.send(s)
        }
    }

    public func didTapInvoices() { coordinator?.showInvoices() }

    public func didTapOffer(id: String) {
        guard let offer = state.value.offers.first(where: { $0.id == id }) else { return }
        coordinator?.showOffer(offer) { [weak self] usage in self?.apply(usage) }
    }

    private func apply(_ usage: PlanUsage, invoices: [Invoice]? = nil, offers: [Offer]? = nil) {
        var s = state.value
        s.phase = .loaded
        s.planName = usage.planName
        s.phone = usage.msisdn
        s.usedRatio = usage.usedRatio
        s.isNearLimit = usage.usedRatio >= 0.8
        s.usageText = "Restam \(Formatters.gigabytes(fromMB: usage.remainingMB)) de \(Formatters.gigabytes(fromMB: usage.dataTotalMB))"
        if let invoices {
            s.openInvoiceText = invoices.first { $0.status != .paid }.map { "Fatura de \($0.month): \(Formatters.money($0.amount))" }
        }
        if let offers { s.offers = offers }
        state.send(s)
    }
}
