import UIKit

/// Coordinators own navigation. View controllers stay reusable and unaware of the flow they are in.
@MainActor
protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func add(_ child: Coordinator) { children.append(child) }
    func remove(_ child: Coordinator) { children.removeAll { $0 === child } }
}
