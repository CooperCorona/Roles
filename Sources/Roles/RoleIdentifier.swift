//
//  StringRepresentable.swift
//  Roles
//
//  Created by Cooper Knaak on 5/13/18.
//

import Foundation
import Vapor
import Authentication
import Fluent

///Adds type safety to roles. Roles must ultimately be represented
///as strings (or ints), but that loses Swift's type safety. Types
///can conform to RoleIdentifier to be stored in the database as
///strings be manipulated everywhere else as an actual type.
public protocol RoleIdentifier: Hashable, Codable {
    
    associatedtype AllCases: Collection where AllCases.Element == Self
    ///Returns an collection of all potential roles that an authenticatable entity can have.
    ///
    ///**NOTE**: This is implemented automatically by the compiler in Swift 4.2 for
    ///any type conforming to the CaseIterable protocol. When updating this project
    ///to Swift 4.2, this will be removed, and RoleIdentifier will require conformance
    ///to CaseIterable.
    static var allCases: AllCases { get }
    
    ///Initializes an instance of this class from a string. If
    ///the given string does not correspond to a value of this
    ///class, throws an exception.
    init(string:String) throws
    
    ///Converts the instance into its string representation.
    func toString() -> String
}
