//
//  RolesGroupBuilderTests.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import XCTest
import Vapor
import Fluent
import Roles

final class RolesGroupBuilderTests: XCTestCase {
    
    let builder = RolesGroupBuilder<RoleMock>()
    
    func testInit() {
        let rolesGroup = self.builder.rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testSingleInit() {
        let rolesGroup = RolesGroup<RoleMock>(.admin)
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testIncludeOnce() {
        let rolesGroup = self.builder
            .include(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testIncludeTwiceSame() {
        let rolesGroup = self.builder
            .include(role: .admin)
            .include(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testIncludeTwiceDifferent() {
        let rolesGroup = self.builder
            .include(role: .admin)
            .include(role: .confirmed)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin, .confirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testExcludeOnce() {
        let rolesGroup = self.builder
            .exclude(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    func testExcludeTwiceSame() {
        let rolesGroup = self.builder
            .exclude(role: .admin)
            .exclude(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    func testExcludeTwiceDifferent() {
        let rolesGroup = self.builder
            .exclude(role: .admin)
            .exclude(role: .confirmed)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin, .confirmed])
    }
    
    func testIncludeExcludedRole() {
        let rolesGroup = self.builder
            .exclude(role: .admin)
            .include(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testExcludeIncludedRole() {
        let rolesGroup = self.builder
            .include(role: .admin)
            .exclude(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    func testIncludeRoles() {
        let rolesGroup = self.builder
            .include(roles: [.admin, .confirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin, .confirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testIncludeRolesOverlap() {
        let rolesGroup = self.builder
            .include(roles: [.admin, .confirmed])
            .include(roles: [.confirmed, .unconfirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin, .confirmed, .unconfirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [])
    }
    
    func testExcludeRoles() {
        let rolesGroup = self.builder
            .exclude(roles: [.admin, .confirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin, .confirmed])
    }
    
    func testExcludeRolesOverlap() {
        let rolesGroup = self.builder
            .exclude(roles: [.admin, .confirmed])
            .exclude(roles: [.confirmed, .unconfirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin, .confirmed, .unconfirmed])
    }
    
    func testIncludeExcludeRoles() {
        let rolesGroup = self.builder
            .include(roles: [.admin, .confirmed])
            .exclude(roles: [.confirmed, .unconfirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [.confirmed, .unconfirmed])
    }
    
    func testExcludeIncludeRoles() {
        let rolesGroup = self.builder
            .exclude(roles: [.admin, .confirmed])
            .include(roles: [.confirmed, .unconfirmed])
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.confirmed, .unconfirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    func testIncludeExactly() {
        let rolesGroup = self.builder
            .includeExactly(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [.confirmed, .unconfirmed])
    }
    
    func testIncludeExactlyOverwrite() {
        let rolesGroup = self.builder
            .include(role: .confirmed)
            .includeExactly(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.admin])
        XCTAssertEqual(rolesGroup.excludedRoles, [.confirmed, .unconfirmed])
    }
    
    func testExcludeExactly() {
        let rolesGroup = self.builder
            .excludeExactly(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.confirmed, .unconfirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    func testExcludeExactlyOverwrite() {
        let rolesGroup = self.builder
            .exclude(role: .confirmed)
            .excludeExactly(role: .admin)
            .rolesGroup
        XCTAssertEqual(rolesGroup.includedRoles, [.confirmed, .unconfirmed])
        XCTAssertEqual(rolesGroup.excludedRoles, [.admin])
    }
    
    
    static var allTests = [
        ("testInit", testInit),
        ("testSingleInit", testSingleInit),
        ("testIncludeOnce", testIncludeOnce),
        ("testIncludeTwiceSame", testIncludeTwiceSame),
        ("testIncludeTwiceDifferent", testIncludeTwiceDifferent),
        ("testExcludeOnce", testExcludeOnce),
        ("testExcludeTwiceSame", testExcludeTwiceSame),
        ("testExcludeTwiceDifferent", testExcludeTwiceDifferent),
        ("testIncludeExcludedRole", testIncludeExcludedRole),
        ("testExcludeIncludedRole", testExcludeIncludedRole),
        ("testIncludeRoles", testIncludeRoles),
        ("testIncludeRolesOverlap", testIncludeRolesOverlap),
        ("testExcludeRoles", testExcludeRoles),
        ("testIncludeRolesOverlap", testIncludeRolesOverlap),
        ("testIncludeExcludeRoles", testIncludeExcludeRoles),
        ("testExcludeIncludeRoles", testExcludeIncludeRoles),
        ("testIncludeExactly", testIncludeExactly),
        ("testIncludeExactlyOverwrite", testIncludeExactly),
        ("testExcludeExactly", testExcludeExactly),
        ("testExcludeExactlyOverwrite", testExcludeExactly),
    ]
}
