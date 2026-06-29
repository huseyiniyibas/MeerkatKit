// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MeerkatKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
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
