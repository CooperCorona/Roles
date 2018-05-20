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
        
        public var reason: String { return "Unauthorized" }
        public var status: Status { return .unauthorized }
        public var metadata: Node? { return nil }
        
    }
    
    ///Accesses roles information for authenticatable entities.
    private let rolesManager:TRolesManager
    ///The roles that should and should not be allowed to access this resource.
    private let roles:RolesGroup<TRole>
    
    ///Initializes a RolesAuthenticationMiddleware object with a given roles manager and roles group.
    public init(rolesManager:TRolesManager, roles:RolesGroup<TRole>) {
        self.rolesManager = rolesManager
        self.roles = roles
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let auth = try request.auth.assertAuthenticated(TAuth.self)
        guard try self.rolesManager.entity(entity: auth, has: self.roles) else {
            return Response(status: .unauthorized)
        }
        return try next.respond(to: request)
    }
    
}
