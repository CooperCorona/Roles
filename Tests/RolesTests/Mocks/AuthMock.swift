//
//  AuthMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Vapor
import Fluent
import AuthProvider

///Mocks an authenticatable entity.
class AuthMock: Entity, Authenticatable {
    
    let storage: Storage = Storage()
    
    init() {
        
    }
    
    required init(row:Row) throws {
        
    }
    
    func makeRow() throws -> Row {
        return Row()
    }
    
}

extension AuthMock: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}
