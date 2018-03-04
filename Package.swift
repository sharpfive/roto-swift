// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RotoSwift",
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "RotoSwift",
            dependencies: ["CSV"]
        ),
        .target(
            name: "PlayerRelativeValues",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "TeamRelativeValues",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "LeagueScrape",
            dependencies: ["RotoSwift"]
        )
    ]
)
