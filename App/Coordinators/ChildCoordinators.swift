import UIKit
import TelecomCore
import TelecomFeatures

@MainActor
final class InvoicesCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var children: [Coordinator] = []
    var onFinish: (() -> Void)?
    private let navigation: UINavigationController
    private let service: TelecomServicing

    init(navigation: UINavigationController, service: TelecomServicing) {
        self.navigation = navigation
        self.service = service
    }

    func start() {
        navigation.delegate = self
        navigation.pushViewController(InvoicesViewController(service: service), animated: true)
    }

    /// Detects the back-swipe so the child coordinator is released (no leaked coordinators).
    func navigationController(_ nav: UINavigationController, didShow vc: UIViewController, animated: Bool) {
        guard let from = nav.transitionCoordinator?.viewController(forKey: .from),
              !nav.viewControllers.contains(from), from is InvoicesViewController else { return }
        nav.delegate = nil
        onFinish?()
    }
}

@MainActor
final class OfferCoordinator: Coordinator, OfferCoordinating {
    var children: [Coordinator] = []
    var onFinish: ((PlanUsage?) -> Void)?
    private let presenter: UIViewController
    private let offer: Offer
    private let service: TelecomServicing

    init(presenter: UIViewController, offer: Offer, service: TelecomServicing) {
        self.presenter = presenter
        self.offer = offer
        self.service = service
    }

    func start() {
        let viewModel = OfferViewModel(offer: offer, service: service)
        viewModel.coordinator = self
        let sheet = UINavigationController(rootViewController: OfferViewController(viewModel: viewModel))
        sheet.sheetPresentationController?.detents = [.medium()]
        presenter.present(sheet, animated: true)
    }

    func offerDidFinish(purchased usage: PlanUsage?) {
        presenter.dismiss(animated: true)
        onFinish?(usage)
    }
}
