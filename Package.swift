// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RotoSwift",
    products: [
            .library(name: "SimulatorLib", targets: ["SimulatorLib"]),
            .library(name: "RotoSwift", targets: ["RotoSwift"])
    ],
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.3.1")),
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.5.0")),
    .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.7.0"),
    .package(url: "https://github.com/johnsundell/publish.git", from: "0.1.0"),
    .package(url: "https://github.com/sharpfive/oliva.git", .branch("dev"))
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
        .executableTarget(
            name: "PlayerRelativeValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .executableTarget(
            name: "TeamRelativeValues",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .executableTarget(
            name: "ESPNScrape",
            dependencies: ["RotoSwift"]
        ),
        .executableTarget(
            name: "LeagueRostersScrape",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .executableTarget(
            name: "HitterAuctionValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),
        .executableTarget(
            name: "PitcherAuctionValues",
            dependencies: ["RotoSwift", "SPMUtility"]
        ),

        .executableTarget(
            name: "FreeAgentFinder",
            dependencies: ["RotoSwift"]
        ),
        .executableTarget(
            name: "Drafter",
            dependencies: ["RotoSwift"]
        ),
        .executableTarget(
            name: "GameSimulator",
            dependencies: ["RotoSwift", "CSV", "SPMUtility", "SimulatorLib",]
        ),
        .executableTarget(
            name: "LeagueSimulator",
            dependencies: ["RotoSwift", "CSV", "SPMUtility", "SimulatorLib", "Oliva", "SimulationLeagueSiteGenerator"]
        ),
        .executableTarget(
            name: "AtBatSimulator",
            dependencies: ["RotoSwift", "CSV", "SPMUtility", "SimulatorLib"]
        ),
        .executableTarget(
            name: "SimHTML",
            dependencies: ["RotoSwift", "SimulatorLib", "Plot", "SPMUtility", "Publish", "Oliva"]
        ),
        .executableTarget(
            name: "ProjectionsToAuctionValues",
            dependencies: ["RotoSwift"]
        ),
        .executableTarget(
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
