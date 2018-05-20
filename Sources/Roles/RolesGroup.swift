//
//  RolesGroup.swift
//  Roles
//
//  Created by Cooper Knaak on 5/18/18.
//

import Foundation

///A set of valid and invalid roles. Matches authenticatable entities
///containing at least one of the includedRoles and containing none
///of the excludedRoles.
///
///To construct a RolesGroup, use a RolesGroupBuilder instance.
public struct RolesGroup<TRole> where TRole: RoleIdentifier {
    
    ///A set of roles authenticatable entities must contain one of
    ///to match this group.
    public let includedRoles:Set<TRole>
    ///A set of roles authenticatable entities must contain none of
    ///to match this group.
    public let excludedRoles:Set<TRole>
    
    ///Initializes a RolesGroup with the given included and excluded roles.
    internal init(includedRoles:Set<TRole>, excludedRoles:Set<TRole>) {
        self.includedRoles = includedRoles
        self.excludedRoles = excludedRoles
    }
    
    ///Initialies a RolesGroup with a single included role.
    public init(_ role:TRole) {
        var includedRoles = Set<TRole>()
        includedRoles.insert(role)
        self.includedRoles = includedRoles
        self.excludedRoles = Set<TRole>()
    }
    
}
