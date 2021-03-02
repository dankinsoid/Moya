/// Protocol to define the opaque type returned from a request.
import Combine

public protocol MoyaCancellable: Cancellable {

    /// A Boolean value stating whether a request is cancelled.
    var isCancelled: Bool { get }
}

internal class MoyaCancellableWrapper: MoyaCancellable {
    internal var innerMoyaCancellable: MoyaCancellable = SimpleMoyaCancellable()

    var isCancelled: Bool { return innerMoyaCancellable.isCancelled }

    internal func cancel() {
        innerMoyaCancellable.cancel()
    }
}

internal class SimpleMoyaCancellable: MoyaCancellable {
    var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}
