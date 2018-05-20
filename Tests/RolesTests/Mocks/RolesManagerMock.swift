//
//  RolesManagerMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Fluent
import AuthProvider
import Roles
import CoronaErrors

///Mocks a RoleManagerProtocol. Set the properties to change the functionality of the methods.
class RolesManagerMock<TRole, TAuth>: RolesManagerProtocol where TRole: RoleIdentifier, TAuth: Entity, TAuth: Authenticatable {
    
    var entityHasRole:(TAuth, TRole) throws -> Bool = { _, _ in false }
    var entityHasRoles:(TAuth, RolesGroup<TRole>) throws -> Bool = { _, _ in false }
    var addRoleToEntity:(TRole, TAuth) throws -> Role<TRole, TAuth> = { _, _ in throw CoronaError.invalidArgument }
    var removeRoleFromEntity:(TRole, TAuth) throws -> Void = { _, _ in }
    
    func entity(entity: TAuth, has role: TRole) throws -> Bool {
        return try self.entityHasRole(entity, role)
    }
    
    func entity(entity: TAuth, has roles: RolesGroup<TRole>) throws -> Bool {
        return try self.entityHasRoles(entity, roles)
    }
    
    func add(role: TRole, to entity: TAuth) throws -> Role<TRole, TAuth> {
        return try self.addRoleToEntity(role, entity)
    }
    
    func remove(role: TRole, from entity: TAuth) throws {
        try self.removeRoleFromEntity(role, entity)
    }
    
    
}
