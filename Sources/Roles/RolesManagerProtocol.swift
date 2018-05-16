//
//  RolesManagerProtocol.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Fluent
import AuthProvider

///Accesses role and manages roles info
///for a given authenticatable and role entity.
public protocol RolesManagerProtocol {
    
    ///The type used to identify roles in the data store.
    associatedtype TRole: RoleIdentifier
    ///The authenticatable entity containing the roles.
    associatedtype TAuth: Entity, Authenticatable
    
    ///Returns true if the given entity has the given role.
    ///Throws an exception on Fluent errors.
    func entity(entity:TAuth, has role:TRole) throws -> Bool
    
    ///Associates a given role with an entity. Throws an exception
    ///if the role is already associated with the entity or on Fluent errors.
    func add(role:TRole, to entity:TAuth) throws -> Role<TRole, TAuth>
    
    ///Unassociates a given role from an entity. Throws an exception
    ///if the role is not already associated with the entity or on Fluent errors.
    func remove(role:TRole, from entity:TAuth) throws
    
}
