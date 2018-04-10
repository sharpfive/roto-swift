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
        
        public init(name: String) {
            self.name = name
        }
//        let positions: [Position]
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
    }
}