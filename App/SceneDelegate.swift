import UIKit
import TelecomCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window, service: MockTelecomService())
        coordinator.start()
        self.window = window
        self.coordinator = coordinator
        options.urlContexts.first.flatMap { DeepLink(url: $0.url) }.map(coordinator.handle)
    }

    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        contexts.first.flatMap { DeepLink(url: $0.url) }.map { coordinator?.handle($0) }
    }
}
