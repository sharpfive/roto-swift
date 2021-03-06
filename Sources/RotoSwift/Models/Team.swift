//
//  Team.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/19/18.
//

import Foundation

public struct Team {
    public let name: String
    public let players: [PlayerKeeperPrice]
}

public struct TeamPlayerRelativeValue {
    let name: String
    let players: [PlayerRelativeValue]
}
