//
//  StringRepresentable.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Vapor
import Fluent

///Adds type safety to roles. Roles must ultimately be represented
///as strings (or ints), but that loses Swift's type safety. Types
///can conform to RoleIdentifier to be stored in the database as
///strings be manipulated everywhere else as an actual type.
///
///Fluent throws an exception when trying to build queries from expressions
///involving RoleIdentifier types. Implementing ReflectionDecodable (which
///is implemented automatically via default implementations of the methods
///solves this).
public protocol RoleIdentifier: Hashable, Codable, CaseIterable {
    
    ///Initializes an instance of this class from a string. If
    ///the given string does not correspond to a value of this
    ///class, throws an exception.
    init(string:String) throws
    
    ///Converts the instance into its string representation.
    func toString() -> String
}
