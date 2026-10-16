import Foundation
import TelecomCore

@MainActor
public protocol OfferCoordinating: AnyObject {
    func offerDidFinish(purchased usage: PlanUsage?)
}

public struct OfferState: Equatable {
    public var title: String
    public var priceText: String
    public var isPurchasing = false
    public var error: String?
}

@MainActor
public final class OfferViewModel {
    public let state: Observable<OfferState>
    public weak var coordinator: OfferCoordinating?
    private let offer: Offer
    private let service: TelecomServicing

    public init(offer: Offer, service: TelecomServicing) {
        self.offer = offer
        self.service = service
        state = Observable(OfferState(title: offer.title, priceText: Formatters.money(offer.price)))
    }

    public func confirm() async {
        guard !state.value.isPurchasing else { return } // double tap protection
        var s = state.value
        s.isPurchasing = true
        s.error = nil
        state.send(s)
        do {
            let usage = try await service.purchase(offerId: offer.id)
            coordinator?.offerDidFinish(purchased: usage)
        } catch {
            s.isPurchasing = false
            s.error = "Não foi possível concluir a compra. Nada foi cobrado."
            state.send(s)
        }
    }

    public func cancel() { coordinator?.offerDidFinish(purchased: nil) }
}
