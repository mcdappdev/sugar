import Authentication
import Crypto
import Fluent
import Vapor

public protocol UserType {
    associatedtype Login: HasReadablePassword
    associatedtype Registration: HasReadablePassword
    associatedtype Update: Decodable
    associatedtype Public: Content

    init(_: Registration) throws
    func update(with: Update) throws

    static func logIn(with: Login, on worker: DatabaseConnectable) -> Future<Self>
    static func preRegister(with: Registration, on worker: DatabaseConnectable) throws -> Future<Void>
    func preUpdate(with: Update, on worker: DatabaseConnectable) throws -> Future<Void>
}

public protocol HasReadableUser {
    /// The username, sometimes an email address
    var username: String { get }
}

public protocol HasUpdatablePassword {
    var password: String? { get }
    var oldPassword: String? { get }
}

public protocol HasUpdatableUsername {
    var username: String? { get }
}

extension UserType where
    Self: Model,
    Self: PasswordAuthenticatable,
    Self.Database: QuerySupporting,
    Self.Login: HasReadableUser,
    Self.Registration: HasReadableUser
{
    public static func logIn(with login: Login, on worker: DatabaseConnectable) -> Future<Self> {
        return Self
            .authenticate(
                username: login.username,
                password: login.password,
                using: BCrypt,
                on: worker
            )
            .unwrap(or: AuthenticationError.userNotFound)
    }
}

extension UserType where
    Self: Model,
    Self: PasswordAuthenticatable,
    Self.Database: QuerySupporting,
    Self.Registration: HasReadableUser
{
    public static func preRegister(with registration: Registration, on worker: DatabaseConnectable) throws -> Future<Void> {
        return try Self.query(on: worker)
            .filter(Self.usernameKey == registration.username)
            .first()
            .nil(or: AuthenticationError.usernameAlreadyExists)
    }
}

extension UserType where
    Self: Model,
    Self: PasswordAuthenticatable,
    Self.Database: QuerySupporting,
    Self.Update: HasUpdatableUsername,
    Self.Update: HasUpdatablePassword,
    Self: HasPassword
{
    public func preUpdate(with update: Update, on worker: DatabaseConnectable) throws -> Future<Void> {
        if update.password != nil && (update.username == nil && update.oldPassword == nil) {
            throw Abort(.internalServerError)
        }

        if let oldPassword = update.oldPassword {
            guard try verify(oldPassword) else {
                throw AuthenticationError.incorrectOldPassword
            }
        }

        if let username = update.username {
            guard let password = update.password, try verify(password) else {
                throw AuthenticationError.incorrectPassword
            }

            return try Self.query(on: worker)
                .filter(Self.usernameKey == username)
                .first()
                .try { user in
                    guard
                        user == nil || user?[keyPath: Self.idKey] == self[keyPath: Self.idKey]
                    else {
                        throw AuthenticationError.usernameAlreadyExists
                    }
                }
                .value(())
        }

        return Future.value((), on: worker)
    }
}

extension UserType where
    Self: Model,
    Self: PasswordAuthenticatable,
    Self.Database: QuerySupporting
{
    public static func logIn(on req: Request) throws -> Future<Self> {
        return try req
            .content
            .decode(Login.self)
            .flatMap(to: Self.self) { login in
                Self.logIn(with: login, on: req)
            }
    }

    public static func register(on req: Request) throws -> Future<Self> {
        return try req.content
            .decode(Registration.self)
            .flatTry { registration in
                try Self.preRegister(with: registration, on: req)
            }
            .flatMap(to: Self.self) { registration in
                return try Self(registration).save(on: req)
            }
    }

    public static func update(on req: Request) throws -> Future<Self> {
        let user = try req.requireAuthenticated(Self.self)

        return flatMap(
            to: Self.self,
            try req.content.decode(Self.Update.self),
            Future.value(user, on: req))
        { update, user in
            return try user.preUpdate(with: update, on: req)
                .flatMap { _ in
                    try user.update(with: update)
                    return user.save(on: req)
                }
        }
    }
}
