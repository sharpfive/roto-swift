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
        .package(url: "https://github.com/JohnSundell/Plot.git", .upToNextMajor(from: "0.7.0")),
        .package(url: "https://github.com/johnsundell/Publish.git", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/sharpfive/Oliva.git", .branch("dev")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.1")),
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
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "TeamRelativeValues",
            dependencies: [
                "RotoSwift", 
            ]
        ),
        .target(
            name: "HitterAuctionValues",
            dependencies: [
                "RotoSwift",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "PitcherAuctionValues",
            dependencies: [
                "RotoSwift",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),

        .target(
            name: "FreeAgentFinder",
            dependencies: ["RotoSwift"]
        ),
        .target(
            name: "Drafter",
            dependencies: [
                "RotoSwift",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "GameSimulator",
            dependencies: [
                "SimulatorLib",
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "LeagueSimulator",
            dependencies: [
                "RotoSwift", 
                "SimulatorLib",
                .product(name: "SimulationLeagueSiteGenerator", package: "Oliva"),
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "Oliva", package: "Oliva"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "AtBatSimulator",
            dependencies: [
                "RotoSwift",
                "SimulatorLib",
                .product(name: "CSV", package: "CSV.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "SimHTML",
            dependencies: [
                "RotoSwift",
                "SimulatorLib",
                .product(name: "Plot", package: "Plot"),
                .product(name: "Publish", package: "Publish"),
                .product(name: "Oliva", package: "Oliva"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),

            ]
        ),
        .target(
            name: "ProjectionsToAuctionValues",
            dependencies: [
                "RotoSwift",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "ProjectionsToAuctionValuesPitchers",
            dependencies: ["RotoSwift"]
        ),
    ]
)
