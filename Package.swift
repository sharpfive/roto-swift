// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RotoSwift",
    products: [
            .library(name: "SimulatorLib", targets: ["SimulatorLib"]),
            .library(name: "RotoSwift", targets: ["RotoSwift"])
    ],
    dependencies: [
    .package(url: "https://github.com/yaslab/CSV.swift.git", .upToNextMajor(from: "2.3.1")),
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.5.0")),
    .package(url: "https://github.com/JohnSundell/Plot.git", from: "0.7.0"),
    .package(url: "https://github.com/johnsundell/publish.git", from: "0.1.0"),
    .package(url: "https://github.com/sharpfive/oliva.git", .branch("dev"))
    ],
    targets: [
        .target(
            name: "RotoSwift",
            dependencies: [
                .product(name: "CSV", package: "CSV.swift")
            ]
        ),
        .target(
            name: "SimulatorLib",
            dependencies: [
                "RotoSwift",
                .product(name: "CSV", package: "CSV.swift")
            ]
        ),
        .target(
            name: "PlayerRelativeValues",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .target(
            name: "TeamRelativeValues",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .target(
            name: "ESPNScrape",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "LeagueRostersScrape",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .target(
            name: "HitterAuctionValues",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .target(
            name: "PitcherAuctionValues",
            dependencies: [
                "RotoSwift", 
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
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
            dependencies: [
                "RotoSwift",
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "SPMUtility", package: "swift-package-manager")
            ]
        ),
        .target(
            name: "LeagueSimulator",
            dependencies: [
                "RotoSwift", 
                "SimulatorLib",
                .product(name: "SimulationLeagueSiteGenerator", package: "oliva"),
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "SPMUtility", package: "swift-package-manager"),
                .product(name: "Oliva", package: "oliva")
            ]
        ),
        .target(
            name: "AtBatSimulator",
            dependencies: [
                "RotoSwift",
                "SimulatorLib",
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "SPMUtility", package: "swift-package-manager"),
            ]
        ),
        .target(
            name: "SimHTML",
            dependencies: [
                "RotoSwift",
                "SimulatorLib",
                .product(name: "SPMUtility", package: "swift-package-manager"),
                .product(name: "Plot", package: "publish"),
                .product(name: "Publish", package: "publish"),
                .product(name: "Oliva", package: "oliva")
            ]
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
