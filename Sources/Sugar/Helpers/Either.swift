import Vapor

/// A value that can one of two types
public enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either: ResponseEncodable where L: ResponseEncodable, R: ResponseEncodable {
    /// See `ResponseEncodable.encode`
    public func encode(for req: Request) throws -> Future<Response> {
        switch self {
        case .left(let left): return try left.encode(for: req)
        case .right(let right): return try right.encode(for: req)
        }
    }
}

extension Future {
    /// Transforms a `Future` into one that can be either the value or an error of a given type.
    ///
    /// - Parameter type: The `Error` type to be promoted.
    /// - Returns: A `Future` that yields either a value or an error.
    public func promoteErrors<E: Error>(ofType type: E.Type = E.self) -> Future<Either<T, E>> {
        return map(Either.left)
            .catchMap {
                guard let error = $0 as? E else {
                    throw $0
                }
                return .right(error)
            }
    }
}
