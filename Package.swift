// swift-tools-version:6.3
import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "cranectl",
    products: [
        .executable(name: "crane", targets: ["CraneCTL"]),
        .library(name: "CraneCommands", targets: ["CraneCommands"]),
    ],
    traits: [
        .trait(name: "PostgresNIO", description: "Adds support for using the Crane Postgres NIO target."),
        .default(enabledTraits: ["PostgresNIO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/cranesql/crane.git", branch: "main"),
        .package(url: "https://github.com/cranesql/crane-postgres-nio.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "CraneCTL",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "CraneCommands"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "CraneCommands",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Crane", package: "crane"),
                .product(
                    name: "CranePostgresNIO",
                    package: "crane-postgres-nio",
                    condition: .when(traits: ["PostgresNIO"])
                ),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "CraneCommandsTests",
            dependencies: [
                .target(name: "CraneCommands")
            ],
            swiftSettings: sharedSwiftSettings
        ),
    ]
)
