//
//  PlayerRelativeValue.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation

public struct PlayerRelativeValue {
    public let name: String
    public let keeperPrice: Int
    public let projectedAuctionValue: Double

    public var relativeValue: Double {
        return projectedAuctionValue - (Double(keeperPrice))
    }

    public var effectiveValue: Double {
        return projectedAuctionValue + relativeValue
    }

    public var halfValue: Double {
    	return projectedAuctionValue / 2.0 + relativeValue
    }

    public var preDraftPowerRanking: Double {
    	return projectedAuctionValue + relativeValue * 2.0
    	// if relativeValue > 0.0 {
    	// 	return projectedAuctionValue + relativeValue
    	// } else {
    	// 	return projectedAuctionValue + relativeValue * 3.0
    	// }
    }
}
