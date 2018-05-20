//
//  AuthenticatableRolesTests.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import XCTest
import Vapor
import Fluent
import Roles

///Tests methods on the Authenticatable+Roles extension.
final class AuthenticatableRolesTests: XCTestCase {
    
    ///Represents an in-memory driver for the database.
    var memory:MemoryDriver! = nil
    ///The database the models are stored in.
    var database:Database! = nil
    ///A mocked authenticatable entity.
    var auth:AuthMock! = nil
    
    ///Initialize test variables.
    override func setUp() {
        super.setUp()
        self.memory = try! MemoryDriver()
        self.database = Database(self.memory)
        
        try! AuthMock.prepare(self.database)
        AuthMock.database = self.database
        try! Role<RoleMock, AuthMock>.prepare(self.database)
        Role<RoleMock, AuthMock>.database = self.database
        
        self.auth = AuthMock()
        try! self.auth.save()
    }
    
    ///Test that auth has no roles associated with it in the database
    ///when no methods are called on it.
    func testInit() {
        XCTAssertFalse(try self.auth.has(role: RoleMock.unconfirmed))
        XCTAssertFalse(try self.auth.has(role: RoleMock.confirmed))
        XCTAssertFalse(try self.auth.has(role: RoleMock.admin))
    }
    
    ///Test that has(role:) returns true when a role exists in the
    ///database.
    func testHasRole() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()

        XCTAssert(try self.auth.has(role: RoleMock.admin))
    }
    
    ///Test that has(role:) returns true when a role exists in the
    ///database corresponding to the given role.
    func testHasRoleFalse() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()
        
        XCTAssertFalse(try self.auth.has(role: RoleMock.confirmed))
    }
    
    ///Test that add(role:) successfully adds a role for the user to the database.
    func testAddRole() {
        XCTAssertNoThrow(try self.auth.add(role: RoleMock.admin))
        XCTAssert(try self.auth.has(role: RoleMock.admin))
    }
    
    ///Test that add(role:) throws an exception when the given role already
    ///exists in the database.
    func testAddRoleDuplicate() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()
        
        XCTAssertThrowsError(try self.auth.add(role: RoleMock.admin))
    }
    
    ///Test that remove(role:) successfully removes a role for the user from the database.
    func testRemoveRole() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()
        
        XCTAssertNoThrow(try self.auth.remove(role: RoleMock.admin))
        XCTAssert(try !self.auth.has(role: RoleMock.admin))
    }
    
    ///Test that remove(role:) throws an error when trying to remove a role
    ///from the database that is not associated with the given user.
    func testRemoveRoleMissing() {
        XCTAssertThrowsError(try self.auth.remove(role: RoleMock.admin))
        XCTAssert(try !self.auth.has(role: RoleMock.admin))
    }
    
    ///Test that has(roles:) correctly returns true with a role group with
    ///one included role and zero excluded roles.
    func testHasRolesOneIncludedNoneExcludedTrue() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .admin)
            .rolesGroup
        do {
            let result = try self.auth.has(roles: rolesGroup)
            XCTAssert(result)
        } catch {
            XCTFail("Unexpected exception: \(error)")
        }
        
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and zero excluded roles.
    func testHasRolesOneIncludedNoneExcludedFalse() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup))
    }

    ///Test that has(roles:) correctly returns false with a role group with
    ///zero included roles and one excluded role, where the role in the database
    ///does not match the excluded role.
    func testHasRolesNoneIncludedOneExcludedMismatchFalse() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .exclude(role: .confirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup))
    }

    ///Test that has(roles:) correctly returns false with a role group with
    ///zero included roles and one excluded role, where the role in the database
    ///matches the excluded role.
    func testHasRolesNoneIncludedOneExcludedMatchFalse() {
        let role = Role<RoleMock, AuthMock>(role: .admin, ownerId: self.auth.id)
        try! role.save()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .exclude(role: .admin)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup))
    }
    
    ///Test that has(roles:) correctly returns true with a role group with
    ///one included role and one excluded role, where the role in the database
    ///matches the included role.
    func testHasRolesOneIncludedOneExcludedTrue() {
        let role = Role<RoleMock, AuthMock>(role: .confirmed, ownerId: self.auth.id)
        try! role.save()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssert(try self.auth.has(roles: rolesGroup))
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and one excluded role, where the role in the database
    ///matches the excluded role.
    func testHasRolesOneIncludedOneExcludedFalse() {
        let role = Role<RoleMock, AuthMock>(role: .unconfirmed, ownerId: self.auth.id)
        try! role.save()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup))
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and one excluded role, where there are roles in the
    ///database to match both the included and excluded role.
    func testHasRolesOneIncludedOneExcludedBoth() {
        let role = Role<RoleMock, AuthMock>(role: .confirmed, ownerId: self.auth.id)
        try! role.save()
        let role2 = Role<RoleMock, AuthMock>(role: .unconfirmed, ownerId: self.auth.id)
        try! role2.save()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup))
    }
    
    static var allTests = [
        ("testInit", testInit),
        ("testHasRole", testHasRole),
        ("testAddRole", testAddRole),
        ("testRemoveRole", testRemoveRole),
        ("testHasRolesOneIncludedNoneExcludedTrue", testHasRolesOneIncludedNoneExcludedTrue),
        ("testHasRolesOneIncludedNoneExcludedFalse", testHasRolesOneIncludedNoneExcludedFalse),
        ("testHasRolesNoneIncludedOneExcludedMismatchFalse", testHasRolesNoneIncludedOneExcludedMismatchFalse),
        ("testHasRolesNoneIncludedOneExcludedMatchFalse", testHasRolesNoneIncludedOneExcludedMatchFalse),
        ("testHasRolesOneIncludedOneExcludedTrue", testHasRolesOneIncludedOneExcludedTrue),
        ("testHasRolesOneIncludedOneExcludedFalse", testHasRolesOneIncludedOneExcludedFalse),
        ("testHasRolesOneIncludedOneExcludedBoth", testHasRolesOneIncludedOneExcludedBoth)
    ]
}
