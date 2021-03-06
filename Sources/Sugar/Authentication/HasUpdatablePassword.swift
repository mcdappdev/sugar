/// Types conforming to this protocol can be used for change password requests.
public protocol HasUpdatablePassword {
    /// The keypath to the optional password.
    static var updatablePasswordKey: KeyPath<Self, String?> { get }

    /// The keypath to the optional old password.
    static var oldPasswordKey: KeyPath<Self, String?> { get }
}
