// swift-tools-version:4.0
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
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/CooperCorona/CoronaErrors.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Roles",
            dependencies: [
                "AuthProvider",
                "FluentProvider",
                "CoronaErrors"
            ]),
        .testTarget(
            name: "RolesTests",
            dependencies: ["Roles"]),
    ]
)
