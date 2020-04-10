//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 3/23/20.
//

// ex swift run GameSimulator --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv
import Foundation
import RotoSwift
import CSV
import SPMUtility
import SimulatorLib

//struct AtBatEventProbability {
//    let single: Double
//    let double: Double
//    let triple: Double
//    let homeRun: Double
//    let walk: Double
//    let strikeOut: Double
//    let hitByPitch: Double
//    let out: Double
//
//    var singleOdds: Double {
//        return odds(for: single)
//    }
//
//    var doubleOdds: Double {
//        return odds(for: double)
//    }
//
//    var tripleOdds: Double {
//        return odds(for: triple)
//    }
//
//    var homeRunOdds: Double {
//        return odds(for: homeRun)
//    }
//
//    var walkOdds: Double {
//        return odds(for: walk)
//    }
//
//    var strikeoutOdds: Double {
//        return odds(for: strikeOut)
//    }
//
//    var hitByPitchOdds: Double {
//        return odds(for: hitByPitch)
//    }
//
//    var outOdds: Double {
//        return odds(for: out)
//    }
//
//    func odds(for value: Double) -> Double {
//        return value / (1 - value)
//    }
//}

//struct PlayerProbability {
//    let playerId: String
//    let probability: AtBatEventProbability
//}
//
//struct TeamLineupProbabilities {
//    let startingPitcher: PlayerProbability
//    let batters: [PlayerProbability]
//
//    func getProbability(for battersRetired: Int) -> PlayerProbability {
//        return batters[battersRetired % 8]
//    }
//}

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

//struct GameLineup {
//    let awayTeam: TeamLineupProbabilities
//    let homeTeam: TeamLineupProbabilities
//}
//
//enum InningFrame {
//    case top
//    case bottom
//}

//struct InningCount {
//    var frame: InningFrame
//    var number: Int
//    var outs: Int
//
//    static func beginningOfGame() -> InningCount {
//        return InningCount(frame: .top, number: 0, outs: 0)
//    }
//
//    mutating func increment() {
//        switch frame {
//        case .top:
//            frame = .bottom
//
//        case .bottom:
//            frame = .top
//            number += 1
//        }
//
//        outs = 0
//    }
//}

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv --linup lineups.csv]",
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
//
//let starsLineup = Lineup(startingPitcherId: "13125", //Gerrit Cole
//                       batterIds: [
//                        "10155", // Mike Trout
//                        "11477",
//                        "16505",
//                        "5038",
//                        "13510",
//                        "17350",
//                        "11493",
//                        "18401",
//                        "5361"
//                       ])
//
//let scrubsLineup = Lineup(startingPitcherId: "4153",
//                        batterIds: [
//                         "19470",
//                         "19683",
//                         "16424",
//                         "19339",
//                         "sa601536",
//                         "13807",
//                         "9256",
//                         "19238"
//                        ])

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

let homeTeam = lineups[0]
let awayTeam = lineups[1]


print("Home Team:")
homeTeam.printToStandardOut()

print("")

print("Away Team:")
awayTeam.printToStandardOut()

let homeLineups = createLineups(for: homeTeam)
let awayLineups = createLineups(for: awayTeam)

//let gameStates = simulateGame(homeLineup: homeLineups.first!, awayLineup: awayLineups.first!)
//
//gameStates.forEach { gameState in
//    if gameState.isEndOfGame() {
//        printFinalScore(with: gameState)
//    } else {
//        printInningFrame(with: gameState)
//    }
//}

var games = [GameState]()

homeLineups.forEach { homeLineup in
    awayLineups.forEach { awayLineup in
        let gameStates = simulateGame(homeLineup: homeLineup,
                                      awayLineup: awayLineup,
                                      pitcherDictionary: pitcherProjections,
                                      batterDictionary: hitterProjections)

        if let lastState = gameStates.last {
            games.append(lastState)
        }
    }
}

games.forEach {
    printFinalScore(with: $0)
}

let homeTeamWon = games.filter { $0.totalHomeRunsScored > $0.totalAwayRunsScored }.count
let awayTeamWon = games.filter { $0.totalHomeRunsScored < $0.totalAwayRunsScored }.count


print("Home Team Won: \(homeTeamWon) games")
print("Away Team Won: \(awayTeamWon) games")

//let twoFiftyHitterProbability = AtBatEventProbability(single: 0.2,
//                                                      double: 0.05,
//                                                      triple: 0,
//                                                      homeRun: 0.0,
//                                                      walk: 0.0,
//                                                      strikeOut: 0.0,
//                                                      hitByPitch: 0.0,
//                                                      out: 0.75)
//
//let event = getAtBatEvent(pitcherProbability: twoFiftyHitterProbability, batterProbability: twoFiftyHitterProbability, baseProbability: twoFiftyHitterProbability)

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
