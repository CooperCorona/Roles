//
//  RoleMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Roles
import CoronaErrors
import Vapor

///Mocks a RoleIdentifier.
public enum RoleMock: String, RoleIdentifier, ReflectionDecodable {
    public static func reflectDecoded() throws -> (RoleMock, RoleMock) {
        return (.unconfirmed, .confirmed)
    }

    
    case unconfirmed
    case confirmed
    case admin
    
    public init(string:String) throws {
        switch string {
        case "unconfirmed":
            self = .unconfirmed
        case "confirmed":
            self = .confirmed
        case "admin":
            self = .admin
        default:
            throw ValueError.invalidArgument
        }
    }
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public static var allCases:[RoleMock] {
        return [.unconfirmed, .confirmed, .admin]
    }
    
}
