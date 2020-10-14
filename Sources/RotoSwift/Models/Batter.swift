//
//  Batter.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation

public struct Pitcher {
    public let name: String
    public let strikeouts: Int
    public let WHIP: Double
    public let ERA: Double
    public let inningsPitched: Double

    public init(name: String, strikeouts: Int, WHIP: Double, ERA: Double, inningsPitched: Double) {
        self.name = name
        self.strikeouts = strikeouts
        self.WHIP = WHIP
        self.ERA = ERA
        self.inningsPitched = inningsPitched
    }
}

public struct PitcherZScores {
    public let name: String
    public let strikeouts: Double
    public let WHIP: Double
    public let ERA: Double

    internal init(name: String, strikeouts: Double, WHIP: Double, ERA: Double) {
        self.name = name
        self.strikeouts = strikeouts
        self.WHIP = WHIP
        self.ERA = ERA
    }

    public var totalZScore: Double {
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
    public init(name: String, homeRuns: Double, runs: Double, onBasePercentage: Double, stolenBases: Double, runsBattedIn: Double, totalZScore: Double? = nil) {
        self.name = name
        self.homeRuns = homeRuns
        self.runs = runs
        self.onBasePercentage = onBasePercentage
        self.stolenBases = stolenBases
        self.runsBattedIn = runsBattedIn
        self.totalZScore = totalZScore ??
            homeRuns + runs + onBasePercentage + stolenBases + runsBattedIn
    }

    public let name: String
    public let homeRuns: Double
    public let runs: Double
    public let onBasePercentage: Double
    public let stolenBases: Double
    public let runsBattedIn: Double
    public var totalZScore: Double
}
