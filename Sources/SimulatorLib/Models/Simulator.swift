//
//  File.swift
//  
//
//  Created by Jaim Zuber on 4/5/20.
//

import Foundation
import CSV
import RotoSwift

public enum AtBatOutcome {
    case single
    case double
    case triple
    case homerun
    case walk
    case strikeout
    case hitByPitch
    case out
}

public struct AtBatRecord {
    public let batterId: String
    public let pitcherId: String
    public let result: AtBatOutcome
    public let resultingState: AtBatResultState
}

public struct GameResult {
    public let inningFrameResults: [InningFrameResult]

    public var homeScore: Int {
        guard let lastGameState = inningFrameResults.last?.gameState else {
            return 0
        }

        return lastGameState.totalHomeRunsScored
    }

    public var awayScore: Int {
        guard let lastGameState = inningFrameResults.last?.gameState else {
            return 0
        }

        return lastGameState.totalAwayRunsScored
    }
}

public struct InningFrameResult {
    public let atBatsRecords: [AtBatRecord]
    public let gameState: GameState
}

//public struct Team {
//    public let identifier: String
//    public let name: String
//    public let pitchers: [PitcherProjection]
//    public let batters: [BatterProjection]
//}

public struct PitcherProjection: FullNameHaving {
    let playerId: String
    public let fullName: String
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
public struct BatterProjection: FullNameHaving {
    public let playerId: String
    public let fullName: String
    public let plateAppearances: Int
    public let singles: Int
    public let doubles: Int
    public let triples: Int
    public let homeRuns: Int
    public let walks: Int
    public let strikeouts: Int
    public let hitByPitch: Int

    public var outs: Int {
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

public struct AtBatEventProbability {
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

public struct PlayerProbability {
    let playerId: String
    let probability: AtBatEventProbability
}

public struct TeamLineupProbabilities {
    let startingPitcher: PlayerProbability
    let batters: [PlayerProbability]

    func getProbability(for battersRetired: Int) -> PlayerProbability {
        return batters[battersRetired % 8]
    }
}

public struct Lineup {
    let startingPitcherId: String
    let batterIds: [String]
}

public struct TeamLineup {
    let identifier: String
    let name: String
    let lineup: Lineup
}

public struct Team {
    public let identifier: String
    public let name: String
    public let pitchers: [PitcherProjection]
    public let batters: [BatterProjection]
}

extension Team: Codable {}
extension Team: Hashable {}
extension PitcherProjection: Codable {}
extension PitcherProjection: Hashable {}
extension BatterProjection: Hashable {}
extension BatterProjection: Codable {}

extension Team {
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

public struct GameLineup {
    let awayTeam: TeamLineupProbabilities
    let homeTeam: TeamLineupProbabilities
}

public struct InningResult {
    let gameState: GameState
    let atbatResults: [AtBatRecord]
}

public struct BaseOccupancy {
    let firstBaseOccupant: String?
    let secondBaseOccupant: String?
    let thirdBaseOccupant: String?
}

public struct GameState {
    public var inningCount: InningCount = InningCount.beginningOfGame()
    var homeBattersRetired = 0
    var awayBattersRetired = 0

    private(set) var firstBaseOccupant: String?
    private(set) var secondBaseOccupant: String?
    private(set) var thirdBaseOccupant: String?
    private(set) var runnersScoredInFrame = 0
    private(set) var homeRunsScored = 0
    private(set) var awayRunsScored = 0

    public var totalHomeRunsScored: Int {
        if inningCount.frame == .bottom {
            return homeRunsScored + runnersScoredInFrame
        } else {
            return homeRunsScored
        }
    }

    public var totalAwayRunsScored: Int {
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
    public func isEndOfGame() -> Bool {

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

    mutating func addAtBatResult(_ atBatResult: AtBatOutcome, batterId: String) -> AtBatResultState {
        var runnersScored = [String]()

        switch atBatResult {
        case .strikeout, .out:
            recordOut()
        case .single, .hitByPitch, .walk:
            runnersScored = advanceRunners(by: 1, batterId: batterId)
        case .double:
            runnersScored = advanceRunners(by: 2, batterId: batterId)
        case .triple:
            runnersScored = advanceRunners(by: 3, batterId: batterId)
        case .homerun:
            runnersScored = advanceRunners(by: 4, batterId: batterId)
        }

        if inningCount.frame == .top {
            awayBattersRetired += 1
        } else {
            homeBattersRetired += 1
        }

        return AtBatResultState(baseOccupancy: BaseOccupancy(firstBaseOccupant: firstBaseOccupant,
                                                             secondBaseOccupant: secondBaseOccupant,
                                                             thirdBaseOccupant: thirdBaseOccupant),
                                runnersScored: runnersScored)
    }

    mutating private func recordOut() {
        inningCount.outs += 1
    }

    // returns runners scored
    mutating private func advanceRunners(by bases: Int, batterId: String) -> [String] {
        let occupantId = "-1"
        var runnersScored = [String]()

        switch bases {
        case 1:
            if let thirdBaseOccupant = thirdBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(thirdBaseOccupant)
                self.thirdBaseOccupant = nil
            }

            if let secondBaseOccupant = secondBaseOccupant {
                thirdBaseOccupant = secondBaseOccupant
            }

            if let firstBaseOccupant = firstBaseOccupant {
                secondBaseOccupant = firstBaseOccupant
            }

            firstBaseOccupant = occupantId
        case 2:
            if let thirdBaseOccupant = thirdBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(thirdBaseOccupant)
                self.thirdBaseOccupant = nil
            }

            if let secondBaseOccupant = secondBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(secondBaseOccupant)
                self.secondBaseOccupant = nil
            }

            if let firstBaseOccupant = firstBaseOccupant {
                thirdBaseOccupant = firstBaseOccupant
            }

            firstBaseOccupant = nil
            secondBaseOccupant = occupantId

        case 3:
            if let thirdBaseOccupant = thirdBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(thirdBaseOccupant)
            }

            if let secondBaseOccupant = secondBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(secondBaseOccupant)
            }

            if let firstBaseOccupant = firstBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(firstBaseOccupant)
            }

            firstBaseOccupant = nil
            secondBaseOccupant = nil
            thirdBaseOccupant = occupantId

        case 4:
            if let thirdBaseOccupant = thirdBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(thirdBaseOccupant)
            }

            if let secondBaseOccupant = secondBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(secondBaseOccupant)
            }

            if let firstBaseOccupant = firstBaseOccupant {
                runnersScoredInFrame += 1
                runnersScored.append(firstBaseOccupant)
            }

            runnersScoredInFrame += 1
            runnersScored.append(batterId)

            firstBaseOccupant = nil
            secondBaseOccupant = nil
            thirdBaseOccupant = nil

        default:
            print("advanceRunners should never get here")
        }

        return runnersScored
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

public enum InningFrame {
    case top
    case bottom
}

public struct InningCount {
    public var frame: InningFrame
    public var number: Int
    public var outs: Int

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

public struct ProbabilityLineupConverter {
    let pitcherDictionary: [String: PitcherProjection]
    let batterDictionary: [String: BatterProjection]

    public init(pitcherDictionary: [String: PitcherProjection], batterDictionary: [String: BatterProjection]) {
        self.pitcherDictionary = pitcherDictionary
        self.batterDictionary = batterDictionary
    }

    var totalHits: Int {
        return totalSingles + totalDoubles + totalHomeRuns + totalTriples
    }

    var totalTriples: Int {
        return batterDictionary.values.map { $0.triples }.reduce(0, +)
    }

    var totalHomeRuns: Int {
        batterDictionary.values.map { $0.homeRuns }.reduce(0, +)
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

    public func convert(lineup: Lineup) -> TeamLineupProbabilities {
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
