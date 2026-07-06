// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MeerkatKit",
    platforms: [
        .iOS("17.5"),
        .macOS("14.5"),
        .tvOS("17.5"),
        .visionOS("1.5")
    ],
    products: [
        .library(
            name: "MeerkatKit",
            targets: ["MeerkatKit"]
        )
    ],
    targets: [
        .target(
            name: "MeerkatKit",
            path: "Sources/MeerkatKit"
        ),
        .testTarget(
            name: "MeerkatKitTests",
            dependencies: ["MeerkatKit"],
            path: "Tests/MeerkatKitTests"
        )
    ]
)
