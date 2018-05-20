//
//  RoleMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Roles
import CoronaErrors

///Mocks a RoleIdentifier.
enum RoleMock: String, RoleIdentifier {
    
    case unconfirmed
    case confirmed
    case admin
    
    init(string:String) throws {
        switch string {
        case "unconfirmed":
            self = .unconfirmed
        case "confirmed":
            self = .confirmed
        case "admin":
            self = .admin
        default:
            throw CoronaError.invalidArgument
        }
    }
    
    func toString() -> String {
        return self.rawValue
    }
    
    static var allCases:[RoleMock] {
        return [.unconfirmed, .confirmed, .admin]
    }
    
}
