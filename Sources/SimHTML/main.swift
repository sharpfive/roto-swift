//
//  main.swift
//  
//
//  Created by Jaim Zuber on 4/5/20.
//

import Foundation
import Plot
import SimulatorLib
import Publish
import OlivaDomain
import ArgumentParser

// ex swift run SimHTML --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv

struct LeagueSimulatorCommand: ParsableCommand {
    @Argument(help: "CSV file of hitter projections")
    var hitterProjectionsFilename: String

    @Argument(help: "CSV file of pitcher projections")
    var pitcherProjectionsFilename: String

    @Argument(help: "json file with Lineups data")
    var lineupsFilename: String

    mutating func run() throws {
        try runMain(hitterFilename: hitterProjectionsFilename,
                pitcherFilename: pitcherProjectionsFilename,
                lineupsFilename: lineupsFilename)
    }
}

struct SimulationLeague: Website {
    enum SectionID: String, WebsiteSectionID {
        case rosters
        case game
        case leagueResults
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        let leagueName: String
        let teams: [TeamProjections]
        let game: GameViewModel?
        let leagueResults: LeagueResultsViewModel?

        init(leagueName: String,
             teams: [TeamProjections],
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

func runMain(hitterFilename: String,
             pitcherFilename: String,
             lineupsFilename: String) throws {
    let hitterProjections = inputHitterProjections(filename: hitterFilename)
    let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)
    let teams = createTeams(filename: lineupsFilename,
                            batterProjections: hitterProjections,
                            pitcherProjections: pitcherProjections)

    //TODO need to create the games, similar to LeagueSimulator

    let leagueName = "CIK"

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

    func createGame(with gameId: String) -> GameViewModel {
        //TODO team names (team repository?)
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
}
