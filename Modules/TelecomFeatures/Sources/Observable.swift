import Foundation

/// Minimal value binding for MVVM in UIKit: the view subscribes, the view model publishes.
/// Dependency-free, so view models also build and test on Linux.
public final class Observable<Value> {
    public private(set) var value: Value
    private var observers: [UUID: (Value) -> Void] = [:]

    public init(_ value: Value) {
        self.value = value
    }

    func send(_ newValue: Value) {
        value = newValue
        observers.values.forEach { $0(newValue) }
    }

    /// Calls immediately with the current value, then on every change. Keep the token alive while observing.
    @discardableResult
    public func bind(_ observer: @escaping (Value) -> Void) -> ObservationToken {
        let id = UUID()
        observers[id] = observer
        observer(value)
        return ObservationToken { [weak self] in self?.observers[id] = nil }
    }
}

public final class ObservationToken {
    private let cancel: () -> Void
    init(_ cancel: @escaping () -> Void) { self.cancel = cancel }
    deinit { cancel() }
}
