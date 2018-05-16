//
//  RolesManager.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import AuthProvider

///Manages authenticatable entities and associated roles.
open class RolesManager<TRole, TAuth, TAccessor>: RolesManagerProtocol where TAccessor: RolesAccessorProtocol, TAccessor.TRole == TRole, TAccessor.TAuth == TAuth {
    
    ///The accessor for manipulating persisted storage of roles.
    private let accessor:TAccessor
    
    ///Initializes a RolesManager instance with the given accessor.
    public init(accessor:TAccessor) {
        self.accessor = accessor
    }
    
    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    public func entity(entity: TAuth, has role: TRole) throws -> Bool {
        return try self.accessor.entity(entity: entity, has: role)
    }
    
    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    public func add(role: TRole, to entity: TAuth) throws -> Role<TRole, TAuth> {
        return try self.add(role: role, to: entity)
    }
    
    ///Disassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    public func remove(role: TRole, from entity: TAuth) throws {
        try self.remove(role: role, from: entity)
    }
    
}
