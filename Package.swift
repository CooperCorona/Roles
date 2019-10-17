// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Roles",
    products: [
        .library(
            name: "Roles",
            targets: ["Roles"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.0.0")),
      .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
      .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "3.0.0")),
      .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMajor(from: "3.0.0")),
      .package(url: "https://github.com/CooperCorona/CoronaErrors.git", .branch("Swift5"))
    ],
    targets: [
        .target(
            name: "Roles",
            dependencies: [
                "Authentication",
                "Fluent",
                "CoronaErrors"
            ]),
        .testTarget(
            name: "RolesTests",
            dependencies: [
                "Roles",
                "FluentSQLite"
            ]),
    ]
)
