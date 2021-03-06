//
//  RolesManager.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import Vapor

///Manages authenticatable entities and associated roles.
open class RolesManager<TAccessor>: RolesManagerProtocol where TAccessor: RolesAccessorProtocol {

    public typealias TRole = TAccessor.TRole
    public typealias TAuth = TAccessor.TAuth
    
    ///The accessor for manipulating persisted storage of roles.
    private let accessor:TAccessor

    ///Initializes a RolesManager instance with the given accessor.
    public init(accessor:TAccessor) {
        self.accessor = accessor
    }

    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    open func entity(entity: TAuth, has role: TRole) -> EventLoopFuture<Bool> {
        return self.accessor.entity(entity: entity, has: role)
    }

    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    open func entity(entity: TAuth, has roles: RolesGroup<TRole>) -> EventLoopFuture<Bool> {
        return self.accessor.entity(entity: entity, has: roles)
    }

    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    open func add(role: TRole, to entity: TAuth) -> EventLoopFuture<Role<TRole, TAuth>> {
        return self.accessor.add(role: role, to: entity)
    }

    ///Disassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    open func remove(role: TRole, from entity: TAuth) -> EventLoopFuture<Void>{
        return self.accessor.remove(role: role, from: entity)
    }

}
