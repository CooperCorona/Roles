//
//  RolesAccessor.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import AuthProvider

///Accesses role and manages roles info in the data store
///for a given authenticatable and role entity.
open class RolesAccessor<TRole, TAuth>: RolesAccessorProtocol where TRole: RoleIdentifier, TAuth: Entity, TAuth: Authenticatable {
    
    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    open func entity(entity:TAuth, has role:TRole) throws -> Bool {
        return try entity.has(role: role)
    }
    
    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    public func add(role: TRole, to entity: TAuth) throws -> Role<TRole, TAuth> {
        return try entity.add(role: role)
    }
    
    ///Disassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    public func remove(role: TRole, from entity: TAuth) throws {
        try entity.remove(role: role)
    }
    
}
