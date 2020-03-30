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

struct GameLineup {
    let awayTeam: TeamLineupProbabilities
    let homeTeam: TeamLineupProbabilities
}

struct GameState {
    var inningCount: InningCount = InningCount.beginningOfGame()
    var homeBattersRetired = 0
    var awayBattersRetired = 0
//    var homeTeamRunsThisInning = 0
//    var awayTeamRunsThisInning = 0

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
            return false
        }

        if inningCount.number < 8 {
            return false
        }

        var totalHomeRunsScored = homeRunsScored
        var totalAwayRunsScored = awayRunsScored

        if inningCount.number == 8 {
            if inningCount.frame == .top {
                totalAwayRunsScored += runnersScoredInFrame
            } else {
                totalHomeRunsScored += runnersScoredInFrame
            }

            if inningCount.frame == .top {
                // 9th inning, top is complete and home team has lead
                if totalHomeRunsScored > totalAwayRunsScored {
                    return true
                } else {
                    return false
                }
            }
        }

        // Score is tied at the end of the inning
        if totalHomeRunsScored == totalAwayRunsScored {
            return false
        }

        // Game is over!
        return true
    }

    mutating func countScores() {
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

    let singleOdds = batterProbability.singleOdds * pitcherProbability.singleOdds / baseProbability.singleOdds
    let doubleOdds = batterProbability.doubleOdds * pitcherProbability.doubleOdds / baseProbability.doubleOdds
    let tripleOdds = batterProbability.tripleOdds * pitcherProbability.tripleOdds / baseProbability.tripleOdds
    let homeRunOdds = batterProbability.homeRunOdds * pitcherProbability.homeRunOdds / baseProbability.homeRunOdds
    let hitByPitchOdds = batterProbability.hitByPitchOdds * pitcherProbability.hitByPitchOdds / baseProbability.hitByPitchOdds
    let walkOdds = batterProbability.walkOdds * pitcherProbability.walkOdds / baseProbability.walkOdds
    let strikeoutOdds = batterProbability.strikeoutOdds * pitcherProbability.strikeoutOdds / baseProbability.strikeoutOdds

    var weights: [(outcome: AtBatOutcome, weight: Double)] = [
        (outcome: .single, weight: singleOdds),
        (outcome: .double, weight: doubleOdds),
        (outcome: .triple, weight: tripleOdds),
        (outcome: .homerun, weight: homeRunOdds),
        (outcome: .hitByPitch, weight: hitByPitchOdds),
        (outcome: .walk, weight: walkOdds),
        (outcome: .strikeout, weight: strikeoutOdds)
    ]

    // If it's not not an out, it's an out.
    let outOdds = 1 - weights.map{ $0.weight }.reduce(0,+)

    weights.append( (outcome: .out, weight: outOdds) )

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
        return .out
    }
}

struct PitcherProjection {
    let playerId: String
    let name: String
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

        return AtBatEventProbability(single: singleProbability, double: doubleProbability, triple: tripleProbability, homeRun: homeRunProbability, walk: walkProbability, strikeOut: strikeoutProbability, hitByPitch: hitByPitchProbability)
    }
}

// Read in batter stats file
struct BatterProjection {
    let playerId: String
    let name: String
    let plateAppearances: Int
    let singles: Int
    let doubles: Int
    let triples: Int
    let homeRuns: Int
    let walks: Int
    let strikeouts: Int
    let hitByPitch: Int

    var probability: AtBatEventProbability {
        let singleProbability: Double = Double(singles) / Double(plateAppearances)
        let doubleProbability: Double = Double(doubles) / Double(plateAppearances)
        let tripleProbability: Double = Double(triples) / Double(plateAppearances)
        let homeRunProbability: Double = Double(homeRuns) / Double(plateAppearances)
        let walkProbability: Double = Double(walks) / Double(plateAppearances)
        let strikeoutProbability: Double = Double(strikeouts) / Double(plateAppearances)
        let hitByPitchProbaility: Double = Double(hitByPitch) / Double(plateAppearances)

        let normalizationFactor = 1.0

        return AtBatEventProbability(single: singleProbability * normalizationFactor,
                                 double: doubleProbability * normalizationFactor,
                                 triple: tripleProbability * normalizationFactor,
                                 homeRun: homeRunProbability * normalizationFactor,
                                 walk: walkProbability * normalizationFactor,
                                 strikeOut: strikeoutProbability * normalizationFactor,
                                 hitByPitch: hitByPitchProbaility * normalizationFactor)
    }
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
                                                 name: playerName,
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
                                                  name: playerName,
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

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

let hitterProjections = inputHitterProjections(filename: hitterFilename)
let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)

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

print("totalPlateAppearances: \(totalPlateAppearances)")
print("totalHits: \(totalHits)")
print("totalSingles: \(totalSingles)")
print("totalDoubles: \(totalDoubles)")
print("totalTriples: \(totalTriples)")
print("totalHomeruns: \(totalHomeRuns)")

print("percentageOfDoubles: \(percentageOfDoubles)")
print("percentageOfTriples: \(percentageOfTriples)")


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

    var baseAtBatProbabilites: AtBatEventProbability {
        let baseProbabilities = AtBatEventProbability(
        single: Double(totalSingles) / Double(totalPlateAppearances),
        double: Double(totalDoubles) / Double(totalPlateAppearances),
        triple: Double(totalTriples) / Double(totalPlateAppearances),
        homeRun: Double(totalHomeRuns) / Double(totalPlateAppearances),
        walk: Double(totalWalks) / Double(totalPlateAppearances),
        strikeOut: Double(totalStrikeouts) / Double(totalPlateAppearances),
        hitByPitch: Double(totalHitByPitch) / Double(totalPlateAppearances))

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

let converter = ProbabilityLineupConverter(pitcherDictionary: pitcherProjections, batterDictionary: hitterProjections)
let scrubsProbabilities = converter.convert(lineup: starsLineup)
let starsProbabilities = converter.convert(lineup: starsLineup)

let gameLineup = GameLineup(awayTeam: scrubsProbabilities, homeTeam: starsProbabilities)

//print("scrubs: \(scrubsProbabilities)")
//
//print("stars: \(starsProbabilities)")

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

    // if gameState.isEndOfInning() {
    print("frameResult: \(gameState.inningCount.frame) \(gameState.inningCount.number) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
    // }
} while !gameState.isEndOfGame()

//let atBats = inningResults.atBatsRecords
//let gameState = inningResults.gameState
gameState.countScores()

print("************************")
print("")
print("Game Over!")
print("inningResult: \(gameState.inningCount.number) - Away: \(gameState.totalAwayRunsScored) - Home: \(gameState.totalHomeRunsScored)")
print("")
print("************************")
print("")
print(gameState)

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
