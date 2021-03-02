import Foundation
import Combine
import CombineCocoa
import CombineOperators
#if !COCOAPODS
import Moya
#endif

extension MoyaProvider: ReactiveCompatible {}

public extension Reactive where Base: MoyaProviderType {

    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response, MoyaError> {
			let owner = Owner()
			return Single { [weak base] promise in
					if !owner.isCancelled {
						owner.value = base?.request(token, callbackQueue: callbackQueue, progress: nil, completion: promise)
					}
				} onCancel: {
					owner.value?.cancel()
					owner.isCancelled = true
					owner.value = nil
				}
    }

    /// Designated request-making method with progress.
    func requestWithProgress(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<ProgressResponse, MoyaError> {
        let progressBlock: (AnySubscriber<ProgressResponse, MoyaError>) -> (ProgressResponse) -> Void = { observer in
            return { progress in
                _ = observer.receive(progress)
            }
        }

			let response = Publishers.Create<ProgressResponse, MoyaError> { [weak base] observer in
            let MoyaCancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: progressBlock(observer)) { result in
                switch result {
                case .success:
									observer.receive(completion: .finished)
                case let .failure(error):
									observer.receive(completion: .failure(error))
                }
            }
            return AnyCancellable {
                MoyaCancellableToken?.cancel()
            }
        }

        // Accumulate all progress and combine them when the result comes
        return response.scan(ProgressResponse()) { last, progress in
            let progressObject = progress.progressObject ?? last.progressObject
            let response = progress.response ?? last.response
            return ProgressResponse(progress: progressObject, response: response)
				}.any()
    }
}

private final class Owner {
	var value: MoyaCancellable?
	var isCancelled = false
}
