//
//  Authenticatable+Roles.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import AuthProvider
import CoronaErrors

extension Authenticatable where Self: Entity {
    
    ///Gets all roles associated with this entity.
    public func getRoles<TRole>() -> Children<Self, Role<TRole, Self>> {
        return children()
    }
    
    ///Returns true if a role associated with this entity
    ///in the database has the given identifier, false otherwise.
    ///Throws an exception on Fluent errors.
    public func has<TRole>(role:TRole) throws -> Bool where TRole: RoleIdentifier {
        return try children(type: Role<TRole, Self>.self).makeQuery().filter("role", role.toString()).count() > 0
    }
    
    ///Returns true if the entity is associated with *at least 1* role in
    ///roles.includedRoles and is **not** associated with *any* role in
    ///roles.excludedRoles. Throws an exception on Fluent errors.
    public func has<TRole>(roles:RolesGroup<TRole>) throws -> Bool where TRole: RoleIdentifier {
        //Fluent throws an exception when calling filter(_, in:) with an empty array, so we need
        //to handle the separate cases where there exist and don't exist elements.
        let included = roles.includedRoles.map() { $0.toString() }
        let excluded = roles.excludedRoles.map() { $0.toString() }
        guard included.count > 0 else {
            return false
        }
        guard try children(type: Role<TRole, Self>.self).makeQuery().filter("role", in: included).count() > 0 else {
            return false
        }
        if excluded.count == 0 {
            return true
        } else {
            return try children(type: Role<TRole, Self>.self).makeQuery().filter("role", in: excluded).count() == 0
        }
    }
    
    ///Adds a role to this entity. Throws an OperationException if the role is already
    ///associated with this entity. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func add<TRole>(role:TRole) throws -> Role<TRole, Self> where TRole: RoleIdentifier {
        guard let id = self.id else {
            throw NilException<Identifier>()
        }
        guard try !self.has(role: role) else {
            throw OperationException(error: .alreadyExists, message: "User with id \(id) already has role \(role).")
        }
        let role = Role<TRole, Self>(role: role, ownerId: self.id!)
        try role.save()
        return role
    }
    
    ///Removes a role from this entity. Throws an OperationException if this entity
    ///does not posess the given role. Throws a NilException<Identifier>
    ///if the `id` property is `nil`. Throws an exception on a Fluent error.
    public func remove<TRole>(role:TRole) throws where TRole: RoleIdentifier {
        guard let id = self.id else {
            throw NilException<Identifier>()
        }
        guard try self.has(role: role) else {
            throw OperationException(error: .missing, message: "User with id \(id) does not have role \(role).")
        }
        guard let roleToDelete = try Role<TRole, Self>.makeQuery().filter(Self.foreignIdKey, id).filter("role", role.toString()).first() else {
            //If the result of the query is nil, one could throw CoronaError.nil, but
            //strictly speaking the underlying reason is that the role is missing from
            //the database, so CoronaError.missing is more appropriate here.
            throw OperationException(error: .missing, message: "User with id \(id) does not have role \(role).")
        }
        try roleToDelete.delete()
    }
    
}
