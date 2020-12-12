//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 5/23/20.
//

// ex swift run LeagueSimulator --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv
import Foundation
//import RotoSwift
import CSV
import SPMUtility
import SimulatorLib
import OlivaDomain
import SimulationLeagueSiteGenerator
import Publish

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
var standardError = StderrOutputStream()

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

public func defaultFilename(for application: String, format: String) -> String {
    let dateString = Date().toString(dateFormat: "yyyy-MM-dd-HH:mm:ss")

    return "\(FileManager.default.currentDirectoryPath)/\(application)-\(dateString).\(format)"
}

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

func createGameViewModels(from gameTeamResults: [GameTeamResult]) -> [GameViewModel] {
    let gameViewModels: [GameViewModel] = gameTeamResults.map { gameTeamResult in

        let groupedInningFrames = Dictionary(grouping: gameTeamResult.gameResult.inningFrameResults) { inningFrameResult -> Int in
            return inningFrameResult.gameState.inningCount.displayNumber
        }

        let inningResults: [LineScoreViewModel.InningResult] = groupedInningFrames.sorted (by: { (arg0, arg1) -> Bool in

            let (key, _) = arg0
            let (key2, _) = arg1
            return key < key2
        }).compactMap { tuple -> LineScoreViewModel.InningResult? in
            guard let topOfInning = tuple.value.first(where: { (inningFrameResult) -> Bool in
                return inningFrameResult.gameState.inningCount.frame == .top
            }) else { return nil }

            let bottomOfInning = tuple.value.first(where: { (inningFrameResult) -> Bool in
                return inningFrameResult.gameState.inningCount.frame == .bottom
            })

            let homeRunsScoredString: String
            if let runnersScoredInBottom = bottomOfInning?.gameState.runnersScoredInFrame {
                homeRunsScoredString = "\(runnersScoredInBottom)"
            } else {
                homeRunsScoredString = "-"
            }
            return LineScoreViewModel.InningResult(
                inningNumber: "\(tuple.key)",
                awayTeamRunsScored: "\(topOfInning.gameState.runnersScoredInFrame)",
                homeTeamRunsScored: homeRunsScoredString,
                isFinalInning: bottomOfInning?.gameState.isEndOfGame() ?? true
            )
        }


        let inningResultsViewModels: [InningResultViewModel] = gameTeamResult.gameResult.inningFrameResults.map { inningFrameResult in

            let inningFrameString = inningFrameResult.gameState.inningCount.frame == .top ? "top" : "bottom"
            let inningCountViewModel = InningCountViewModel(
                frame: inningFrameString,
                count: "\(inningFrameResult.gameState.inningCount.displayNumber)",
                outs: "\(inningFrameResult.gameState.inningCount.outs)")

            let atBatViewModels: [AtBatResultViewModel] = inningFrameResult.atBatsRecords.map { atBatRecord in

                let batterName = gameTeamResult.getBatterName(by: atBatRecord.batterId) ?? "-"
                let pitcherName = gameTeamResult.getPitcherName(by: atBatRecord.pitcherId) ?? "-"
                return AtBatResultViewModel(batterName: batterName, pitcherName: pitcherName, result: "\(atBatRecord.result)")
            }

            return InningResultViewModel(inningCount: inningCountViewModel, atBats: atBatViewModels)
        }

        let homeTeamAtBatRecords = gameTeamResult.gameResult.inningFrameResults.filter { $0.gameState.inningCount.frame == .bottom }.flatMap { $0.atBatsRecords }
        let homeTeamHits = homeTeamAtBatRecords.filter { $0.wasHit }.count

        let awayTeamAtBatRecords = gameTeamResult.gameResult.inningFrameResults.filter { $0.gameState.inningCount.frame == .top }.flatMap { $0.atBatsRecords }
        let awayTeamHits = awayTeamAtBatRecords.filter { $0.wasHit }.count
        let lineScoreViewModel = LineScoreViewModel(awayTeam: gameTeamResult.awayTeam.name,
                                  homeTeam: gameTeamResult.homeTeam.name,
                                  inningScores: inningResults,
                                  awayTeamHits: "\(awayTeamHits)",
                                  homeTeamHits: "\(homeTeamHits)",
                                  awayTeamFinalScore: "\(gameTeamResult.gameResult.awayScore)",
                                  homeTeamFinalScore: "\(gameTeamResult.gameResult.homeScore)")

        let homeBatterBoxScore = gameTeamResult.createHomeBatterBoxScore()
        let awayBatterBoxScore = gameTeamResult.createAwayBatterBoxScore()
        let homePitcherBoxScore = gameTeamResult.createHomePitcherBoxScore()
        let awayPicherBoxScore = gameTeamResult.createAwayPitcherBoxScore()

        let homeTeamBoxScoreViewModel = TeamBoxScoreViewModel(
            teamName: gameTeamResult.homeTeam.name,
            batters: homeBatterBoxScore,
            pitchers: homePitcherBoxScore
        )

        let awayTeamBoxScoreViewModel = TeamBoxScoreViewModel(
            teamName: gameTeamResult.awayTeam.name,
            batters: awayBatterBoxScore,
            pitchers: awayPicherBoxScore
        )

        let gameViewModel = GameViewModel(gameId: "\(gameTeamResult.gameId)",
                                          title: gameTeamResult.title,
                             lineScore: lineScoreViewModel,
                             inningResults: inningResultsViewModels,
                             boxScore: BoxScoreViewModel(homeTeam: homeTeamBoxScoreViewModel, awayTeam: awayTeamBoxScoreViewModel))
        return gameViewModel
    }

    return gameViewModels
}

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv --linup lineups.csv]",
overview: "Converts a set of hitter statistic projections and turns them into auction values")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFormatOption = parser.add(option: "--format", shortName: "-f", kind: String.self, usage: "Output Format text, json")

let lineupsFilenameOption = parser.add(option: "--lineups", shortName: "-l", kind: String.self, usage: "Filename for the team lineups.")

let lineupsFiletypeOption = parser.add(option: "--lineupType", shortName: "-t", kind: String.self, usage: "Type of lineup file draft or auction.")


let leagueNameOption = parser.add(option: "--leaguename", shortName: "-ln", kind: String.self, usage: "Name of the League")

let leagueAbbreviationOption = parser.add(option: "--leagueAbbreviation", shortName: "-la", kind: String.self, usage: "Abbreviation for the league for html links, no spaces")

let googleAnalyticsOption = parser.add(option: "--googleAnalytics", shortName: "-ga", kind: String.self, usage: "Google Analytics string")

let pathOption = parser.add(option: "--path", shortName: "-p", kind: String.self, usage: "Output directory")


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
let lineupsFileName = parsedArguments.get(lineupsFilenameOption)
let lineupsFiletype = parsedArguments.get(lineupsFiletypeOption)
let outputFormatArgument = parsedArguments.get(outputFormatOption)
let pathString = parsedArguments.get(pathOption)
let googleAnalyticsKey = parsedArguments.get(googleAnalyticsOption) ?? "Unknown GA Key"

let leagueName = parsedArguments.get(leagueNameOption) ?? "FanSim League"
let leagueAbbreviation = parsedArguments.get(leagueAbbreviationOption) ?? "RL1"

enum OutputFormat: String {
    case text
    case json
    case publish
}

public enum LineupFiletype: String {
    case draft
    case auction
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



let lineupType: LineupFiletype

if let lineupsFiletype = lineupsFiletype {
    lineupType = LineupFiletype(rawValue: lineupsFiletype) ?? .auction
} else {
    lineupType = .auction
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

let teams: [TeamProjections]

switch lineupType {
case .auction:
    teams = createTeams(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)
case .draft:
    teams = createDraftTeams(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)
}

guard teams.count > 0 else {
    print("Error no teams defined")
    exit(0)
}

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

let lineups = teams.map { return createLineups(for: $0) }

func simulateGames(for teams: [TeamProjections], pitcherDictionary: [String : PitcherProjection], batterDictionary: [String : BatterProjection]) -> [GameTeamResult] {
    let teamsInLeague = teams.count

    let teamLineups = teams.map { (team: $0, linups: createLineups(for: $0)) }


    var gameTeamResults = [GameTeamResult]()
    var gameId = 0
    var gamePeriodIndex = 0
    let gamesPerSeries = 3

    let lineupPerTeam = teamLineups.first!.linups.count

    let totalGames = (teamsInLeague-1) * teamLineups.count * gamesPerSeries
    var gameCount = 1

    for (index, teamLineup) in teamLineups.enumerated() {
        (1..<teamsInLeague).forEach { awayTeamIndex in
            let awayTeam = teamLineups[(awayTeamIndex + index) % teamsInLeague]

            (0..<gamesPerSeries).forEach { seriesIndex in
                let awayTeamLineup = awayTeam.linups[(gamePeriodIndex + seriesIndex) % lineupPerTeam]
                let homeTeamLineup = teamLineup.linups[(gamePeriodIndex + seriesIndex) % lineupPerTeam]

                let gameResult = simulateGame(homeLineup: homeTeamLineup,
                             awayLineup: awayTeamLineup,
                             pitcherDictionary: pitcherDictionary,
                             batterDictionary: batterDictionary
                )

                let gameTeamResult = GameTeamResult(
                    gameId: "\(gameId)",
                    gameResult: gameResult,
                    homeTeam: teamLineup.team,
                    awayTeam: awayTeam.team
                )

                gameId += 1

                print("\(gameCount) / \(totalGames) - \(awayTeam.team.name): \(gameTeamResult.gameResult.awayScore) at \(teamLineup.team.name): \(gameTeamResult.gameResult.homeScore) ", to: &standardError)

                gameTeamResults.append(gameTeamResult)
                gameCount += 1
            }

            gamePeriodIndex += gamesPerSeries
        }
    }
    return gameTeamResults
}


struct GameTeamResult {
    let gameId: String
    let gameResult: GameResult
    let homeTeam: SimulatorLib.TeamProjections
    let awayTeam: SimulatorLib.TeamProjections

    var title: String {
        return "\(awayTeam.name) at \(homeTeam.name)"
    }

    var detailURLString: String {
        return "-"
    }

    var result: String {
        return "\(homeTeam.name) \(gameResult.homeScore) \(awayTeam.name) \(gameResult.awayScore)"
    }

    var homeTeamWon: Bool {
        return gameResult.homeScore > gameResult.awayScore
    }

    var homeTeamHits: Int {
        homeTeamAtBatRecords.filter { return $0.wasHit }.count
    }

    var homeTeamAtBatRecords: [AtBatRecord] {
        return gameResult.inningFrameResults.filter { $0.gameState.inningCount.frame == .bottom }.flatMap { $0.atBatsRecords }
    }

    var awayTeamHits: Int {
        awayTeamAtBatRecords.filter { $0.wasHit }.count
    }

    var awayTeamAtBatRecords: [AtBatRecord] {
        return gameResult.inningFrameResults.filter { $0.gameState.inningCount.frame == .top }.flatMap { $0.atBatsRecords }
    }


    func getBatterName(by playerId: String) -> String? {
        let batter = homeTeam.batters.first(where: { return $0.playerId == playerId }) ??
            awayTeam.batters.first(where: { return $0.playerId == playerId })

        return batter?.fullName
    }

    func getPitcherName(by playerId: String) -> String? {
        let pitcher = homeTeam.pitchers.first(where: { return $0.playerId == playerId }) ??
            awayTeam.pitchers.first(where: { return $0.playerId == playerId })

        return pitcher?.fullName
    }
}

let gameTeamResults = simulateGames(
    for: teams,
    pitcherDictionary: pitcherProjections,
    batterDictionary: hitterProjections
)

func convertToLeagueResultsViewModel(teams: [SimulatorLib.TeamProjections], gameTeamResults: [GameTeamResult]) -> LeagueResultsViewModel? {

    let gameViewModels: [GameMetaDataViewModel] = gameTeamResults.map { gameTeamResult in

        let urlString = "../game/\(gameTeamResult.gameId)/index.html"

        return GameMetaDataViewModel(
            title: gameTeamResult.title,
            detailURLString: urlString,
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
        let team: SimulatorLib.TeamProjections
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

        let winningPercentageString = String(format: "%.3f", winningPercentage)
        return TeamStandingsViewModel(teamName: teamName,
                                      wins: "\(gamesWon)",
                                      losses: "\(gamesLost)",
                                      winPercentage: winningPercentageString)
    }.sorted { teamStandings1, teamStandings2 -> Bool in
        return teamStandings1.winPercentage > teamStandings2.winPercentage
    }

    let standingsViewModel = StandingsViewModel(teamStandings: teamStandingsViewModels)
    return standingsViewModel
}

guard let leagueResultsViewModel = convertToLeagueResultsViewModel(teams: teams, gameTeamResults: gameTeamResults) else {
    print("ERROR: unable to create leagueResultsViewModel")
    exit(0)
}

let lineScoreViewModals: [LineScoreViewModel] = gameTeamResults.map { gameTeamResult in

    let inningScores: [LineScoreViewModel.InningResult] = gameTeamResult.gameResult.inningFrameResults.map { inningFrameResult in

        return LineScoreViewModel.InningResult(inningNumber: "\(inningFrameResult.gameState.inningCount.displayNumber)",
                                               awayTeamRunsScored: "\(inningFrameResult.gameState.totalAwayRunsScored)",
                                               homeTeamRunsScored: "\(inningFrameResult.gameState.totalHomeRunsScored)",
                                               isFinalInning: false)

    }
    return LineScoreViewModel(awayTeam: gameTeamResult.awayTeam.name,
                              homeTeam: gameTeamResult.homeTeam.name,
                              inningScores: inningScores,
                              awayTeamHits: "\(gameTeamResult.homeTeamHits)",
                              homeTeamHits: "\(gameTeamResult.awayTeamHits)",
                              awayTeamFinalScore: "\(gameTeamResult.gameResult.awayScore)",
                              homeTeamFinalScore: "\(gameTeamResult.gameResult.homeScore)")

}

let gameViewModels = createGameViewModels(from: gameTeamResults)

extension GameTeamResult {
    func createHomeBatterBoxScore() -> [BatterBoxScore] {
        return homeTeam.batterLineup.batterLineupPositions.map { batterLineupPosition in
            // runs for a batter requires all atBatRecords
            let batterRuns = gameResult.runs(for: batterLineupPosition.batterProjection.playerId)
            return createBatterBoxScore(
                for: batterLineupPosition.batterProjection,
                with: gameResult.atBatRecords(for: batterLineupPosition.batterProjection.playerId),
                runs: batterRuns
            )
        }
    }

    func createAwayBatterBoxScore() -> [BatterBoxScore] {
        return awayTeam.batterLineup.batterLineupPositions.map { batterLineupPosition in
            let batterRuns = gameResult.runs(for: batterLineupPosition.batterProjection.playerId)
            return createBatterBoxScore(
                for: batterLineupPosition.batterProjection,
                with: gameResult.atBatRecords(for: batterLineupPosition.batterProjection.playerId),
                runs: batterRuns
            )
        }
    }

    func createHomePitcherBoxScore() -> [PitcherBoxScore] {
        let atBatRecords = self.gameResult.topInningFrameResults.flatMap {
            $0.atBatsRecords
        }

        return createPitcherBoxScore(from: atBatRecords)
    }

    func createAwayPitcherBoxScore() -> [PitcherBoxScore] {
        let atBatRecords = self.gameResult.bottomInningFrameResults.flatMap {
            $0.atBatsRecords
        }

        return createPitcherBoxScore(from: atBatRecords)
    }

    func createBatterBoxScore(for batter: BatterProjection, with atBatRecords: [AtBatRecord], runs: Int) -> BatterBoxScore {

        // we should likely pass in all the atBatRecords and filter here. This way we don't have to pass in runs
        let runsBattedIn = atBatRecords.map { $0.resultingState.runnersScored.count }.reduce(0,+)

        return BatterBoxScore(
            playerName: batter.fullName,
            atBats: "\(atBatRecords.filter { $0.wasAtBat}.count)",
            runs: "\(runs)",
            hits: "\(atBatRecords.filter({ $0.wasHit }).count)",
            rbis: "\(runsBattedIn)",
            strikeouts: "\(atBatRecords.filter({ $0.result == .strikeout }).count)"
        )
    }

    func createBatterBoxScore(from atBatRecords: [AtBatRecord]) -> [BatterBoxScore] {
        let batterGroupedDictionary = Dictionary(grouping: atBatRecords) { atBatRecord in
            return atBatRecord.batterId
        }

        let batterBoxScores: [BatterBoxScore] = batterGroupedDictionary.map { tuple in
            let atBats = tuple.value.filter({ $0.wasAtBat }).count
            let hits = tuple.value.filter({ $0.wasHit }).count
            let strikeouts = tuple.value.filter({ $0.result == .strikeout }).count
            return BatterBoxScore(playerName: self.getBatterName(by: tuple.key) ?? "-",
                           atBats: "\(atBats)",
                           runs: "",
                           hits: "\(hits)",
                           rbis: "",
                           strikeouts: "\(strikeouts)"
            )
        }

        return batterBoxScores
    }

    func createPitcherBoxScore(from atBatRecords: [AtBatRecord]) -> [PitcherBoxScore] {
        let pitcherGroupedDictionary = Dictionary(grouping: atBatRecords) { atBatRecord in
            return atBatRecord.pitcherId
        }

        let pitcherBoxScores: [PitcherBoxScore] = pitcherGroupedDictionary.map { keyValue in
            let hits = keyValue.value.filter({ $0.wasHit }).count
            let walks = keyValue.value.filter({ $0.result == .walk }).count
            let strikeouts = keyValue.value.filter({ $0.result == .strikeout }).count
            let homeRuns = keyValue.value.filter({$0.result == .homerun}).count
            let outs = keyValue.value.filter({ $0.wasOut}).count

            // doesn't exactly match earned runs
            let earnedRuns = keyValue.value.map { $0.resultingState.runnersScored.count }.reduce(0,+)

            let outsPerInning = 3

            let inningsPitchedString: String
            let partialInningOuts = outs % outsPerInning

            if partialInningOuts > 0 {
                if partialInningOuts == 1 {
                    inningsPitchedString = "\(outs / outsPerInning) 1/3"
                } else {
                    inningsPitchedString = "\(outs / outsPerInning) 2/3"
                }
            } else {
                inningsPitchedString = "\(outs / outsPerInning)"
            }

            return PitcherBoxScore(
                playerName: self.getPitcherName(by: keyValue.key) ?? "-",
                inningsPitched: inningsPitchedString,
                hits: "\(hits)",
                runs: "\(earnedRuns)",
                walks: "\(walks)",
                strikeouts: "\(strikeouts)",
                homeRuns: "\(homeRuns)"
            )
        }

        return pitcherBoxScores
    }
}

let teamViewModels: [TeamViewModel] = teams.map { lineup in
    let batterViewModels = lineup.batters.map { lineupBatter in
        return PlayerViewModel(fullName: lineupBatter.fullName)
    }

    let pitcherViewModels = lineup.pitchers.map { lineupPitcher in
        return PlayerViewModel(fullName: lineupPitcher.fullName)
    }
    return TeamViewModel(name: lineup.name, batters: batterViewModels, pitchers: pitcherViewModels)
}

let leagueData = LeagueData(leagueName: leagueName,
                            teams: teamViewModels,
                            leagueResults: leagueResultsViewModel,
                            games: gameViewModels
                )


switch outputFormat {
case .text:
    printText(gameTeamResults.map { $0.gameResult})
case .json:
//    let viewModel = convertToLeagueResultsViewModel(teams: lineups, gameTeamResults: gameTeamResults)
//
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    let data = try jsonEncoder.encode(leagueData)

    print(String(data: data, encoding: .utf8)!)
case .publish:
    let path: Path?
    if let pathString = pathString {
        try createContentDirectory(at: pathString)
        path = Path(pathString)
    } else {
        path = nil
    }

    print("DEBUG path=\(String(describing: path))")

    if googleAnalyticsKey.isEmpty {
        print("WARNING: googleAnalyticsKey is empty")
    }

    publishSimulationLeagueSite(from: leagueData, googleAnalyticsId: googleAnalyticsKey, at: path )
}

func createContentDirectory(at basePathString: String) throws {
    let filemanager = FileManager.default

    guard let baseURL = URL(string: basePathString) else {
        print("Unable to create URL: \(basePathString)")
        exit(0)
    }

    let contentDirectory = baseURL.appendingPathComponent("Content")

    if !filemanager.fileExists(atPath: contentDirectory.absoluteString) {
        try filemanager.createDirectory(at: contentDirectory, withIntermediateDirectories: false)
    }
}
///output
///
//Teams
// GameResults
//      Home Team
//      Away Team
