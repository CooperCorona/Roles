//
//  AuthenticatableRolesTests.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import XCTest
import Vapor
import FluentSQLite
import Roles

///Syntactic sugar for AuthMock with a concrete SQLiteDatabase.
public typealias Auth = AuthMock<SQLiteDatabase>
///Syntactic sugar for Roles.Role with RoleMock and Auth.
public typealias Role = Roles.Role<RoleMock, Auth>

extension Roles.Role: Equatable where TRole == RoleMock, TAuth == Auth {}
public func ==(lhs:Role, rhs:Role) -> Bool {
    return lhs.id == rhs.id && lhs.role == rhs.role && lhs.ownerId == rhs.ownerId
}

///Represents a SQLite migration to create or delete a Roles<RoleMock, AuthMock<SQLiteDatabase>> table.
struct CreateRoleSQLite: SQLiteMigration {
    static func prepare(on conn: SQLiteConnection) -> EventLoopFuture<Void> {
        return SQLiteDatabase.create(Role.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.role)
            builder.field(for: \.ownerId)
        }
    }

    static func revert(on conn: SQLiteConnection) -> EventLoopFuture<Void> {
        return SQLiteDatabase.delete(Role.self, on: conn)
    }

}

///Tests methods on the Authenticatable+Roles extension.
final class AuthenticatableRolesTests: XCTestCase {

    ///The database the models are stored in.
    var database:SQLiteDatabase! = nil
    ///The connection to the database with which to run queries.
    var connection:SQLiteConnection! = nil
    ///A mocked authenticatable entity.
    var auth:Auth! = nil
    ///The worker to run the database commands on.
    let worker = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    
    ///Initialize test variables.
    override func setUp() {
        super.setUp()

        self.database = try! SQLiteDatabase()
        self.connection = try! self.database.newConnection(on: worker).wait()
        try! Auth.prepare(on: self.connection).wait()
        try! CreateRoleSQLite.prepare(on: self.connection).wait()
        self.auth = Auth()
        let _ = try! self.auth.save(on: self.connection).wait()
    }
    
    ///Test that auth has no roles associated with it in the database
    ///when no methods are called on it.
    func testInit() {
        XCTAssertFalse(try self.auth.has(role: RoleMock.unconfirmed, on: self.connection).wait())
        XCTAssertFalse(try self.auth.has(role: RoleMock.confirmed, on: self.connection).wait())
        XCTAssertFalse(try self.auth.has(role: RoleMock.admin, on: self.connection).wait())
    }

    ///Tests that getRoles returns an empty array when auth has no roles
    ///associated with it in the database.
    func testGetRolesEmpty() {
        let expected:[Role] = []
        let roles:[Role] = try! self.auth.getRoles(on: self.connection).wait()
        XCTAssertEqual(expected, roles)
    }

    ///Tests that getRoles returns an array with one element when auth
    ///has one roles associated with it in the database.
    func testGetRolesOne() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        let expected = [role]

        let roles:[Role] = try! self.auth.getRoles(on: self.connection).wait()
        XCTAssertEqual(expected, roles)
    }

    ///Tests that getRoles returns an array with multiple elements when auth
    ///has many roles associated with it in the database.
    func testGetRolesMany() {
        let role = Role(role: .confirmed, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        let role2 = Role(role: .unconfirmed, ownerId: self.auth.id)
        let _ = try! role2.save(on: self.connection).wait()
        let expected = [role, role2]

        let roles:[Role] = try! self.auth.getRoles(on: self.connection).wait()
        XCTAssert((expected[0] == roles[0] && expected[1] == roles[1])
               || (expected[0] == roles[1] && expected[1] == roles[0]))
    }

    ///Test that has(role:) returns true when a role exists in the
    ///database.
    func testHasRole() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()

        XCTAssert(try self.auth.has(role: RoleMock.admin, on: self.connection).wait())
    }
    
    ///Test that has(role:) returns true when a role exists in the
    ///database corresponding to the given role.
    func testHasRoleFalse() {
        let role = Role(role: .admin, ownerId: nil)
        let _ = try! role.save(on: self.connection).wait()
        
        XCTAssertFalse(try self.auth.has(role: RoleMock.confirmed, on: self.connection).wait())
    }
    
    ///Test that add(role:) successfully adds a role for the user to the database.
    func testAddRole() {
        XCTAssertNoThrow(try self.auth.add(role: RoleMock.admin, on: self.connection).wait())
        XCTAssert(try self.auth.has(role: RoleMock.admin, on: self.connection).wait())
    }
    
    ///Test that add(role:) throws an exception when the given role already
    ///exists in the database.
    func testAddRoleDuplicate() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        
        XCTAssertThrowsError(try self.auth.add(role: RoleMock.admin, on: self.connection).wait())
    }
    
    ///Test that remove(role:) successfully removes a role for the user from the database.
    func testRemoveRole() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        
        XCTAssertNoThrow(try self.auth.remove(role: RoleMock.admin, on: self.connection).wait())
        XCTAssert(try !self.auth.has(role: RoleMock.admin, on: self.connection).wait())
    }
    
    ///Test that remove(role:) throws an error when trying to remove a role
    ///from the database that is not associated with the given user.
    func testRemoveRoleMissing() {
        XCTAssertThrowsError(try self.auth.remove(role: RoleMock.admin, on: self.connection).wait())
        XCTAssert(try !self.auth.has(role: RoleMock.admin, on: self.connection).wait())
    }

    ///Test that has(roles:) correctly returns true with a role group with
    ///one included role and zero excluded roles.
    func testHasRolesOneIncludedNoneExcludedTrue() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .admin)
            .rolesGroup
        do {
            let result = try self.auth.has(roles: rolesGroup, on: self.connection).wait()
            XCTAssert(result)
        } catch {
            XCTFail("Unexpected exception: \(error)")
        }
        
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and zero excluded roles.
    func testHasRolesOneIncludedNoneExcludedFalse() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
    }

    ///Test that has(roles:) correctly returns false with a role group with
    ///zero included roles and one excluded role, where the role in the database
    ///does not match the excluded role.
    func testHasRolesNoneIncludedOneExcludedMismatchFalse() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .exclude(role: .confirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
    }

    ///Test that has(roles:) correctly returns false with a role group with
    ///zero included roles and one excluded role, where the role in the database
    ///matches the excluded role.
    func testHasRolesNoneIncludedOneExcludedMatchFalse() {
        let role = Role(role: .admin, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()

        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .exclude(role: .admin)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
    }
    
    ///Test that has(roles:) correctly returns true with a role group with
    ///one included role and one excluded role, where the role in the database
    ///matches the included role.
    func testHasRolesOneIncludedOneExcludedTrue() {
        let role = Role(role: .confirmed, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssert(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and one excluded role, where the role in the database
    ///matches the excluded role.
    func testHasRolesOneIncludedOneExcludedFalse() {
        let role = Role(role: .unconfirmed, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
    }
    
    ///Test that has(roles:) correctly returns false with a role group with
    ///one included role and one excluded role, where there are roles in the
    ///database to match both the included and excluded role.
    func testHasRolesOneIncludedOneExcludedBoth() {
        let role = Role(role: .confirmed, ownerId: self.auth.id)
        let _ = try! role.save(on: self.connection).wait()
        let role2 = Role(role: .unconfirmed, ownerId: self.auth.id)
        let _ = try! role2.save(on: self.connection).wait()
        
        let rolesGroup = RolesGroupBuilder<RoleMock>()
            .include(role: .confirmed)
            .exclude(role: .unconfirmed)
            .rolesGroup
        XCTAssertFalse(try self.auth.has(roles: rolesGroup, on: self.connection).wait())
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
