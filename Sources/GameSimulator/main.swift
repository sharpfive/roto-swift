//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 3/23/20.
//

// ex swift run GameSimulator ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv ~/Dropbox/roto/cash/2020/2020-04-05-Auction-final.csv

import ArgumentParser
import Foundation

import CSV
import SimulatorLib


struct GameSimulator: ParsableCommand {
    @Argument(help: "CSV file of hitter projections")
    var hitterProjectionsFilename: String

    @Argument(help: "CSV file of pitcher projections")
    var pitcherProjectionsFilename: String

    @Argument(help: "json file with Lineups data")
    var lineupsFilename: String

    mutating func run() throws {
        runMain(hitterFilename: hitterProjectionsFilename,
                pitcherFilename: pitcherProjectionsFilename,
                lineupsFilename: lineupsFilename)
    }
}

GameSimulator.main()

extension SimulatorLib.TeamProjections {
    func printToStandardOut() {
        print("Team: \(name)")
        print("   id: \(identifier)")
        print("   Pitchers")
        pitchers.forEach {
            print("      \($0)")
        }
        print("   Batters")
        batters.forEach {
            print("      \($0)")
        }
    }
}

func runMain(hitterFilename: String,
             pitcherFilename: String,
             lineupsFilename: String) {
    let hitterProjections = inputHitterProjections(filename: hitterFilename)
    let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)
    let lineups = createTeams(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)

    let totalSingles = hitterProjections.values.map { $0.singles }.reduce(0, +)
    let totalDoubles = hitterProjections.values.map { $0.doubles }.reduce(0, +)
    let totalTriples = hitterProjections.values.map { $0.triples}.reduce(0, +)
    let totalHomeRuns = hitterProjections.values.map { $0.homeRuns}.reduce(0, +)
    let totalHitByPitch = hitterProjections.values.map { $0.hitByPitch}.reduce(0, +)
    let totalPlateAppearances = hitterProjections.values.map { $0.plateAppearances}.reduce(0, +)

    let totalHits = totalSingles + totalDoubles + totalTriples + totalHomeRuns

    func printInningFrame(with gameState: GameState) {
        print("frameResult: \(gameState.inningCount.frame) \(gameState.inningCount.displayNumber) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
    }

    func printFinalScore(with gameState: GameState) {
        print("************************")
        print("")
        print("Game Over!")
        print("inningResult: \(gameState.inningCount.displayNumber) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
        print("")
        print("************************")
        print("")
    }

    let homeTeam = lineups[0]
    let awayTeam = lineups[1]


    print("Home Team:")
    homeTeam.printToStandardOut()

    print("")

    print("Away Team:")
    awayTeam.printToStandardOut()

    let homeLineups = createLineups(for: homeTeam)
    let awayLineups = createLineups(for: awayTeam)

    let gameState = simulateGame(
        homeLineup: homeLineups.first!,
        awayLineup: awayLineups.first!,
        pitcherDictionary: pitcherProjections,
        batterDictionary: hitterProjections
    )

    gameState.inningFrameResults.forEach { inningFrameResult in
        let gameState = inningFrameResult.gameState
        if gameState.isEndOfGame() {
            printFinalScore(with: gameState)
        } else {
            printInningFrame(with: gameState)
        }
    }
}
