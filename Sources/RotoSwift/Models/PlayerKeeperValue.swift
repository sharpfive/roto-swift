//
//  PlayerKeeperValue.swift
//  CSV
//
//  Created by Jaim Zuber on 5/19/19.
//

import Foundation

public struct PlayerKeeperValue {
    public let name: String
    public let currentValue: Double
    public let nextYearValue: Double
    public let followingYearValue: Double

    public init(name: String, currentValue: Double, nextYearValue: Double, followingYearValue: Double) {
        self.name = name
        self.currentValue = currentValue
        self.nextYearValue = nextYearValue
        self.followingYearValue = followingYearValue
    }

    public var totalValue: Double {
        return currentValue + futureValue
    }

    public var futureValue: Double {
        return nextYearValue + followingYearValue
    }
}
