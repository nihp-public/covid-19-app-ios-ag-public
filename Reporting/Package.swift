// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reporting",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Reporting",
            targets: ["Reporting"]
        ),
        .executable(
            name: "Reporter",
            targets: ["Reporter"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.4"),
        .package(path: "../CodeAnalyzer"),
    ],
    targets: [
        .target(
            name: "AppStoreConnector",
            dependencies: [
            ]
        ),
        .target(
            name: "Reporting",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CodeAnalyzer",
            ]
        ),
        .target(
            name: "Reporter",
            dependencies: [
                "Reporting",
            ]
        ),
        .testTarget(
            name: "ReportingTests",
            dependencies: [
                "Reporting",
            ]
        ),
        .testTarget(
            name: "AppStoreConnectorTests",
            dependencies: [
                "AppStoreConnector",
            ]
        ),
        .testTarget(
            name: "AppStoreConnectorIntegrationTests",
            dependencies: [
                "AppStoreConnector",
            ]
        ),
    ]
)
