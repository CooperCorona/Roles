//
//  RolesAuthenticationMiddlewareTests.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import XCTest
import Vapor
import Roles

final class RolesAuthenticationMiddlewareTests: XCTestCase {
    
    var droplet:Droplet! = nil
    var authMock:AuthMock! = nil
    var rolesManagerMock:RolesManagerMock<RoleMock, AuthMock>! = nil
    var middleware:RolesAuthenticationMiddleware<RolesManagerMock<RoleMock, AuthMock>>! = nil
    
    override func setUp() {
        super.setUp()
        self.authMock = AuthMock()
        self.rolesManagerMock = RolesManagerMock()
        self.middleware = RolesAuthenticationMiddleware(rolesManager: self.rolesManagerMock, roles: RolesGroup(.confirmed))
        
        self.droplet = try! Droplet(middleware: [self.middleware])
        self.droplet.get("*") { _ in "" }
    }
    
    func testAuthorized() {
        self.rolesManagerMock.entityHasRoles = { _, _ in true }
        do {
            let request = Request(method: .get, uri: "*")
            request.auth.authenticate(self.authMock)
            let response = try self.droplet.respond(to: request)
            XCTAssertEqual(response.status, .ok)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUnauthorized() {
        self.rolesManagerMock.entityHasRoles = { _, _ in false }
        do {
            let request = Request(method: .get, uri: "*")
            request.auth.authenticate(self.authMock)
            let response = try self.droplet.respond(to: request)
            XCTAssertEqual(response.status, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    static var allTests = [
        ("testAuthorized", testAuthorized),
        ("testUnauthorized", testUnauthorized),
    ]
}
