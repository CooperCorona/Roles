//
//  Authenticatable+Roles.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import Authentication
import CoronaErrors

extension Authenticatable where Self: Model {

    ///Gets all roles associated with this entity.
    public func getRoles<TRole>(on conn:DatabaseConnectable) throws -> EventLoopFuture<[Role<TRole, Self>]> where TRole: RoleIdentifier {
        return try children(\Role<TRole, Self>.ownerId).query(on: conn).all()
    }

    ///Returns true if a role associated with this entity
    ///in the database has the given identifier, false otherwise.
    ///Throws an exception on Fluent errors.
    public func has<TRole>(role:TRole, on conn:DatabaseConnectable) throws -> EventLoopFuture<Bool> where TRole: RoleIdentifier {
        return try children(\Role<TRole, Self>.ownerId).query(on: conn).filter(\Role<TRole, Self>.role == role).count().map() { $0 > 0 }
//        return try children(\Role<TRole, Self>.ownerId).makeQuery().filter("role", role.toString()).count() > 0
    }
    
    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    public func has<TRole>(roles:RolesGroup<TRole>, on conn:DatabaseConnectable) throws -> EventLoopFuture<Bool> where TRole: RoleIdentifier {
        //Fluent throws an exception when calling filter(_, in:) with an empty array, so we need
        //to handle the separate cases where there exist and don't exist elements.
        let included = roles.includedRoles.map() { $0 }
        let excluded = roles.excludedRoles.map() { $0 }
        guard included.count > 0 else {
            return conn.eventLoop.future(false)
        }
        //Because Authenticatable does not necessarily need to be a class, the closure can't
        //capture `[weak self]`, so `innerQuery` is declared ahead of time and that is captured instead.
        let innerQuery = try self.children(\Role<TRole, Self>.ownerId).query(on: conn)
        return try self.children(\Role<TRole, Self>.ownerId)
            .query(on: conn)
            .filter(\Role<TRole, Self>.role ~~ included)
            .count()
            .flatMap() {
                guard $0 > 0 else {
                    return conn.eventLoop.future(false)
                }
                return innerQuery
                    .filter(\Role<TRole, Self>.role ~~ excluded)
                    .count()
                    .map() {
                        return $0 == 0
                }
        }
    }
    
    ///Adds a role to this entity. Throws an OperationException if the role is already
    ///associated with this entity. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func add<TRole>(role:TRole, on conn:DatabaseConnectable) throws -> EventLoopFuture<Role<TRole, Self>> where TRole: RoleIdentifier {
        guard let id = self[keyPath: Self.idKey] else {
            throw NilException<ID>()
        }
        return try self.has(role: role, on: conn).flatMap() {
            guard !$0 else {
                throw OperationException(error: .alreadyExists, message: "User with id \(id) already has role \(role).")
            }
            let role = Role<TRole, Self>(role: role, ownerId: id)
            return role.create(on: conn)
        }/*
        guard try !self.has(role: role) else {
            throw OperationException(error: .alreadyExists, message: "User with id \(id) already has role \(role).")
        }
        let role = Role<TRole, Self>(role: role, ownerId: id)
        try role.save()
        return role*/
    }
    
    ///Removes a role from this entity. Throws an OperationException if this entity
    ///does not posess the given role. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func remove<TRole>(role:TRole, on conn:DatabaseConnectable) throws -> EventLoopFuture<Void> where TRole: RoleIdentifier {
        guard let id = self[keyPath: Self.idKey] else {
            throw NilException<ID>()
        }
        let query = try children(\Role<TRole, Self>.ownerId).query(on: conn)
        return try self.has(role: role, on: conn).flatMap() {
            guard $0 else {
                throw OperationException(error: .missing, message: "User with id \(id) does not have role \(role).")
            }
            return query.first().flatMap() {
                guard let roleToDelete = $0 else {
                    //If the result of the query is nil, one could throw CoronaError.nil, but
                    //strictly speaking the underlying reason is that the role is missing from
                    //the database, so CoronaError.missing is more appropriate here.
                    throw OperationException(error: .missing, message: "User with id \(id) does not have role \(role).")
                }
                return roleToDelete.delete(on: conn)
            }
        }/*
        guard let roleToDelete = try Role<TRole, Self>.makeQuery().filter(Self.foreignIdKey, id).filter("role", role.toString()).first() else {
            //If the result of the query is nil, one could throw CoronaError.nil, but
            //strictly speaking the underlying reason is that the role is missing from
            //the database, so CoronaError.missing is more appropriate here.
            throw OperationException(error: .missing, message: "User with id \(id) does not have role \(role).")
        }
        try roleToDelete.delete()*/
    }

}
