// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MoPilot",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MoPilot", targets: ["MoPilot"])
    ],
    targets: [
        .executableTarget(
            name: "MoPilot",
            path: "Sources/MoPilot",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
