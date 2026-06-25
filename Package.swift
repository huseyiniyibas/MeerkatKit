// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeerkatKit",
    platforms: [
        .iOS(.v15)
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
