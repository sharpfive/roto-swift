import Foundation
import CSV
import RotoSwift
import SPMUtility

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

let parser = ArgumentParser(commandName: "PlayerRelativeValues", usage: "filename [--input Keeper-Values-2019-Sheet1.csv]", overview: "Scrapes a csv of team rosters and compares them to csv's of project Fangraphs auction values. This show the relative value of a player..")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")
let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitchers csv file.")
let auctionValuesFilenameOption = parser.add(option: "--auction", shortName: "-a", kind: String.self, usage: "Filename for the auction values file.")
let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Location of output csv")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
}
catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
}
catch let error {
    print(error.localizedDescription)
    exit(0)
}

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let auctionValuesFilename = parsedArguments.get(auctionValuesFilenameOption)

// Not a required field, will default to the current directory
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "PlayerRelativeValues", format: "csv")

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

guard let auctionValuesFilename = auctionValuesFilename else {
    print("Auction Value filename is required")
    exit(0)
}

processRelativeValues(auctionValuesFilename: auctionValuesFilename, fangraphsHitterFilename: hitterFilename, fangraphsPitcherFilename: pitcherFilename, outputFilename: outputFilename)
