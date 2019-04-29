import Fluent
import Authentication

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
    public static var idKey: WritableKeyPath<Role<TRole, TAuth>, ID?> { return \.id }

    public typealias TDatabase = TAuth.Database
    public typealias Database = TDatabase
    public typealias ID = TAuth.ID

    ///The unique identifier of this instance.
    public var id:TAuth.ID? = nil
    ///The name of this role.
    public var role:TRole
    ///The authenticatable entity owning this role.
    public var ownerId:TAuth.ID? = nil
    
    ///Initializes a role object from a given role identifier and owner identifier.
    public init(role:TRole, ownerId:TAuth.ID?) {
        self.role = role
        self.ownerId = ownerId
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RoleCodableKeys.self)
        let id:ID? = try? container.decode(ID.self, forKey: .id)
        let role:TRole = try container.decode(TRole.self, forKey: .role)
        let ownerId:TAuth.ID? = try? container.decode(TAuth.ID.self, forKey: .ownerId)
        self.init(role: role, ownerId: ownerId)
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RoleCodableKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(ownerId, forKey: .ownerId)
    }
    
    ///Initializes a role object from a database row.
    /*public convenience init(row: Row) throws {
        self.init(role: try TRole(string: row.get("role")), ownerId: try row.get(TAuth.foreignIdKey))
    }
    
    ///Converts this instance into a database row.
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("role", self.role.toString())
        try row.set(TAuth.foreignIdKey, self.ownerId)
        return row
    }*/
}
/*
extension Role {
    
    ///The owner of this role based on the ownerId property.
    public var owner:Parent<Role<TRole, TAuth, TDatabase>, TAuth>? {
        get {
            return parent(id: self.ownerId)
        }
    }
    
}

extension Role: Migration{//} where TDatabase: MigrationSupporting {
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("role")
            builder.parent(TAuth.self)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
*/
