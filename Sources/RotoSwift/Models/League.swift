//
//  League.swift
//  RotoSwiftPackageDescription
//
//  Created by Jaim Zuber on 3/4/18.
//

import Foundation

public struct League {

    public let teams: [Team]

    public struct Team {
        public let name: String
        public let players: [Player]
    }

    public struct Player {
        public let name: String
        public let eligiblePositions: [FieldPosition]

        public init(name: String, eligiblePositions: [FieldPosition] = [FieldPosition]()) {
            self.name = name
            self.eligiblePositions = eligiblePositions
        }
    }

    public enum FieldPosition: String {
        case catcher = "C"
        case firstBase = "1B"
        case secondBase = "2B"
        case thirdBase = "3B"
        case shortStop = "SS"
        case outfield = "OF"
        case startingPitcher = "SP"
        case reliefPitcher = "RP"
        case designatedHitter = "DH"
    }

    public enum RosterPosition: String {
        case catcher = "C"
        case firstBase = "1B"
        case secondBase = "2B"
        case thirdBase = "3B"
        case shortStop = "SS"
        case outfield = "OF"
        case startingPitcher = "SP"
        case reliefPitcher = "RP"
        case bench = "Bench"
        case utility = "UTIL"
        case designatedHitter = "DH"
        case pitcher = "P"
        case injured = "IL"
    }
}
