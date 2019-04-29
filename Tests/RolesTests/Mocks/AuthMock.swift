//
//  AuthMock.swift
//  RolesTests
//
//  Created by Cooper Knaak on 5/19/18.
//

import Foundation
import Vapor
import Fluent
import Authentication
import FluentSQLite

///Mocks an authenticatable entity.
public final class AuthMock<TDatabase>: Model, Authenticatable where TDatabase: QuerySupporting {

    public typealias ID = Int
    public typealias Database = SQLiteDatabase

    public static var idKey: WritableKeyPath<AuthMock, Int?> { return \.id }

    var id:Int? = nil
    var username = "Auth"

    init() {
        
    }
}

extension AuthMock: SQLiteMigration {}
