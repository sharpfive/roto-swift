//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 3/23/20.
//

// ex swift run GameSimulator --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv
import Foundation
import RotoSwift
import CSV
import SPMUtility

struct AtBatEventProbability {
    let single: Double
    let double: Double
    let triple: Double
    let homeRun: Double
    let walk: Double
    let strikeOut: Double
    let hitByPitch: Double
    let out: Double

    var singleOdds: Double {
        return odds(for: single)
    }

    var doubleOdds: Double {
        return odds(for: double)
    }

    var tripleOdds: Double {
        return odds(for: triple)
    }

    var homeRunOdds: Double {
        return odds(for: homeRun)
    }

    var walkOdds: Double {
        return odds(for: walk)
    }

    var strikeoutOdds: Double {
        return odds(for: strikeOut)
    }

    var hitByPitchOdds: Double {
        return odds(for: hitByPitch)
    }

    var outOdds: Double {
        return odds(for: out)
    }

    func odds(for value: Double) -> Double {
        return value / (1 - value)
    }
}

struct PlayerProbability {
    let playerId: String
    let probability: AtBatEventProbability
}

struct TeamLineupProbabilities {
    let startingPitcher: PlayerProbability
    let batters: [PlayerProbability]

    func getProbability(for battersRetired: Int) -> PlayerProbability {
        return batters[battersRetired % 8]
    }
}

struct Lineup {
    let startingPitcherId: String
    let batterIds: [String]
}

struct Team {
    let identifier: String
    let name: String
    let lineup: Lineup
}

struct GameLineup {
    let awayTeam: TeamLineupProbabilities
    let homeTeam: TeamLineupProbabilities
}

struct GameState {
    var inningCount: InningCount = InningCount.beginningOfGame()
    var homeBattersRetired = 0
    var awayBattersRetired = 0

    private(set) var firstBaseOccupant: String?
    private(set) var secondBaseOccupant: String?
    private(set) var thirdBaseOccupant: String?
    private(set) var runnersScoredInFrame = 0
    private(set) var homeRunsScored = 0
    private(set) var awayRunsScored = 0

    var totalHomeRunsScored: Int {
        if inningCount.frame == .bottom {
            return homeRunsScored + runnersScoredInFrame
        } else {
            return homeRunsScored
        }
    }

    var totalAwayRunsScored: Int {
        if inningCount.frame == .top {
            return awayRunsScored + runnersScoredInFrame
        } else {
            return awayRunsScored
        }
    }

    func isEndOfFrame() -> Bool {
        return inningCount.outs >= 3
    }

    func isEndOfInning() -> Bool {
        if case inningCount.frame = InningFrame.bottom {
            return isEndOfFrame()
        } else {
            return false
        }
    }

    // Game state functions are meant to be called before advanceFrame
    func isEndOfGame() -> Bool {

        if !isEndOfFrame() {
            if inningCount.number >= 8 {
                if inningCount.frame == .top &&
                    inningCount.outs >= 3 &&
                    totalHomeRunsScored > totalAwayRunsScored {
                    return true
                } else if inningCount.frame == .bottom &&
                    totalHomeRunsScored > totalAwayRunsScored {
                    return true
                }
            }

            return false
        }

        if inningCount.number < 8 {
            return false
        }

        if !isEndOfInning() {
            if inningCount.number >= 8 {
                if inningCount.frame == .top &&
                    inningCount.outs >= 3 &&
                    totalHomeRunsScored > totalAwayRunsScored {
                    return true
                } else if inningCount.frame == .bottom &&
                    totalHomeRunsScored > totalAwayRunsScored {
                    return true
                }
            }
            return false
        }

        // Score is tied at the end of the inning
        if totalHomeRunsScored == totalAwayRunsScored {
            return false
        }

        // Game is over!
        return true
    }

    mutating private func countScores() {
        if inningCount.frame == .top {
            awayRunsScored += runnersScoredInFrame
        } else {
            homeRunsScored += runnersScoredInFrame
        }
    }

    mutating func addAtBatResult(_ atBatResult: AtBatOutcome) {
        switch atBatResult {
        case .strikeout, .out:
            recordOut()
        case .single, .hitByPitch, .walk:
            advanceRunners(by: 1)
        case .double:
            advanceRunners(by: 2)
        case .triple:
            advanceRunners(by: 3)
        case .homerun:
            advanceRunners(by: 4)
        }

        if inningCount.frame == .top {
            awayBattersRetired += 1
        } else {
            homeBattersRetired += 1
        }
    }

    mutating private func recordOut() {
        inningCount.outs += 1
    }

    mutating private func advanceRunners(by bases: Int) {
        let occupantId = "-1"

        switch bases {
        case 1:
            if thirdBaseOccupant != nil {
                runnersScoredInFrame += 1
                thirdBaseOccupant = nil
            }

            if let secondBaseOccupant = secondBaseOccupant {
                thirdBaseOccupant = secondBaseOccupant
            }

            if let firstBaseOccupant = firstBaseOccupant {
                secondBaseOccupant = firstBaseOccupant
            }

            firstBaseOccupant = occupantId
        case 2:
            if thirdBaseOccupant != nil {
                runnersScoredInFrame += 1
                self.thirdBaseOccupant = nil
            }

            if secondBaseOccupant != nil {
                runnersScoredInFrame += 1
                self.secondBaseOccupant = nil
            }

            if let firstBaseOccupant = firstBaseOccupant {
                thirdBaseOccupant = firstBaseOccupant
            }

            firstBaseOccupant = nil
            secondBaseOccupant = occupantId

        case 3:
            if thirdBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            if secondBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            if firstBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            firstBaseOccupant = nil
            secondBaseOccupant = nil
            thirdBaseOccupant = occupantId

        case 4:
            if thirdBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            if secondBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            if firstBaseOccupant != nil {
                runnersScoredInFrame += 1
            }

            runnersScoredInFrame += 1

            firstBaseOccupant = nil
            secondBaseOccupant = nil
            thirdBaseOccupant = nil

        default:
            print("advanceRunners should never get here")
        }
    }

    mutating func advanceFrame() {
        countScores()

        firstBaseOccupant = nil
        secondBaseOccupant = nil
        thirdBaseOccupant = nil
        runnersScoredInFrame = 0
        inningCount.increment()
    }
}

enum InningFrame {
    case top
    case bottom
}

struct InningCount {
    var frame: InningFrame
    var number: Int
    var outs: Int

    static func beginningOfGame() -> InningCount {
        return InningCount(frame: .top, number: 0, outs: 0)
    }

    mutating func increment() {
        switch frame {
        case .top:
            frame = .bottom

        case .bottom:
            frame = .top
            number += 1
        }

        outs = 0
    }
}

enum AtBatOutcome {
    case single
    case double
    case triple
    case homerun
    case walk
    case strikeout
    case hitByPitch
    case out
}

struct AtBatRecord {
    let batterId: String
    let pitcherId: String
    let result: AtBatOutcome
}

struct InningFrameResult {
    let atBatsRecords: [AtBatRecord]
    let gameState: GameState
}

func simulateInningFrame(lineup: GameLineup, gameState: GameState, baseProbability: AtBatEventProbability) -> InningFrameResult {
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

        gameState.addAtBatResult(atBatResult)
        atBatResults.append(AtBatRecord(batterId: batterProbability.playerId, pitcherId: pitcherProbability.playerId, result: atBatResult))
    }

    return InningFrameResult(atBatsRecords: atBatResults, gameState: gameState)
}

func getAtBatEvent(pitcherProbability: AtBatEventProbability,
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
    let outOdds = oddsRatio(batter: batterProbability.out, pitcher: pitcherProbability.out, base: baseProbability.out)

    //print("outOdds: \(outOdds)")
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

//    print(">-------<")
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

struct PitcherProjection: FullNameHaving {
    let playerId: String
    let fullName: String
    let inningsPitched: Int
    let hits: Int
    let homeRuns: Int
    let walks: Int
    let strikeouts: Int

    var plateAppearances: Int {
        inningsPitched * 3 +
        hits +
        walks
    }

    func probability(doublePercentage: Double, triplePercentage: Double, hitByPitchProbability: Double) -> AtBatEventProbability {
        let estimatedDoubles = Double(hits) * doublePercentage
        let estimatedTriples = Double(hits) * triplePercentage
        let doubleProbability = estimatedDoubles / Double(plateAppearances)
        let tripleProbability = estimatedTriples / Double(plateAppearances)
        let singleProbability = (Double(hits) - Double(homeRuns) - estimatedDoubles - estimatedTriples) / Double(plateAppearances)
        let homeRunProbability: Double = Double(homeRuns) / Double(plateAppearances)
        let walkProbability: Double = Double(walks) / Double(plateAppearances)
        let strikeoutProbability: Double = Double(strikeouts) / Double(plateAppearances)

        let outs = plateAppearances - hits - strikeouts - Int((Double(plateAppearances) * hitByPitchProbability))
        let outProbability: Double = Double(outs) / Double(plateAppearances)

        return AtBatEventProbability(single: singleProbability, double: doubleProbability, triple: tripleProbability, homeRun: homeRunProbability, walk: walkProbability, strikeOut: strikeoutProbability, hitByPitch: hitByPitchProbability, out: outProbability)
    }
}

// Read in batter stats file
struct BatterProjection: FullNameHaving {
    let playerId: String
    let fullName: String
    let plateAppearances: Int
    let singles: Int
    let doubles: Int
    let triples: Int
    let homeRuns: Int
    let walks: Int
    let strikeouts: Int
    let hitByPitch: Int

    var outs: Int {
        return plateAppearances - singles - doubles - triples - hitByPitch - homeRuns - walks
    }

    var probability: AtBatEventProbability {
        let singleProbability: Double = Double(singles) / Double(plateAppearances)
        let doubleProbability: Double = Double(doubles) / Double(plateAppearances)
        let tripleProbability: Double = Double(triples) / Double(plateAppearances)
        let homeRunProbability: Double = Double(homeRuns) / Double(plateAppearances)
        let walkProbability: Double = Double(walks) / Double(plateAppearances)
        let strikeoutProbability: Double = Double(strikeouts) / Double(plateAppearances)
        let hitByPitchProbaility: Double = Double(hitByPitch) / Double(plateAppearances)
        let outProbability: Double = Double(outs) / Double(plateAppearances)
        let normalizationFactor = 1.0

        return AtBatEventProbability(single: singleProbability * normalizationFactor,
                                 double: doubleProbability * normalizationFactor,
                                 triple: tripleProbability * normalizationFactor,
                                 homeRun: homeRunProbability * normalizationFactor,
                                 walk: walkProbability * normalizationFactor,
                                 strikeOut: strikeoutProbability * normalizationFactor,
                                 hitByPitch: hitByPitchProbaility * normalizationFactor,
                                out: outProbability)
    }
}

func createLineups(filename: String, batterProjections: [String: BatterProjection], pitcherProjections: [String: PitcherProjection]) -> [Team] {

    let maxBatters = 9
    let maxPitchers = 1

    let repository = CouchManagerLeagueRespository(filename: filename)
    let auctionEntries = repository.getAuctionEntries()

    var currentTeamId: Int?
    var currentTeamName: String = ""

    let playerComparer = PlayerComparer()

    var batters = [BatterProjection]()
    var pitchers = [PitcherProjection]()

    var teams = [Team]()

    for auctionEntry in auctionEntries {
        if let unwrappedCurrentTeamId = currentTeamId,
            currentTeamId != auctionEntry.teamNumber {

            guard let startingPitcherId = pitchers.first else {
                print("Invalid lineup for team: \(String(describing: currentTeamId))")
                exit(0)
            }

            let lineup = Lineup(startingPitcherId: startingPitcherId.playerId, batterIds: batters.map { $0.playerId } )

            // create team
            let team = Team(identifier: "\(unwrappedCurrentTeamId)", name: currentTeamName, lineup: lineup)
            teams.append(team)

            // Reset counters
            batters = [BatterProjection]()
            pitchers = [PitcherProjection]()
            currentTeamId = auctionEntry.teamNumber
            currentTeamName = auctionEntry.teamName
        }

        if pitchers.count >= maxPitchers && batters.count >= maxBatters {
            continue
        }

        if batters.count < maxBatters,
            let batterProjection = batterProjections.values.first(where: {
            playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }) {
            batters.append(batterProjection)
        }

        if pitchers.count < maxPitchers,
            let pitcherProjection = pitcherProjections.values.first(where: {
                playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }) {
            pitchers.append(pitcherProjection)
        }

    }

    return teams
}

func inputHitterProjections(filename: String) -> [String: BatterProjection] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true)

    var hitterProjectionsDictionary = [String: BatterProjection]()
    while let row = csv.next() {
        guard let plateAppearances = Int(row[3]),
            let singles = Int(row[5]),
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
                                                 singles: singles,
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

func inputPitcherProjections(filename: String) -> [String: PitcherProjection] {
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

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv]",
overview: "Converts a set of hitter statistic projections and turns them into auction values")

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

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "HitterAuctionValues", format: "csv")
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

//print("totalPlateAppearances: \(totalPlateAppearances)")
//print("totalHits: \(totalHits)")
//print("totalSingles: \(totalSingles)")
//print("totalDoubles: \(totalDoubles)")
//print("totalTriples: \(totalTriples)")
//print("totalHomeruns: \(totalHomeRuns)")
//
//print("percentageOfDoubles: \(percentageOfDoubles)")
//print("percentageOfTriples: \(percentageOfTriples)")

struct ProbabilityLineupConverter {
    let pitcherDictionary: [String: PitcherProjection]
    let batterDictionary: [String: BatterProjection]

    var totalHits: Int {
        return totalSingles + totalDoubles + totalHomeRuns + totalTriples
    }

    var totalTriples: Int {
        return hitterProjections.values.map { $0.triples}.reduce(0, +)
    }

    var totalHomeRuns: Int {
        hitterProjections.values.map { $0.homeRuns}.reduce(0, +)
    }

    var totalSingles: Int {
        return batterDictionary.values.map { $0.singles }.reduce(0, +)
    }

    var totalDoubles: Int {
        return batterDictionary.values.map { $0.doubles }.reduce(0, +)
    }

    var totalHitByPitch: Int {
        return batterDictionary.values.map { $0.hitByPitch}.reduce(0, +)
    }

    var totalWalks: Int {
        return batterDictionary.values.map { $0.walks }.reduce(0, +)
    }

    var totalStrikeouts: Int {
        return batterDictionary.values.map { $0.strikeouts }.reduce(0, +)
    }

    var totalPlateAppearances: Int {
        return batterDictionary.values.map { $0.plateAppearances }.reduce(0, +)
    }

    // Out but not a strikeout
    var totalOuts: Int {
        return totalPlateAppearances - totalHits - totalWalks - totalStrikeouts - totalHitByPitch
    }

    var baseAtBatProbabilites: AtBatEventProbability {
        let baseProbabilities = AtBatEventProbability(
        single: Double(totalSingles) / Double(totalPlateAppearances),
        double: Double(totalDoubles) / Double(totalPlateAppearances),
        triple: Double(totalTriples) / Double(totalPlateAppearances),
        homeRun: Double(totalHomeRuns) / Double(totalPlateAppearances),
        walk: Double(totalWalks) / Double(totalPlateAppearances),
        strikeOut: Double(totalStrikeouts) / Double(totalPlateAppearances),
        hitByPitch: Double(totalHitByPitch) / Double(totalPlateAppearances),
        out: Double(totalOuts) / Double(totalPlateAppearances))

        return baseProbabilities
    }

    func convert(lineup: Lineup) -> TeamLineupProbabilities {
        let pitcher = pitcherDictionary[lineup.startingPitcherId]!

        let batters = lineup.batterIds.compactMap {
            batterDictionary[$0]
        }

        let doublePercentage = Double(totalDoubles) / Double(totalHits)
        let triplePercentage = Double(totalTriples) / Double(totalHits)
        let hitByPitchPercentage = Double(totalHitByPitch) / Double(totalHits)
        let pitcherProbability = PlayerProbability(playerId: pitcher.playerId, probability: pitcher.probability(doublePercentage: doublePercentage, triplePercentage: triplePercentage, hitByPitchProbability: hitByPitchPercentage))
        return TeamLineupProbabilities(
            startingPitcher: pitcherProbability,
            batters: batters.map {
                return PlayerProbability(playerId: $0.playerId, probability: $0.probability)
            })
        }
    }

let starsLineup = Lineup(startingPitcherId: "13125", //Gerrit Cole
                       batterIds: [
                        "10155", // Mike Trout
                        "11477",
                        "16505",
                        "5038",
                        "13510",
                        "17350",
                        "11493",
                        "18401",
                        "5361"
                       ])

let scrubsLineup = Lineup(startingPitcherId: "4153",
                        batterIds: [
                         "19470",
                         "19683",
                         "16424",
                         "19339",
                         "sa601536",
                         "13807",
                         "9256",
                         "19238"
                        ])


func simulateGame(homeLineup: Lineup, awayLineup: Lineup) -> GameState {
    let converter = ProbabilityLineupConverter(pitcherDictionary: pitcherProjections, batterDictionary: hitterProjections)
    let awayProbabilities = converter.convert(lineup: awayLineup)
    let homeProbabilities = converter.convert(lineup: homeLineup)

    let gameLineup = GameLineup(awayTeam: awayProbabilities, homeTeam: homeProbabilities)

    var gameState = GameState(inningCount: InningCount(frame: .top, number: 0, outs: 0), homeBattersRetired: 0, awayBattersRetired: 0)

    srand48(Int(Date().timeIntervalSince1970))

    var gameStarted = true

    repeat {

        if gameStarted {
            gameStarted = false
        } else {
            gameState.advanceFrame()
        }
        let inningResults = simulateInningFrame(lineup: gameLineup, gameState: gameState, baseProbability: converter.baseAtBatProbabilites)

        gameState = inningResults.gameState

        print("frameResult: \(gameState.inningCount.frame) \(gameState.inningCount.number + 1) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
        // print(gameState)

    } while !gameState.isEndOfGame()

    print("************************")
    print("")
    print("Game Over!")
    print("inningResult: \(gameState.inningCount.number + 1) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
    print("")
    print("************************")
    print("")
    print(gameState)

    return gameState
}


simulateGame(homeLineup: scrubsLineup, awayLineup: scrubsLineup)

let twoFiftyHitterProbability = AtBatEventProbability(single: 0.2,
                                                      double: 0.05,
                                                      triple: 0,
                                                      homeRun: 0.0,
                                                      walk: 0.0,
                                                      strikeOut: 0.0,
                                                      hitByPitch: 0.0,
                                                      out: 0.75)

let event = getAtBatEvent(pitcherProbability: twoFiftyHitterProbability, batterProbability: twoFiftyHitterProbability, baseProbability: twoFiftyHitterProbability)

//srand48(Int(Date().timeIntervalSince1970))
//
//let events: [AtBatOutcome] = (0..<10000000).map { number in
//    return getAtBatEvent(pitcherProbability: twoFiftyHitterProbability,
//                  batterProbability: twoFiftyHitterProbability,
//                  baseProbability: twoFiftyHitterProbability) }
//
//
//let singles = events.filter { $0 == .single }.count
//
//print("\(singles) singeles out of \(events.count) at bats")


//let atBats = inningResults.atBatsRecords
//let gameState = inningResults.gameState
//gameState.countScores()


//results.forEach {
//    print("\($0)")
//}

//print("results: \(results)")



//hitterProjections.prefix(upTo: 20).forEach {
//    print($0)
//    print($0.probability)
//    print("--")
//}
//
//pitcherProjections.prefix(upTo: 25).forEach {
//    print($0)
//    print($0.probability(doublePercentage: percentageOfDoubles, triplePercentage: percentageOfTriples, hitByPitchProbability: percentageOfHitByPitch))
//    print("--")
//}
