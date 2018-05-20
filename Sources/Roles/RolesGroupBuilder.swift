//
//  RolesGroupBuilder.swift
//  Roles
//
//  Created by Cooper Knaak on 5/18/18.
//

import Foundation

///Contains methods for setting properties of a RolesGroup.
///Contains a snapshot of the current RolesGroup, which can
///be accessed at any time.
public struct RolesGroupBuilder<TRole> where TRole: RoleIdentifier {
    
    ///The current RolesGroup to be matched.
    public let rolesGroup:RolesGroup<TRole>
    
    ///Initializes an empty roles group.
    public init() {
        self.rolesGroup = RolesGroup<TRole>(includedRoles: [], excludedRoles: [])
    }
    
    ///Initializes the builder with an underlying RolesGroup containing
    ///exactly the included and excluded roles.
    private init(includedRoles: Set<TRole>, excludedRoles: Set<TRole>) {
        self.rolesGroup = RolesGroup<TRole>(includedRoles: includedRoles, excludedRoles: excludedRoles)
    }
    
    ///Builds a roles group matching entities with **exactly** the given role.
    ///All other roles are excluded.
    public func includeExactly(role: TRole) -> RolesGroupBuilder {
        var roles = Set<TRole>(TRole.allCases)
        roles.remove(role)
        return RolesGroupBuilder(includedRoles: [role], excludedRoles: roles)
    }
    
    ///Builds a roles group matching entities with any role **except** the given role.
    ///All roles are included, except for the given role, which is excluded.
    public func excludeExactly(role: TRole) -> RolesGroupBuilder {
        var roles = Set<TRole>(TRole.allCases)
        roles.remove(role)
        return RolesGroupBuilder(includedRoles: roles, excludedRoles: [role])
    }
    
    ///Adds the given role to the included roles. Removes it from
    ///the excluded roles, if it exists.
    public func include(role: TRole) -> RolesGroupBuilder {
        var includedRoles = self.rolesGroup.includedRoles
        var excludedRoles = self.rolesGroup.excludedRoles
        includedRoles.insert(role)
        excludedRoles.remove(role)
        return RolesGroupBuilder(includedRoles: includedRoles, excludedRoles: excludedRoles)
    }
    
    ///Adds the given roles to the included roles. Removes them from
    ///the excluded roles, if they exists.
    public func include(roles: Set<TRole>) -> RolesGroupBuilder {
        var includedRoles = self.rolesGroup.includedRoles
        var excludedRoles = self.rolesGroup.excludedRoles
        for role in roles {
            includedRoles.insert(role)
        }
        for role in roles {
            excludedRoles.remove(role)
        }
        return RolesGroupBuilder(includedRoles: includedRoles, excludedRoles: excludedRoles)
    }
    
    ///Adds the given role to the excluded roles. Removes it from
    ///the included roles, if it exists.
    public func exclude(role: TRole) -> RolesGroupBuilder {
        var includedRoles = self.rolesGroup.includedRoles
        var excludedRoles = self.rolesGroup.excludedRoles
        includedRoles.remove(role)
        excludedRoles.insert(role)
        return RolesGroupBuilder(includedRoles: includedRoles, excludedRoles: excludedRoles)
    }
    
    ///Adds the given roles to the excluded roles. Removes them from
    ///the included roles, if they exists.
    public func exclude(roles: Set<TRole>) -> RolesGroupBuilder {
        var includedRoles = self.rolesGroup.includedRoles
        var excludedRoles = self.rolesGroup.excludedRoles
        for role in roles {
            includedRoles.remove(role)
        }
        for role in roles {
            excludedRoles.insert(role)
        }
        return RolesGroupBuilder(includedRoles: includedRoles, excludedRoles: excludedRoles)
    }
    
}
