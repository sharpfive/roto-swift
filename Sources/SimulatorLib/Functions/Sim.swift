//
//  File.swift
//  
//
//  Created by Jaim Zuber on 4/10/20.
//

import CSV
import Foundation
import RotoSwift

public struct AtBatResultState {
    public let baseOccupancy: BaseOccupancy
    public let runnersScored: [String]
}

public func simulateInningFrame(lineup: GameLineup, gameState: GameState, baseProbability: AtBatEventProbability) -> InningFrameResult {
    var gameState = gameState

    var atBatResults = [AtBatRecord]()

    while !gameState.isEndOfFrame() {

        // get pitcher probability
        let pitchingTeam = gameState.inningCount.frame == .top ?
            lineup.homeTeam : lineup.awayTeam

        let pitcherProbability = pitchingTeam.startingPitcher

        // get batter probability
        let battingTeam = gameState.inningCount.frame == .top ?
            lineup.awayTeam : lineup.homeTeam
        let battersRetired = gameState.inningCount.frame == .top ? gameState.awayBattersRetired : gameState.homeBattersRetired

        let batterProbability = battingTeam.getProbability(for: battersRetired)

        // print("batter: \(batterProbability.playerId)")
        // get at bat result
        let atBatResult = getAtBatEvent(pitcherProbability: pitcherProbability.probability,
                                        batterProbability: batterProbability.probability,
                                        baseProbability: baseProbability)

        let atBatResultState = gameState.addAtBatResult(atBatResult, batterId: batterProbability.playerId)
        atBatResults.append(
            AtBatRecord(batterId: batterProbability.playerId,
                        pitcherId: pitcherProbability.playerId,
                        result: atBatResult,
                        resultingState: atBatResultState
            )
        )
    }

    return InningFrameResult(atBatsRecords: atBatResults, gameState: gameState)
}

public func getAtBatEvent(pitcherProbability: AtBatEventProbability,
                   batterProbability: AtBatEventProbability,
                   baseProbability: AtBatEventProbability) -> AtBatOutcome {
    // do fancy Odds Ratio math from Tony Tango
    // http://www.insidethebook.com/ee/index.php/site/comments/the_odds_ratio_method/

    func oddsRatio(batter: Double, pitcher: Double, base: Double) -> Double {
        if base == 0.0 {
            return 0
        }

        return batter * pitcher / base
    }

    let singleOdds = oddsRatio(batter: batterProbability.single, pitcher: pitcherProbability.single, base: baseProbability.single)
    let doubleOdds = oddsRatio(batter: batterProbability.double, pitcher: pitcherProbability.double, base: baseProbability.double)
    let tripleOdds = oddsRatio(batter: batterProbability.triple, pitcher: pitcherProbability.triple, base: baseProbability.triple)
    let homeRunOdds = oddsRatio(batter: batterProbability.homeRun, pitcher: pitcherProbability.homeRun, base: baseProbability.homeRun)
    let hitByPitchOdds = oddsRatio(batter: batterProbability.hitByPitch, pitcher: pitcherProbability.hitByPitch, base: baseProbability.hitByPitch)
    let walkOdds = oddsRatio(batter: batterProbability.walk, pitcher: pitcherProbability.walk, base: baseProbability.walk)
    let strikeoutOdds = oddsRatio(batter: batterProbability.strikeOut, pitcher: pitcherProbability.strikeOut, base: baseProbability.strikeOut)

    let outOdds = 1 - (singleOdds + doubleOdds + tripleOdds + homeRunOdds + hitByPitchOdds + walkOdds + strikeoutOdds)
    //let outOdds = oddsRatio(batter: batterProbability.out, pitcher: pitcherProbability.out, base: baseProbability.out)

    // print("outOdds: \(outOdds)")
    let weights: [(outcome: AtBatOutcome, weight: Double)] = [
        (outcome: .single, weight: singleOdds),
        (outcome: .double, weight: doubleOdds),
        (outcome: .triple, weight: tripleOdds),
        (outcome: .homerun, weight: homeRunOdds),
        (outcome: .hitByPitch, weight: hitByPitchOdds),
        (outcome: .walk, weight: walkOdds),
        (outcome: .strikeout, weight: strikeoutOdds),
        (outcome: .out, weight: outOdds)
    ]


//    let totalWeights: Double = weights.map{ $0.weight }.reduce(0,+)
//    print(">-------<")
//    print("totalWeights: \(totalWeights)")
//    print("pitcherProbability: \(pitcherProbability)")
//    print("batterProbability: \(batterProbability)")
//    print("baseProbability: \(baseProbability)")
//    print(">-----<")
//    weights.forEach {
//        print("\($0)")
//    }

    return getRandomElementWeighted(weights)
}

func getRandomElementWeighted(_ weights: [(outcome: AtBatOutcome, weight: Double)]) -> AtBatOutcome {
    // Thanks to the person at https://stackoverflow.com/questions/41418689/get-random-element-from-array-with-weighted-elements/41418770#41418770
    let totalWeights = weights.map { $0.weight }.reduce(0,+)

    let resultWeight = drand48() * totalWeights

//    print("totalWeights: \(totalWeights) - result: \(resultWeight)")
//    weights.forEach {
//        print("\($0)")
//    }

    var lastWeight: Double = 0.0
    let weightedArray: [(outcome: AtBatOutcome, weight: Double)] = weights.map {
        let weightValue = $0.weight + lastWeight
        lastWeight = weightValue
        return (outcome: $0.outcome, weight: weightValue)
    }

//    print("weighted array!")
//    weightedArray.forEach {
//        print("\($0)")
//    }

    if let result = weightedArray.first(where: { $0.weight >= resultWeight }).map({ $0.outcome}) {
        return result
    } else {
        // shouldn't get here
        print("!!!! shouldn't get here")
        print("totalWeights: \(totalWeights) - result: \(resultWeight)")

        print("weighted array!")
        weightedArray.forEach {
            print("\($0)")
        }
        return .out
    }
}

public func createDraftTeams(filename: String, batterProjections: [String: BatterProjection], pitcherProjections: [String: PitcherProjection]) -> [TeamProjections] {

    let requiredBatters = 9
    let requiredPitchers = 5

    let repository = CouchManagerLeagueRespository(filename: filename)
    let draftEntries = repository.getDraftEntries()

    var teamPlayers = [String: [CouchManagerLeagueRespository.DraftEntry]]()

    for draftEntry in draftEntries {
        var teamArray = teamPlayers[draftEntry.teamName] ?? [CouchManagerLeagueRespository.DraftEntry]()
        teamArray.append(draftEntry)

        teamPlayers[draftEntry.teamName] = teamArray
    }

    let playerComparer = PlayerComparer()

    var teams = [TeamProjections]()

    for teamName in teamPlayers.keys {
        guard let playerArray = teamPlayers[teamName] else { continue }
        var batters = [BatterProjection]()
        var pitchers = [PitcherProjection]()

        for draftEntry in playerArray {
            let draftedBatters = [CouchManagerLeagueRespository.DraftEntry]()
            let draftedPitchers = [CouchManagerLeagueRespository.DraftEntry]()

            if draftedBatters.count < requiredBatters,
                let batterProjection = batterProjections.values.first(where: {
                playerComparer.isSamePlayer(playerOne: draftEntry, playerTwo: $0)
            }) {
                batters.append(batterProjection)
            } else if draftedPitchers.count < requiredPitchers,
                      let pitcherProjection = pitcherProjections.values.first(where: {
                        playerComparer.isSamePlayer(playerOne: draftEntry, playerTwo: $0)
                      }) {
                pitchers.append(pitcherProjection)
            } else {
                print("ERROR: createDraftTeams can't find \(draftEntry)")
            }
        }
        let team: TeamProjections = TeamProjections(
            identifier: teamName,
            name: teamName,
            pitchers: pitchers,
            batters: batters)

//        if teams.count >= 2 {//aiai
//            continue
//        }
        teams.append(team)
    }

    return teams
}

public func createTeams(filename: String, batterProjections: [String: BatterProjection], pitcherProjections: [String: PitcherProjection]) -> [TeamProjections] {

    let requiredBatters = 9
    let requiredPitchers = 5

    let repository = CouchManagerLeagueRespository(filename: filename)
    let auctionEntries = repository.getAuctionEntries()

    var currentTeamId: Int?
    var currentTeamName: String = ""

    let playerComparer = PlayerComparer()

    var batters = [BatterProjection]()
    var pitchers = [PitcherProjection]()

    var teams = [TeamProjections]()

    for auctionEntry in auctionEntries {
        if let unwrappedCurrentTeamId = currentTeamId,
            currentTeamId != auctionEntry.teamNumber {

            guard pitchers.count >= requiredPitchers else {
                print("Invalid lineup for team: \(String(describing: currentTeamId)) - not enough pitchers")
                exit(0)
            }

            guard batters.count >= requiredBatters else {
                print("Invalid lineup for team \(String(describing: currentTeamId)) - not enough pitchers")
                exit(0)
            }

            let team = TeamProjections(identifier: "\(unwrappedCurrentTeamId)", name: currentTeamName, pitchers: pitchers, batters: batters)

//            if teams.count >= 2 {//aiai
//                continue
//            }

            teams.append(team)

            // Reset counters
            batters = [BatterProjection]()
            pitchers = [PitcherProjection]()
            currentTeamId = auctionEntry.teamNumber
            currentTeamName = auctionEntry.teamName
        }

        currentTeamId = auctionEntry.teamNumber
        currentTeamName = auctionEntry.teamName

        if batters.count < requiredBatters,
            let batterProjection = batterProjections.values.first(where: {
            playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }) {
            batters.append(batterProjection)
        } else if pitchers.count < requiredPitchers, // else is because we don't have another way to determine Will Smoth or Jose Ramirez are pitchers or batters
            // we'll assume they are hitters for now
            let pitcherProjection = pitcherProjections.values.first(where: {
                playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }) {
            pitchers.append(pitcherProjection)
        }
    }

    return teams
}

public func inputHitterProjections(filename: String) -> [String: BatterProjection] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true)

    var hitterProjectionsDictionary = [String: BatterProjection]()
    while let row = csv.next() {
        guard let plateAppearances = Int(row[3]),
            let hits = Int(row[5]),
            let doubles = Int(row[6]),
            let triples = Int(row[7]),
            let homeRuns = Int(row[8]),
            let walks = Int(row[11]),
            let strikeouts = Int(row[12]),
            let hitByPitch = Int(row[13]) else {
                print("Invalid row: \(row)")
                exit(0)
        }

        let playerId = row[32]
        let playerName = row[0]

        let hitterProjection = BatterProjection(playerId: playerId,
                                                 fullName: playerName,
                                                 plateAppearances: plateAppearances,
                                                 hits: hits,
                                                 doubles: doubles,
                                                 triples: triples,
                                                 homeRuns: homeRuns,
                                                 walks: walks,
                                                 strikeouts: strikeouts,
                                                 hitByPitch: hitByPitch)

        hitterProjectionsDictionary[playerId] = hitterProjection
    }

    return hitterProjectionsDictionary
}

public func inputPitcherProjections(filename: String) -> [String: PitcherProjection] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true)

    var pitcherProjectionsDictionary = [String: PitcherProjection]()
    while let row = csv.next() {
        guard let inningsPitchedDouble = Double(row[8]),
            let hits = Int(row[9]),
            let homeRuns = Int(row[11]),
            let strikeouts = Int(row[12]),
            let walks = Int(row[13])
            else {
                print("Invalid Pitcher row: \(row)")
                exit(0)
        }

        let playerId = row[21]
        let playerName = row[0]
        let inningsPitched = Int(inningsPitchedDouble)

        let pitcherProjection = PitcherProjection(playerId: playerId,
                                                  fullName: playerName,
                                                  inningsPitched: inningsPitched,
                                                  hits: hits,
                                                  homeRuns: homeRuns,
                                                  walks: walks,
                                                  strikeouts: strikeouts)
        pitcherProjectionsDictionary[playerId] = pitcherProjection
    }

    return pitcherProjectionsDictionary
}

public func simulateGame(homeLineup: Lineup,
                         awayLineup: Lineup,
                         pitcherDictionary: [String: PitcherProjection],
                         batterDictionary: [String: BatterProjection],
                         baseProjections: AtBatEventProbability? = nil) -> GameResult {
    let converter = ProbabilityLineupConverter(pitcherDictionary: pitcherDictionary,
                                               batterDictionary: batterDictionary)

    let awayProbabilities = converter.convert(lineup: awayLineup)
    let homeProbabilities = converter.convert(lineup: homeLineup)
    let baseProbabilities = baseProjections ?? converter.baseAtBatProbabilites

    let gameLineup = GameLineup(awayTeam: awayProbabilities, homeTeam: homeProbabilities)

    var gameState = GameState(inningCount: InningCount(frame: .top, number: 0, outs: 0), homeBattersRetired: 0, awayBattersRetired: 0)

    srand48(Int(Date().timeIntervalSince1970))

    var gameStarted = true

    var inningFrameResults = [InningFrameResult]()

    repeat {

        if gameStarted {
            gameStarted = false
        } else {
            gameState.advanceFrame()
        }
        let inningFrameResult = simulateInningFrame(lineup: gameLineup, gameState: gameState, baseProbability: baseProbabilities)

        gameState = inningFrameResult.gameState

        inningFrameResults.append(inningFrameResult)

    } while !gameState.isEndOfGame()

    return GameResult(inningFrameResults: inningFrameResults)
}

public func createLineups(for team: TeamProjections) -> [Lineup] {
    return team.pitchers.map { pitcherProjection in
        return Lineup(startingPitcherId: pitcherProjection.playerId, batterIds: team.batters.prefix(9).map{ $0.playerId })
    }
}

