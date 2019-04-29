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
open class RolesAuthenticationMiddleware<TRolesManager>: Middleware where TRolesManager: RolesManagerProtocol {
    
    public typealias TRole = TRolesManager.TRole
    public typealias TAuth = TRolesManager.TAuth
    
    ///An error thrown when an entity is authenticated, but does not
    ///have the proper roles to access a certain resource.
    public struct RolesError: AbortError {
        public var identifier: String { return "RolesError" }
        public var reason: String { return "Unauthorized" }
        public var status: HTTPResponseStatus { return .unauthorized }
        public var headers: HTTPHeaders { return HTTPHeaders() }
        
    }
    
    ///Accesses roles information for authenticatable entities.
    public let rolesManager:TRolesManager
    ///The roles that should and should not be allowed to access this resource.
    public let roles:RolesGroup<TRole>
    
    ///Initializes a RolesAuthenticationMiddleware object with a given roles manager and roles group.
    public init(rolesManager:TRolesManager, roles:RolesGroup<TRole>) {
        self.rolesManager = rolesManager
        self.roles = roles
    }

    open func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let auth = try request.requireAuthenticated(TAuth.self)
        return try self.rolesManager.entity(entity: auth, has: self.roles).flatMap() {
            guard $0 else {
                throw RolesError()
            }
            return try next.respond(to: request)
        }
    }
    
}
