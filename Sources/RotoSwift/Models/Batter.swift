//
//  Batter.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation

struct Pitcher {
    let name: String
    let strikeouts: Int
    let WHIP: Double
    let ERA: Double
    let inningsPitched: Double
}

struct PitcherZScores {
    let name: String
    let strikeouts: Double
    let WHIP: Double
    let ERA: Double

    var totalZScore: Double {
        return strikeouts + WHIP + ERA
    }
}

public struct Batter {
    public let name: String
    public let homeRuns: Int
    public let runs: Int
    public let onBasePercentage: Double
    public let stolenBases: Int
    public let runsBattedIn: Int
}

public struct BatterZScores {
    public let name: String
    public let homeRuns: Double
    public let runs: Double
    public let onBasePercentage: Double
    public let stolenBases: Double
    public let runsBattedIn: Double

    public var totalZScore: Double {
        return homeRuns + runs + onBasePercentage + stolenBases + runsBattedIn
    }
}
