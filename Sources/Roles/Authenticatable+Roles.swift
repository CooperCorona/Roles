//
//  Authenticatable+Roles.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import AuthProvider
//import CoronaErrors
public enum CoronaError: Error {
    case missing
    case alreadyExists
    case invalidState
}

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
    
    ///Adds a role to this entity. Throws an exception if the role is already
    ///associated with this entity or on a Fluent error.
    public func add<TRole>(role:TRole) throws -> Role<TRole, Self> where TRole: RoleIdentifier {
        guard try !self.has(role: role) else {
            throw CoronaError.alreadyExists
        }
        let role = Role<TRole, Self>(role: role, ownerId: self.id!)
        try role.save()
        return role
    }
    
    ///Removes a role from this entity. Throws an exception if this entity
    ///does not posess the given role or on a Fluent error.
    public func remove<TRole>(role:TRole) throws where TRole: RoleIdentifier {
        guard try self.has(role: role) else {
            throw CoronaError.missing
        }
        guard let id = self.id else {
            throw CoronaError.invalidState
        }
        guard let role = try Role<TRole, Self>.makeQuery().filter("ownerId", id).filter("role", role.toString()).first() else {
            //If the result of the query is nil, one could throw CoronaError.nil, but
            //strictly speaking the underlying reason is that the role is missing from
            //the database, so CoronaError.missing is more appropriate here.
            throw CoronaError.missing
        }
        try role.delete()
    }
    
}
