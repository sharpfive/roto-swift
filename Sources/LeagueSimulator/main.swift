//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 5/23/20.
//

// ex swift run LeagueSimulator --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv
import Foundation
import RotoSwift
import CSV
import SPMUtility
import SimulatorLib
import OlivaDomain


extension SimulatorLib.Team {
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

func printInningFrame(with gameState: GameState) {
    print("frameResult: \(gameState.inningCount.frame) \(gameState.inningCount.number + 1) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
}

func printFinalScore(with gameState: GameState) {
    print("************************")
    print("")
    print("Game Over!")
    print("inningResult: \(gameState.inningCount.number + 1) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
    print("")
    print("************************")
    print("")
}

func printText(_ gameResults: [GameResult]) {

    let finalGameStates = gameResults.compactMap { $0.inningFrameResults.last?.gameState }

    for finalGameState in finalGameStates {
        printFinalScore(with: finalGameState)
    }

    let homeTeamWon = finalGameStates.filter { $0.totalHomeRunsScored > $0.totalAwayRunsScored }.count
    let awayTeamWon = finalGameStates.filter { $0.totalHomeRunsScored < $0.totalAwayRunsScored }.count


    print("Home Team Won: \(homeTeamWon) games")
    print("Away Team Won: \(awayTeamWon) games")
}

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv --linup lineups.csv]",
overview: "Converts a set of hitter statistic projections and turns them into auction values")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")

let outputFormatOption = parser.add(option: "--format", shortName: "-f", kind: String.self, usage: "Output Format text, json")

let lineupsFilenameOption = parser.add(option: "--lineups", shortName: "-l", kind: String.self, usage: "Filename for the team lineups.")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
} catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
} catch let error {
    print(error.localizedDescription)
    exit(0)
}

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "HitterAuctionValues", format: "csv")
let lineupsFileName = parsedArguments.get(lineupsFilenameOption)
let outputFormatArgument = parsedArguments.get(outputFormatOption)

enum OutputFormat: String {
    case text
    case json
}

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

guard let lineupsFilename = lineupsFileName else {
    print("Lineup filename is required")
    exit(0)
}

let outputFormat: OutputFormat
if let outputFormatArgument = outputFormatArgument {
    guard let expectedOutputFormat = OutputFormat(rawValue: outputFormatArgument) else {
        print("Unexpected outputFormat :\(outputFormatArgument)")
        exit(0)
    }
    outputFormat = expectedOutputFormat
} else {
    outputFormat = .text
}

let hitterProjections = inputHitterProjections(filename: hitterFilename)
let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)
let lineups = createLineups(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)

let totalSingles = hitterProjections.values.map { $0.singles }.reduce(0, +)
let totalDoubles = hitterProjections.values.map { $0.doubles }.reduce(0, +)
let totalTriples = hitterProjections.values.map { $0.triples}.reduce(0, +)
let totalHomeRuns = hitterProjections.values.map { $0.homeRuns}.reduce(0, +)
let totalHitByPitch = hitterProjections.values.map { $0.hitByPitch}.reduce(0, +)
let totalPlateAppearances = hitterProjections.values.map { $0.plateAppearances}.reduce(0, +)

let totalHits = totalSingles + totalDoubles + totalTriples + totalHomeRuns

let percentageOfDoubles = Double(totalDoubles) / Double(totalHits)
let percentageOfTriples = Double(totalTriples) / Double(totalHits)
let percentageOfHitByPitch = Double(totalHitByPitch) / Double(totalPlateAppearances)

let homeTeam = lineups[0]
let awayTeam = lineups[1]

print("Home Team:")
homeTeam.printToStandardOut()

print("")

print("Away Team:")
awayTeam.printToStandardOut()

let homeLineups = createLineups(for: homeTeam)
let awayLineups = createLineups(for: awayTeam)

var gameResults = [GameResult]()

homeLineups.forEach { homeLineup in
    awayLineups.forEach { awayLineup in
        let gameResult = simulateGame(homeLineup: homeLineup,
                                      awayLineup: awayLineup,
                                      pitcherDictionary: pitcherProjections,
                                      batterDictionary: hitterProjections)

        gameResults.append(gameResult)
    }
}


struct GameData {
    let homeTeam: Team
    let awayTeam: Team
    let gameResult: GameResult

    var title: String {
        return "\(homeTeam.name) vs \(awayTeam.name)"
    }

    var detailURLString: String {
        return "aiai"
    }

    var result: String {
        return "\(homeTeam.name) \(gameResult.homeScore) \(awayTeam.name) \(gameResult.awayScore)"
    }
}

func convertToLeagueResultsViewModel(teams: [Team], gameResults: [GameResult]) -> LeagueResultsViewModel? {

    gameResults.map {
        $0.
    }
    let gameViewModels = gameData.map { gameData in
        return GameMetaDataViewModel(
            title: gameData.title,
            detailURLString: "aiai",
            result: gameData.result)
    }

    let teamStandings = [
        TeamStandingsViewModel(teamName: "aiai", wins: "aiai", losses: "aiai", winPercentage: "aiai")
    ]
    let standingsViewModal = StandingsViewModel(
        teamStandings: teamStandings)

    return LeagueResultsViewModel(
        games: gameViewModels,
        standings: teamStandings)
}


switch outputFormat {
case .text:
    printText(gameResults)
case .json:
    let viewModel = convertToLeagueResultsViewModel(teams: teams, gameResults: gameResults)
    print("json!")
}


///output
///
//Teams
// GameResults
//      Home Team
//      Away Team
