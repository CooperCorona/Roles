//
//  RolesAuthenticationMiddleware.swift
//  Roles
//
//  Created by Cooper Knaak on 5/18/18.
//

import Foundation
import Vapor
import Fluent

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

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            let auth:TAuth = try request.auth.require(TAuth.self)
            return try self.entity(entity: auth, has: self.roles, req: request).flatMap() {
                guard $0 else {
                    return request.eventLoop.future(error: Abort(.unauthorized))
                }
                return next.respond(to: request)
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }

    open func entity(entity:TAuth, has roles:RolesGroup<TRole>, req:Request) throws -> EventLoopFuture<Bool> {
        fatalError("Not implemented. Subclasses of RolesAuthenticationMiddleware must implement entity(entity:has:).")
    }
    
}
