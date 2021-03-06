//
//  RolesAccessor.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import Vapor
import CoronaErrors

///Accesses role and manages roles info in the data store
///for a given authenticatable and role entity.
open class RolesAccessor<TRole, TAuth>: RolesAccessorProtocol where
    TRole: RoleIdentifier,
    TAuth: Model & Authenticatable {

    private let connectionPool:Database

    public init(connectionPool:Database) {
        self.connectionPool = connectionPool
    }

    private func tryOrError<T>(_ closure:@escaping (Database) throws -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        return self.connectionPool.withConnection { (connection:Database) -> EventLoopFuture<T> in
            do {
                return try closure(connection)
            } catch {
                return connection.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    open func entity(entity:TAuth, has role:TRole) -> EventLoopFuture<Bool> {
        return self.connectionPool.withConnection { entity.has(role: role, on: $0) }
    }
    
    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    public func entity(entity: TAuth, has roles: RolesGroup<TRole>) -> EventLoopFuture<Bool> {
        return self.connectionPool.withConnection { entity.has(roles: roles, on: $0) }
    }
    
    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    public func add(role: TRole, to entity: TAuth) -> EventLoopFuture<Role<TRole, TAuth>> {
        return self.connectionPool.withConnection { entity.add(role: role, on: $0) }
    }
    
    ///Disassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    public func remove(role: TRole, from entity: TAuth) -> EventLoopFuture<Void> {
        return self.connectionPool.withConnection { entity.remove(role: role, on: $0) }
    }
    
}
