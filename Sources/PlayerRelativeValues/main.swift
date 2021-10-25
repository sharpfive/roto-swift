import Foundation
import CSV
import RotoSwift

import ArgumentParser

struct PlayerRelativeValuesCommand: ParsableCommand {
    @Argument(help: "CSV file of hitter auction values")
    var hitterAuctionValuesFilename: String

    @Argument(help: "CSV file of pitcher auction values")
    var pitcherAcutionValuesFilename: String

    @Argument(help: "Filename for actual auction values for the league")
    var leagueAuctionValuesFilename: String

    @Option(name: .shortAndLong, help: "CSV file to output the created auction values.")
    var outputFilename: String = defaultFilename(for: "PlayerRelativeValues", format: "csv")

    mutating func run() throws {
        processRelativeValues(auctionValuesFilename: leagueAuctionValuesFilename,
                              fangraphsHitterFilename: hitterAuctionValuesFilename,
                              fangraphsPitcherFilename: pitcherAcutionValuesFilename,
                              outputFilename: outputFilename)

    }
}

func processRelativeValues(auctionValuesFilename: String, fangraphsHitterFilename: String, fangraphsPitcherFilename: String, outputFilename: String) {
    let auctionRepository = CBAuctionValueRepository(filename: auctionValuesFilename)
    let keeperValues = auctionRepository.getAuctionValues()

    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterFilename, pitcherFilename: fangraphsPitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()

    let playerRelativeValues = joinRelativeValues(playerKeeperPrices: keeperValues, playerAuctions: projectedValues)

    // Output to csv
    let stream = OutputStream(toFileAtPath: outputFilename, append: false)!
    let csvWriter = try! CSVWriter(stream: stream)

    try! csvWriter.write(row: ["name", "keeperPrice", "projectedAuctionValue", "relativeValue"])

    playerRelativeValues.sorted(by: { $0.relativeValue > $1.relativeValue }).forEach { playerRelativeValue in

        // output to CSV
        csvWriter.beginNewRow()
        try! csvWriter.write(row: [
            playerRelativeValue.name,
            String(playerRelativeValue.keeperPrice),
            String(playerRelativeValue.projectedAuctionValue),
            String(playerRelativeValue.relativeValue)
            ])
    }

    csvWriter.stream.close()
}
