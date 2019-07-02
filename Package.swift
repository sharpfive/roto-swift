// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RotoSwift",
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.3.1")),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "RotoSwift",
            dependencies: ["CSV"]
        ),
        .target(
            name: "PlayerRelativeValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .target(
            name: "TeamRelativeValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .target(
            name: "ESPNScrape",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "LeagueRostersScrape",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .target(
            name: "RotoAuctionValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .target(
            name: "FreeAgentFinder",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "ProjectionsToAuctionValues",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "ProjectionsToAuctionValuesPitchers",
            dependencies: ["RotoSwift"]
        ),
        .testTarget(
            name: "LeagueRostersScrapeTests",
            dependencies: ["LeagueRostersScrape", "RotoSwift"],
            path: "Tests"
        )
    ]
)
