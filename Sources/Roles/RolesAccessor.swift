//
//  RolesAccessor.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import Authentication

///Accesses role and manages roles info in the data store
///for a given authenticatable and role entity.
open class RolesAccessor<TRole, TAuth>: RolesAccessorProtocol where TRole: RoleIdentifier, TAuth: Model, TAuth: Authenticatable {

    private let connection:DatabaseConnectable

    public init(connection:DatabaseConnectable) {
        self.connection = connection
    }
    
    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    open func entity(entity:TAuth, has role:TRole) throws -> EventLoopFuture<Bool> {
        return try entity.has(role: role, on: connection)
    }
    
    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    public func entity(entity: TAuth, has roles: RolesGroup<TRole>) throws -> EventLoopFuture<Bool> {
        return try entity.has(roles: roles, on: connection)
    }
    
    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    public func add(role: TRole, to entity: TAuth) throws -> EventLoopFuture<Role<TRole, TAuth>> {
        return try entity.add(role: role, on: connection)
    }
    
    ///Disassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    public func remove(role: TRole, from entity: TAuth) throws -> EventLoopFuture<Void> {
        return try entity.remove(role: role, on: connection)
    }
    
}
