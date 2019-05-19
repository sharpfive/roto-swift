//
//  PlayerKeeperAuctionValue.swift
//  CSV
//
//  Created by Jaim Zuber on 5/19/19.
//

import Foundation

public struct PlayerKeeperAuctionValue {
    let auctionIncrement = 5
    public let playerKeeperValue: PlayerKeeperValue
    public let currentAuctionCost: Int

    public init(playerKeeperValue: PlayerKeeperValue, currentAuctionCost: Int) {
        self.playerKeeperValue = playerKeeperValue
        self.currentAuctionCost = currentAuctionCost
    }

    public var totalRelativeValue: Double {
        if currentAuctionCost == 0 {
            // Max value from either year
            let eitherYearValue = max(playerKeeperValue.nextYearValue, playerKeeperValue.followingYearValue)

            // Player is kept the first year
            let firstYearKeptValue = playerKeeperValue.nextYearValue + playerKeeperValue.followingYearValue - 1.0

            return max(eitherYearValue, firstYearKeptValue)
        } else {
            return max(nextYearRelativeValue + followingRelativeValue, nextYearRelativeValue)
        }
    }

    public var nextYearRelativeValue: Double {
        return playerKeeperValue.nextYearValue - Double(nextYearAuctionCost)
    }

    public var followingRelativeValue: Double {
        return playerKeeperValue.followingYearValue - Double(followingYearAuctionCost)
    }

    public var nextYearAuctionCost: Int {
        if currentAuctionCost == 0 {
            return 0
        }
        return currentAuctionCost + auctionIncrement
    }

    var followingYearAuctionCost: Int {
        if currentAuctionCost == 0 {
            return 0
        }

        return currentAuctionCost + auctionIncrement*2
    }
}
