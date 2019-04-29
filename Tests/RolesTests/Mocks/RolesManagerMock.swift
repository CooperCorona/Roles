//
//  RolesManagerMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Fluent
import Authentication
import Roles
import CoronaErrors

///Mocks a RoleManagerProtocol. Set the properties to change the functionality of the methods.
class RolesManagerMock<TRole, TAuth>: RolesManagerProtocol where TRole: RoleIdentifier, TAuth: Model, TAuth: Authenticatable {

    private let eventLoop:EventLoop

    var entityHasRole:(TAuth, TRole) throws -> Bool = { _, _ in false }
    var entityHasRoles:(TAuth, RolesGroup<TRole>) throws -> Bool = { _, _ in false }
    var addRoleToEntity:(TRole, TAuth) throws -> Roles.Role<TRole, TAuth> = { _, _ in throw ValueError.invalidArgument }
    var removeRoleFromEntity:(TRole, TAuth) throws -> Void = { _, _ in }

    init(eventLoop:EventLoop) {
        self.eventLoop = eventLoop
    }

    func entity(entity: TAuth, has role: TRole) throws -> EventLoopFuture<Bool> {
        return try self.eventLoop.future(self.entityHasRole(entity, role))
    }
    
    func entity(entity: TAuth, has roles: RolesGroup<TRole>) throws -> EventLoopFuture<Bool> {
        return try self.eventLoop.future(self.entityHasRoles(entity, roles))
    }
    
    func add(role: TRole, to entity: TAuth) throws -> EventLoopFuture<Roles.Role<TRole, TAuth>> {
        return try self.eventLoop.future(self.addRoleToEntity(role, entity))
    }
    
    func remove(role: TRole, from entity: TAuth) throws -> EventLoopFuture<Void> {
        return try self.eventLoop.future(self.removeRoleFromEntity(role, entity))
    }
    
    
}
