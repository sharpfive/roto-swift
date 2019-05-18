//
//  main.swift
//  RotoSwift
//
//  Created by Jaim Zuber on 5/18/19.
//
import Foundation
import CSV
import RotoSwift

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

// Terminology
// Projections:
// A csv file of projected stats for a year
//
//
// Keeper Values:
// The amount paid for a play in a year
//
// Auction Values:
// The output of this program. This program converts the projected stats into auction values
//


struct PlayerKeeperValue {
    let name: String
    let value: Double
    let nextYearValue: Double
    let followingYearValue: Double

    var totalValue: Double {
        return value + futureValue
    }

    var futureValue: Double {
        return nextYearValue + followingYearValue
    }
}

struct PlayerKeeperAuctionValue {
    let auctionIncrement = 5
    let playerKeeperValue: PlayerKeeperValue
    let currentAuctionCost: Int

    var totalRelativeValue: Double {
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

    var nextYearRelativeValue: Double {
        return playerKeeperValue.nextYearValue - Double(nextYearAuctionCost)
    }

    var followingRelativeValue: Double {
        return playerKeeperValue.followingYearValue - Double(followingYearAuctionCost)
    }

    var nextYearAuctionCost: Int {
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





let dateString = "2019-05-18"

let baseDirectoryString = "/Users/jaim/Dropbox/roto/projections/\(dateString)"
let inputDirectoryString = "\(baseDirectoryString)/input/"
let outputDirectoryString = "\(baseDirectoryString)/output/"

let keeperValuesFilenameString = "Keeper-Values-2019.csv"
let nextYearProjectionFilenameString = "Zips-projections-2020-batters.csv"
let followingYearProjectionFilenameString = "Zips-projections-2021-batters.csv"

let nextYearAuctionValuesFilenameString = "Zips-auction-values-2020-batters.csv"
let followingYearAuctionValuesFilenameString = "Zips-auction-values-2021-batters.csv"
let futureRelativeValuesFilenameString = "Zips-future-values.csv"


let keeperValuesFullPathString = inputDirectoryString + keeperValuesFilenameString
let nextYearProjectionsFullPathString = inputDirectoryString + nextYearProjectionFilenameString
let followingYearProjectionsFullPathString = inputDirectoryString + followingYearProjectionFilenameString

let nextYearAuctionValuesFullPathString = outputDirectoryString + nextYearAuctionValuesFilenameString
let followingYearAuctionValuesFullPathString = outputDirectoryString + followingYearAuctionValuesFilenameString
let futureRelativeValuesFullPathString = outputDirectoryString + futureRelativeValuesFilenameString



// Convert the projectsion to projected auction values
convertProjectionsFileToActionValues(from: nextYearProjectionsFullPathString, to: nextYearAuctionValuesFullPathString)
convertProjectionsFileToActionValues(from: followingYearProjectionsFullPathString, to: followingYearAuctionValuesFullPathString)


var nextYearHitterValues = buildPlayerAuctionValuesArray(hitterFilename: nextYearAuctionValuesFullPathString, pitcherFilename: nil, csvFormat: .rotoswift)
var followingYearHitterValues = buildPlayerAuctionValuesArray(hitterFilename: followingYearAuctionValuesFullPathString, pitcherFilename: nil, csvFormat: .rotoswift)

// Take next and following values and add them
// Note: current value is zero
let futureValueHitters: [PlayerKeeperValue] = nextYearHitterValues.map { hitter in
    let valueIn2020 = nextYearHitterValues.first(where: { $0.name == hitter.name })?.auctionValue ?? 0.0
    let valueIn2021 = followingYearHitterValues.first(where: { $0.name == hitter.name })?.auctionValue ?? 0.0
    return PlayerKeeperValue(name: hitter.name, value: 0.0, nextYearValue: valueIn2020, followingYearValue: valueIn2021)
}

// Get the list of keeper values
let auctionRepository = CBAuctionValueRepository(filename: keeperValuesFullPathString)
let keeperPrices = auctionRepository.getAuctionValues()

let rankedFutureValueHitters = futureValueHitters.sorted(by: { $0.futureValue > $1.futureValue })

let rankedFutureActualValueHitters: [PlayerKeeperAuctionValue] = rankedFutureValueHitters.map { playerKeeperValue in
    // get the future value with the auction values
    let keeperCostInfo = keeperPrices.first(where: { $0.name == playerKeeperValue.name })

    let keeperPrice: Int = keeperCostInfo?.keeperPrice ?? 0

    return PlayerKeeperAuctionValue(playerKeeperValue: playerKeeperValue, currentAuctionCost: keeperPrice)
}

let stream = OutputStream(toFileAtPath:futureRelativeValuesFullPathString, append:false)!
let csvWriter = try! CSVWriter(stream: stream)

try! csvWriter.write(row: ["name", "Total", "Cost", "Relative", "Next Year", "Next Year Rel", "Following Year", "Following YearRel"])

let rows: [[String]] = rankedFutureActualValueHitters.map { playerKeeperAuctionValue in
    let stringArray: [String] = [
        playerKeeperAuctionValue.playerKeeperValue.name,
        String(format: "%.2f", playerKeeperAuctionValue.playerKeeperValue.totalValue),
        "\(playerKeeperAuctionValue.currentAuctionCost)",
        String(format: "%.2f", playerKeeperAuctionValue.totalRelativeValue),
        String(format: "%.2f", playerKeeperAuctionValue.playerKeeperValue.nextYearValue),
        String(format: "%.2f", playerKeeperAuctionValue.nextYearRelativeValue),
        String(format: "%.2f", playerKeeperAuctionValue.playerKeeperValue.followingYearValue),
        String(format: "%.2f", playerKeeperAuctionValue.followingRelativeValue),
    ]
    return stringArray
}

rows.forEach { row in
    // output to CSV
    csvWriter.beginNewRow()
    try! csvWriter.write(row: row)
}

csvWriter.stream.close()











