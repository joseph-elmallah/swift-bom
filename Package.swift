// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BOM",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BOM",
            targets: ["BOM"]),
    ],
    targets: [
        .target(
            name: "BOM",
            dependencies: []),
        .testTarget(
            name: "BOMTests",
            dependencies: ["BOM"],
            resources: [.copy("TestData")]),
    ]
)
