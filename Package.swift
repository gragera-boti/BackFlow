// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BackFlow",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BackFlow",
            targets: ["BackFlow"]
        )
    ],
    targets: [
        .target(
            name: "BackFlow",
            path: "BackFlow",
            resources: [
                .copy("../SeedData")
            ]
        )
    ]
)
