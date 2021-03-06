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
// The amount paid for a player in a year
//
// Auction Values:
// The output of this program. This program converts the projected stats into auction values
//

let dateString = "2021-03-21"

let baseDirectoryString = "/Users/jaim/Dropbox/roto/projections/\(dateString)"
let inputDirectoryString = "\(baseDirectoryString)/input/"
let outputDirectoryString = "\(baseDirectoryString)/output/"

let keeperValuesFilenameString = "Keeper-Values-2021.csv"
let nextYearProjectionFilenameString = "Zips-projections-2022-batters.csv"
let followingYearProjectionFilenameString = "Zips-projections-2023-batters.csv"

let nextYearAuctionValuesFilenameString = "Zips-auction-values-2022-batters.csv"
let followingYearAuctionValuesFilenameString = "Zips-auction-values-2023-batters.csv"
let futureRelativeValuesFilenameString = "Zips-future-values.csv"

let keeperValuesFullPathString = inputDirectoryString + keeperValuesFilenameString
let nextYearProjectionsFullPathString = inputDirectoryString + nextYearProjectionFilenameString
let followingYearProjectionsFullPathString = inputDirectoryString + followingYearProjectionFilenameString

let nextYearAuctionValuesFullPathString = outputDirectoryString + nextYearAuctionValuesFilenameString
let followingYearAuctionValuesFullPathString = outputDirectoryString + followingYearAuctionValuesFilenameString
let futureRelativeValuesFullPathString = outputDirectoryString + futureRelativeValuesFilenameString

// Convert the projections to projected auction values
convertProjectionsFileToActionValues(from: nextYearProjectionsFullPathString, to: nextYearAuctionValuesFullPathString)
convertProjectionsFileToActionValues(from: followingYearProjectionsFullPathString, to: followingYearAuctionValuesFullPathString)

var nextYearHitterValues = buildPlayerAuctionValuesArray(hitterFilename: nextYearAuctionValuesFullPathString, pitcherFilename: nil, csvFormat: .rotoswift)
var followingYearHitterValues = buildPlayerAuctionValuesArray(hitterFilename: followingYearAuctionValuesFullPathString, pitcherFilename: nil, csvFormat: .rotoswift)

// Take next and following values and add them
// Note: current value is zero
let futureValueHitters: [PlayerKeeperValue] = nextYearHitterValues.map { hitter in
    let valueIn2020 = nextYearHitterValues.first(where: { $0.fullName == hitter.fullName })?.auctionValue ?? 0.0
    let valueIn2021 = followingYearHitterValues.first(where: { $0.fullName == hitter.fullName })?.auctionValue ?? 0.0
    return PlayerKeeperValue(name: hitter.fullName, currentValue: 0.0, nextYearValue: valueIn2020, followingYearValue: valueIn2021)
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

let stream = OutputStream(toFileAtPath: futureRelativeValuesFullPathString, append: false)!
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
        String(format: "%.2f", playerKeeperAuctionValue.followingRelativeValue)
    ]
    return stringArray
}

rows.forEach { row in
    // output to CSV
    csvWriter.beginNewRow()
    try! csvWriter.write(row: row)
}

csvWriter.stream.close()
