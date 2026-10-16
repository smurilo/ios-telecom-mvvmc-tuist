import UIKit
import TelecomCore
import TelecomFeatures

@MainActor
final class AppCoordinator: Coordinator, HomeCoordinating {
    var children: [Coordinator] = []
    private let navigation = UINavigationController()
    private let window: UIWindow
    private let service: TelecomServicing
    private weak var homeViewModel: HomeViewModel?

    init(window: UIWindow, service: TelecomServicing) {
        self.window = window
        self.service = service
    }

    func start() {
        let viewModel = HomeViewModel(service: service)
        viewModel.coordinator = self
        homeViewModel = viewModel
        navigation.navigationBar.prefersLargeTitles = true
        navigation.setViewControllers([HomeViewController(viewModel: viewModel)], animated: false)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }

    func handle(_ link: DeepLink) {
        navigation.dismiss(animated: false)
        navigation.popToRootViewController(animated: false)
        switch link {
        case .home: break
        case .invoices: showInvoices()
        case let .offer(id): homeViewModel?.didTapOffer(id: id)
        }
    }

    // MARK: HomeCoordinating

    func showInvoices() {
        let child = InvoicesCoordinator(navigation: navigation, service: service)
        child.onFinish = { [weak self, weak child] in if let child { self?.remove(child) } }
        add(child)
        child.start()
    }

    func showOffer(_ offer: Offer, onPurchased: @escaping (PlanUsage) -> Void) {
        let child = OfferCoordinator(presenter: navigation, offer: offer, service: service)
        child.onFinish = { [weak self, weak child] usage in
            if let usage { onPurchased(usage) }
            if let child { self?.remove(child) }
        }
        add(child)
        child.start()
    }
}
