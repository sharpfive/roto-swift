//
//  main.swift
//  
//
//  Created by Jaim Zuber on 4/5/20.
//

import Foundation
import Plot
import SPMUtility
import SimulatorLib
import Publish

// ex swift run SimHTML --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --linup lineups.csv]",
overview: "Converts a lineup into html")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")

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

let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let lineupsFileName = parsedArguments.get(lineupsFilenameOption)


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

let hitterProjections = inputHitterProjections(filename: hitterFilename)
let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)
let teams = createLineups(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)



let leagueName = "CIK"

struct LineScoreViewModel: Codable, Hashable {
    struct InningResult: Codable, Hashable {
        let inningNumber: String
        let awayTeamRunsScored: String
        let homeTeamRunsScored: String
        let isFinalInning: Bool
    }

    let awayTeam: String
    let homeTeam: String

    let inningScores: [InningResult]
    let awayTeamHits: String
    let homeTeamHits: String

    let awayTeamErrors: String = "0"
    let homeTeamErrors: String = "0"

    let awayTeamFinalScore: String
    let homeTeamFinalScore: String
}

struct GameMetaDataViewModel: Codable, Hashable {
    let title: String
    let detailURLString: String
}

struct LeagueResultsViewModel: Codable, Hashable {
    let games: [GameMetaDataViewModel]
}

struct GameViewModel: Codable, Hashable {
    let gameId: String
    let title: String
    let lineScore: LineScoreViewModel
}

let inningScores = [
    LineScoreViewModel.InningResult(inningNumber: "1", awayTeamRunsScored: "1", homeTeamRunsScored: "0", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "2", awayTeamRunsScored: "0", homeTeamRunsScored: "0", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "3", awayTeamRunsScored: "0", homeTeamRunsScored: "0", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "4", awayTeamRunsScored: "0", homeTeamRunsScored: "3", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "5", awayTeamRunsScored: "0", homeTeamRunsScored: "0", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "6", awayTeamRunsScored: "0", homeTeamRunsScored: "0", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "7", awayTeamRunsScored: "0", homeTeamRunsScored: "2", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "8", awayTeamRunsScored: "0", homeTeamRunsScored: "1", isFinalInning: false),
    LineScoreViewModel.InningResult(inningNumber: "9", awayTeamRunsScored: "2", homeTeamRunsScored: "-", isFinalInning: true),
]

let lineScoreViewModel = LineScoreViewModel(awayTeam: "Toronto Blue Jays",
                                   homeTeam: "Minnesota Twins",
                                   inningScores: inningScores,
                                   awayTeamHits: "7",
                                   homeTeamHits: "11",
                                   awayTeamFinalScore: "3",
                                   homeTeamFinalScore: "6")

let gameViewModel = GameViewModel(gameId: "0", title: "Toronto Blue Jays at Minnesota Twins, April 13 2020", lineScore: lineScoreViewModel)

func createGame(with gameId: String) -> GameViewModel {
    return GameViewModel(gameId: gameId, title: "Toronto Blue Jays at Minnesota Twins, April 13 2020", lineScore: lineScoreViewModel)
}

let games = [
    createGame(with: "0"),
    createGame(with: "1"),
    createGame(with: "2"),
    createGame(with: "3"),
    createGame(with: "4"),
    createGame(with: "5"),
]


struct SimulationLeague: Website {
    enum SectionID: String, WebsiteSectionID {
        case rosters
        case game
        case leagueResults
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        let leagueName: String
        let teams: [Team]
        let game: GameViewModel?
        let leagueResults: LeagueResultsViewModel?

        init(leagueName: String,
             teams: [Team],
             game: GameViewModel? = nil,
             leagueResults: LeagueResultsViewModel? = nil) {
            self.leagueName = leagueName
            self.teams = teams
            self.game = game
            self.leagueResults = leagueResults
        }
    }

    var url = URL(string: "https://cooking-with-john.com")!
    var name = "The League"
    var description = "Baseball Simulation"
    var language: Language { .english }
    var imagePath: Path? { "images/logo.png" }
}

extension Theme where Site == SimulationLeague {
    static var league: Self {
        Theme(htmlFactory: SimulationLeagueHTMLFactory())
    }
}

let metadatas = games.map { game in
    return SimulationLeague.ItemMetadata(leagueName: leagueName, teams: teams, game: game)
}

let gameItems = metadatas.map{ metadata in
    return Item<SimulationLeague>(path: "\(metadata.game!.gameId)", sectionID: .game, metadata: metadata)
}

let gameMetaDatas: [GameMetaDataViewModel] = games.map {
    let urlString = "/game/\($0.gameId)/index.html"
    return GameMetaDataViewModel(title: $0.title, detailURLString: urlString)
}

let leagueResults = LeagueResultsViewModel(games: gameMetaDatas)

try SimulationLeague().publish(
    withTheme: .league,
    additionalSteps: [
        .addItem(Item(
            path: "rosters",
            sectionID: .rosters,
            metadata: SimulationLeague.ItemMetadata(
                leagueName: leagueName,
                teams: teams,
                game: nil
            ),
            tags: ["roster"],
            content: Content(
                title: "Roster",
                date: Date()
            )
        )),
        .addItems(in: gameItems),
        .addItem(Item(path: "leagueResults",
                      sectionID: .leagueResults,
                      metadata: SimulationLeague.ItemMetadata(leagueName: leagueName,
                                                              teams: teams,
                                                              leagueResults: leagueResults),
                                                              tags: ["leagueRosters"],
                                                              content: Content(
                                                                  title: "League Results",
                                                                  date: Date()
                                                              )))
    ]
)
