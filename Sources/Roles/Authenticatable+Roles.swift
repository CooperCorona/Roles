//
//  Authenticatable+Roles.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import Vapor
import CoronaErrors

extension Authenticatable where Self: Model {

    /// Returns a query for only the roles associated with this object.
    private func rolesQuery<TRole>(on conn:Database, id:IDValue) -> QueryBuilder<Role<TRole, Self>> where TRole: RoleIdentifier {
        return Role<TRole, Self>.query(on: conn).filter(\.$owner.$id == id)
    }

    ///Gets all roles associated with this entity.
    public func getRoles<TRole>(on conn:Database) -> EventLoopFuture<[Role<TRole, Self>]> where TRole: RoleIdentifier {
        guard let id = self.id else {
            return conn.eventLoop.makeFailedFuture(NilException<IDValue>())
        }
        return self.rolesQuery(on: conn, id: id).all()
    }

    ///Returns true if a role associated with this entity
    ///in the database has the given identifier, false otherwise.
    ///Throws an exception on Fluent errors.
    public func has<TRole>(role:TRole, on conn:Database) -> EventLoopFuture<Bool> where TRole: RoleIdentifier {
        guard let id = self.id else {
            return conn.eventLoop.makeFailedFuture(NilException<IDValue>())
        }
        return self.rolesQuery(on: conn, id: id).filter(\.$role == role).count().map { $0 > 0 }
    }

    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    public func has<TRole>(roles:RolesGroup<TRole>, on conn:Database) -> EventLoopFuture<Bool> where TRole: RoleIdentifier {
        guard let id = self.id else {
            return conn.eventLoop.makeFailedFuture(NilException<IDValue>())
        }
        //Fluent throws an exception when calling filter(_, in:) with an empty array, so we need
        //to handle the separate cases where there exist and don't exist elements.
        let included = roles.includedRoles.map() { $0 }
        let excluded = roles.excludedRoles.map() { $0 }
        guard included.count > 0 else {
            return conn.eventLoop.future(false)
        }
        //Because Authenticatable does not necessarily need to be a class, the closure can't
        //capture `[weak self]`, so `innerQuery` is declared ahead of time and that is captured instead.
        let innerQuery:QueryBuilder<Role<TRole, Self>> = self.rolesQuery(on: conn, id: id)
        return self.rolesQuery(on: conn, id: id)
            .filter(\.$role ~~ included)
            .count()
            .flatMap() {
                guard $0 > 0 else {
                    return conn.eventLoop.future(false)
                }
                return innerQuery
                    .filter(\.$role ~~ excluded)
                    .count()
                    .map() {
                        return $0 == 0
                }
        }
    }

    ///Adds a role to this entity. Throws an OperationException if the role is already
    ///associated with this entity. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func add<TRole>(role:TRole, on conn:Database) -> EventLoopFuture<Role<TRole, Self>> where TRole: RoleIdentifier {
        guard let id = self.id else {
            return conn.eventLoop.makeFailedFuture(NilException<IDValue>())
        }
        return self.has(role: role, on: conn).flatMap() {
            guard !$0 else {
                return conn.eventLoop.makeFailedFuture(OperationException(error: .alreadyExists, message: "User with id \(id) already has role \(role)."))
            }
            let role = Role<TRole, Self>(role: role, ownerId: id)
            return role.create(on: conn).map { role }
        }
    }

    ///Removes a role from this entity. Throws an OperationException if this entity
    ///does not posess the given role. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func remove<TRole>(role:TRole, on conn:Database) -> EventLoopFuture<Void> where TRole: RoleIdentifier {
        guard let id = self.id else {
            return conn.eventLoop.makeFailedFuture(NilException<IDValue>())
        }
        return self.has(role: role, on: conn).flatMap() { hasRole -> EventLoopFuture<Role<TRole, Self>?> in
            guard hasRole else {
                return conn.eventLoop.makeFailedFuture(OperationException(error: .missing, message: "User with id \(id) does not have role \(role)."))
            }
            return self.rolesQuery(on: conn, id: id).filter(\.$role == role).first()
        }.flatMap {
            guard let roleToDelete = $0 else {
                //If the result of the query is nil, one could throw CoronaError.nil, but
                //strictly speaking the underlying reason is that the role is missing from
                //the database, so CoronaError.missing is more appropriate here.
                return conn.eventLoop.makeFailedFuture(OperationException(error: .missing, message: "User with id \(id) does not have role \(role)."))
            }
            return roleToDelete.delete(on: conn)
        }
    }

}
