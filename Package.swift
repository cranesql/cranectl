// swift-tools-version:6.3
import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "cranectl",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .tvOS(.v18),
    ],
    products: [
        .executable(name: "crane", targets: ["CraneCTL"]),
        .library(name: "CraneCommands", targets: ["CraneCommands"]),
    ],
    traits: [
        .trait(name: "PostgresNIO", description: "Adds support for using the Crane Postgres NIO target."),
        .trait(name: "YAML", description: "Adds support for using YAML configuration files."),
        .default(enabledTraits: ["PostgresNIO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(
            url: "https://github.com/apple/swift-configuration.git",
            from: "1.0.0",
            traits: ["CommandLineArguments", "JSON", "YAML"]
        ),
        // Workaround for https://github.com/apple/swift-configuration/issues/89: SwiftPM fails to
        // resolve Yams via swift-configuration's `YAML` trait alone. Drop this once that's fixed.
        .package(url: "https://github.com/jpsim/Yams.git", "5.4.0"..<"7.0.0"),
        .package(url: "https://github.com/cranesql/crane.git", branch: "main", traits: ["Configuration"]),
        .package(
            url: "https://github.com/cranesql/crane-postgres-nio.git",
            branch: "main",
            traits: ["Configuration"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "CraneCTL",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "CraneCommands"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "CraneCommands",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Logging", package: "swift-log"),
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
