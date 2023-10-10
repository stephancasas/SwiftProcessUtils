// swift-tools-version: 5.8

import PackageDescription;

let package = Package(
    name: "SwiftProcessUtils",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "ProcessUtils",
            targets: ["ProcessUtils"]),
    ],
    targets: [
        .target(name: "ProcessUtils", dependencies: [])
    ]
)
