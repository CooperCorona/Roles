import Vapor
import Fluent

public enum RoleCodableKeys: String, CodingKey {
    case id
    case role
    case ownerId
}

///Represents a role an authenticatable entity may posess.
public final class Role<TRole, TAuth>: Model where
    TAuth: Model,
    TAuth: Authenticatable,
    TRole: RoleIdentifier {

    public static var schema: String { return "Role_\(TRole.self)_\(TAuth.self)" }

    public typealias IDValue = TAuth.IDValue

    ///The unique identifier of this instance.
    @ID(key: .id)
    public var id:TAuth.IDValue?
    ///The name of this role.
    @Field(key: "role")
    public var role:TRole?

    ///The authenticatable entity owning this role.
    @Parent(key: "ownerId")
    public var owner:TAuth
    
    ///Initializes a role object from a given role identifier and owner identifier.
    public init(role:TRole, ownerId:TAuth.IDValue) {
        self.role = role
        self.$owner.id = ownerId
    }

    public init() {}
}
