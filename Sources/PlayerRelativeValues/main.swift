import Foundation
import CSV
import RotoSwift
import SPMUtility

func processRelativeValues(cbPathString: String, fangraphsHitterPathString: String, fangraphsPitcherPathString: String, outputPathString: String) {
    let auctionRepository = CBAuctionValueRepository(filename: cbPathString)
    let keeperValues = auctionRepository.getAuctionValues()

    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterPathString, pitcherFilename: fangraphsPitcherPathString)
    let projectedValues = fangraphsRepository.getAuctionValues()

    let playerRelativeValues = joinRelativeValues(playerKeeperPrices: keeperValues, playerAuctions: projectedValues)

    // Output to csv
    let stream = OutputStream(toFileAtPath: outputPathString, append: false)!
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

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
struct PlayerRelativeValuesFields {
    let hitterFilename: String?
    let pitcherFilename: String?
    let keeperValuesFilename: String
}

//func processArguments(arguments: ArgumentParser.Result) -> PlayerRelativeValuesFields? {
//
//}

print("PlayerRelativeValues")

let parser = ArgumentParser(commandName: "PlayerRelativeValues", usage: "filename [--input Keeper-Values-2019-Sheet1.csv]", overview: "Scrapes a csv of team rosters and compares them to csv's of project Fangraphs auction values. This show the relative value of a player..")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")
let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitchers csv file.")
let auctionValuesFilenameOption = parser.add(option: "--auction", shortName: "-a", kind: String.self, usage: "Filename for the auction values file.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Location of output csv")

let argumentArray = [
    hitterFilenameOption,
    pitcherFilenameOption,
    auctionValuesFilenameOption
]

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

let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let auctionValuesFilename = parsedArguments.get(auctionValuesFilenameOption)

let dateString = Date().toString(dateFormat: "yyyy-MM-dd-HH:mm:ss")

let outputFilename = parsedArguments.get(outputFilenameOption) ?? "\(FileManager.default.currentDirectoryPath)-\(dateString)-relative-values-2018.csv"

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

//let fangraphsHitterFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-batters-2019-03-16.csv"
//let fangraphsHitterFilename: OptionArgument<String> = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")

//let fangraphsPitcherFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-pitchers-2019-03-16.csv"


let outputFile = "/Users/jaim/Dropbox/roto/2019/projections/\(dateString)-relative-values-2018.csv"


processRelativeValues(cbPathString: auctionValuesFilename, fangraphsHitterPathString: hitterFilename, fangraphsPitcherPathString: pitcherFilename, outputPathString: outputFile)
