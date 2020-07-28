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

//print("Home Team:")
//homeTeam.printToStandardOut()
//
//print("")
//
//print("Away Team:")
//awayTeam.printToStandardOut()

let homeLineups = createLineups(for: homeTeam)
let awayLineups = createLineups(for: awayTeam)


struct GameTeamResult {
    let gameResult: GameResult
    let homeTeam: SimulatorLib.Team
    let awayTeam: SimulatorLib.Team

    var title: String {
        return "\(homeTeam.name) vs \(awayTeam.name)"
    }

    var detailURLString: String {
        return "aiai"
    }

    var result: String {
        return "\(homeTeam.name) \(gameResult.homeScore) \(awayTeam.name) \(gameResult.awayScore)"
    }

    var homeTeamWon: Bool {
        return gameResult.homeScore > gameResult.awayScore
    }
}

var gameTeamResults = [GameTeamResult]()

homeLineups.forEach { homeLineup in
    awayLineups.forEach { awayLineup in
        let gameResult = simulateGame(homeLineup: homeLineup,
                                      awayLineup: awayLineup,
                                      pitcherDictionary: pitcherProjections,
                                      batterDictionary: hitterProjections)

        gameTeamResults.append(
            GameTeamResult(gameResult: gameResult,
                            homeTeam: homeTeam,
                            awayTeam: awayTeam))
    }
}

func convertToLeagueResultsViewModel(teams: [SimulatorLib.Team], gameTeamResults: [GameTeamResult]) -> LeagueResultsViewModel? {

//    gameResults.map {
//        $0.
//    }
    let gameViewModels = gameTeamResults.map { gameTeamResult in
        return GameMetaDataViewModel(
            title: gameTeamResult.title,
            detailURLString: "-",
            result: gameTeamResult.result)
    }

    let standingsViewModal = calculateTeamStandingsViewModels(from: gameTeamResults)

    return LeagueResultsViewModel(
        games: gameViewModels,
        standings: standingsViewModal)
}

func calculateTeamStandingsViewModels(from gameTeamResults: [GameTeamResult]) -> StandingsViewModel {

    // get list of all teams in the results
    // let teamsRedundantArray = gameTeamResults.compactMap {[$0.homeTeam.identifier, $0.awayTeam.identifier]}

    struct TeamResult {
        let team: SimulatorLib.Team
        let won: Bool
    }

    let teamResults: [TeamResult] = gameTeamResults.flatMap {
        return [
            TeamResult(team: $0.homeTeam, won: $0.homeTeamWon),
            TeamResult(team: $0.awayTeam, won: !$0.homeTeamWon)
        ]
    }

    let resultsDictionary = Dictionary(grouping: teamResults) { teamResult in
        return teamResult.team.identifier
    }

    let teamStandingsViewModels: [TeamStandingsViewModel] = resultsDictionary.compactMap { groupedTeamResults in
        guard let teamName = groupedTeamResults.value.first?.team.name else { return nil }

        let teamResultsForTeam = groupedTeamResults.value
        let totalGames = teamResultsForTeam.count
        let gamesWon = teamResultsForTeam.filter { teamResult -> Bool in
            teamResult.won
        }.count
        let gamesLost = totalGames - gamesWon
        let winningPercentage = Double(gamesWon) / Double(totalGames)

        return TeamStandingsViewModel(teamName: teamName,
                                      wins: "\(gamesWon)",
                                      losses: "\(gamesLost)",
                                      winPercentage: "\(winningPercentage)")
    }

    let standingsViewModel = StandingsViewModel(teamStandings: teamStandingsViewModels)
    return standingsViewModel
}


switch outputFormat {
case .text:
    printText(gameTeamResults.map { $0.gameResult})
case .json:
    let viewModel = convertToLeagueResultsViewModel(teams: lineups, gameTeamResults: gameTeamResults)

    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    let data = try jsonEncoder.encode(viewModel)

    print(String(data: data, encoding: .utf8)!)
}


///output
///
//Teams
// GameResults
//      Home Team
//      Away Team
