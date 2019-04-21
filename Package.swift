// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RotoSwift",
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.3.1"))
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
            name: "ESPNScrape",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "LeagueRostersScrape",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "RotoAuctionValues",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "FreeAgentFinder",
            dependencies: ["RotoSwift"]
        ),

        .testTarget(
            name: "LeagueRostersScrapeTests",
            dependencies: ["LeagueRostersScrape", "RotoSwift"],
            path: "Tests"
        )
    ]
)
