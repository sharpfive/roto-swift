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
        public let eligiblePositions: [RosterPosition]

        public init(name: String, eligiblePositions: [RosterPosition] = [RosterPosition]()) {
            self.name = name
            self.eligiblePositions = eligiblePositions
        }
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
        //aiai some of these are field positions
        //aiai others are roster positions IL, P, Bench
        //aiai how to split them up?
    }
}
