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
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
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
                .product(name: "ArgumentParser", package: "swift-argument-parser")
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
