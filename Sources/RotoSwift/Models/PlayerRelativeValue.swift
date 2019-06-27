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
}
