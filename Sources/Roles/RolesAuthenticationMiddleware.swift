//
//  RolesAuthenticationMiddleware.swift
//  Roles
//
//  Created by Cooper Knaak on 5/18/18.
//

import Foundation
import Vapor
import Authentication
import HTTP

///Middleware that authorizes authenticatable entities of a certain role(s).
///If the entity's roles do not match the given roles group, then a 404 error
///is thrown.
///
///NOTE: Until Vapor supports Swift 5.1 with opaque types, there's no way to use Services to create
///a RolesManagerProtocol instance because it has associated types. Clients are required to subclass
///RolesAuthenticationMiddleware and implement the `entity(entity:has:)` method, create a concrete
///instance of RolesManagerProtocol, and calling `entity(entity:has:)` on it. This restriction will
///be lifted once opaque types are supported.
open class RolesAuthenticationMiddleware<TRole, TAuth>: Middleware where TRole: RoleIdentifier, TAuth: Authenticatable & Model {

    ///The roles that should and should not be allowed to access this resource.
    public let roles:RolesGroup<TRole>
    
    ///Initializes a RolesAuthenticationMiddleware object with a given roles manager and roles group.
    public init(roles:RolesGroup<TRole>) {
        self.roles = roles
    }

    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let auth:TAuth = try request.requireAuthenticated(TAuth.self)
        return try self.entity(entity: auth, has: self.roles).flatMap() {
            guard $0 else {
                throw Abort(.unauthorized)
            }
            return try next.respond(to: request)
        }
    }

    open func entity(entity:TAuth, has:RolesGroup<TRole>) throws -> EventLoopFuture<Bool> {
        fatalError("Not implemented. Subclasses of RolesAuthenticationMiddleware must implement entity(entity:has:).")
    }
    
}
