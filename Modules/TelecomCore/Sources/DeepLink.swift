import Foundation

/// Routes coming from push notifications, SMS links or Siri Shortcuts, e.g. minhalinha://ofertas/o2
public enum DeepLink: Equatable, Sendable {
    case home
    case invoices
    case offer(id: String)

    public init?(url: URL) {
        guard url.scheme == "minhalinha" else { return nil }
        let parts = ([url.host].compactMap { $0 } + url.pathComponents).filter { !$0.isEmpty && $0 != "/" }
        switch parts.first {
        case nil, "inicio": self = .home
        case "faturas": self = .invoices
        case "ofertas" where parts.count == 2: self = .offer(id: parts[1])
        default: return nil
        }
    }
}
