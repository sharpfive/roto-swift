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
        public let eligiblePositions: [Position]

        public init(name: String, eligiblePositions: [Position] = [Position]()) { //aiai
            self.name = name
            self.eligiblePositions = eligiblePositions
        }
    }

    public enum Position : String {
        case Catcher = "C"
        case FirstBase = "1B"
        case SecondBase = "2B"
        case ThirdBase = "3B"
        case ShortStop = "SS"
        case Outfield = "OF"
        case StartingPitcher = "SP"
        case ReliefPitcher = "RP"
        case Bench = "Bench"
        case Utility = "UTIL"
        case DH = "DH"
        case Pitcher = "P"
        case Injured = "IL"
        //aiai some of these are field positions
        //aiai others are roster positions IL, P, Bench
        //aiai how to split them up?
    }
}
