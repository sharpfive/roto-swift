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

struct Batter {
    let name: String
    let homeRuns: Int
    let runs: Int
    let onBasePercentage: Double
    let stolenBases: Int
    let runsBattedIn: Int
}

struct BatterZScores {
    let name: String
    let homeRuns: Double
    let runs: Double
    let onBasePercentage: Double
    let stolenBases: Double
    let runsBattedIn: Double

    var totalZScore: Double {
        return homeRuns + runs + onBasePercentage + stolenBases + runsBattedIn
    }
}
