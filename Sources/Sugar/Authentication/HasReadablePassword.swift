/// Types conforming to this protocol can be used for login or register requests.
public protocol HasReadablePassword: Decodable {
    /// Key path to the readable password.
    static var readablePasswordKey: KeyPath<Self, String> { get }
}
