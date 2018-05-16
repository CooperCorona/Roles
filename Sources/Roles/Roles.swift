import Fluent
import AuthProvider

///Represents a role an authenticatable entity may posess.
public final class Role<TRole, TAuth>: Entity where TAuth: Entity, TAuth: Authenticatable, TRole: RoleIdentifier {
    
    ///The storage for Fluent.
    public var storage: Storage = Storage()
    
    ///The name of this role.
    public var role:TRole
    ///The authenticatable entity owning this role.
    public var ownerId:Identifier? = nil
    
    ///Initializes a role object from a given role identifier and owner identifier.
    public init(role:TRole, ownerId:Identifier) {
        self.role = role
        self.ownerId = ownerId
    }
    
    ///Initializes a role object from a database row.
    public convenience init(row: Row) throws {
        self.init(role: try TRole(string: row.get("role")), ownerId: try row.get("ownerId"))
    }
    
    ///Converts this instance into a database row.
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("role", self.role.toString())
        try row.set("ownerId", self.ownerId)
        return row
    }
}

extension Role {
    
    ///The owner of this role based on the ownerId property.
    public var owner:Parent<Role<TRole, TAuth>, TAuth>? {
        get {
            return parent(id: self.ownerId)
        }
    }
    
}
