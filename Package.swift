// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RotoSwift",
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.3.1")),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
    .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.7.0"),
    ],
    targets: [
        .target(
            name: "RotoSwift",
            dependencies: ["CSV"]
        ),
        .target(
            name: "SimulatorLib",
            dependencies: ["CSV", "RotoSwift"]
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
            name: "HitterAuctionValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .target(
            name: "PitcherAuctionValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),

        .target(
            name: "FreeAgentFinder",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "Drafter",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "GameSimulator",
            dependencies: ["RotoSwift", "CSV", "SPMUtility", "SimulatorLib",]
        ),
        .target(
            name: "SimHTML",
            dependencies: ["RotoSwift", "SimulatorLib", "Plot"]
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
