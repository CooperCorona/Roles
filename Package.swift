// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Roles",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Roles",
            targets: ["Roles"]),
    ],
    dependencies: [
      .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.0.0")),
      .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMajor(from: "4.0.0")),
      .package(url: "https://github.com/CooperCorona/CoronaErrors.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Roles",
            dependencies: [
                "Fluent",
                "CoronaErrors"
            ]),
        .testTarget(
            name: "RolesTests",
            dependencies: [
                "Roles",
                "FluentSQLiteDriver"
            ]),
    ]
)
