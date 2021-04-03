import Foundation
import CSV
import RotoSwift
import SPMUtility

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let parser = ArgumentParser(commandName: "TeamRelativeValues",
                            usage: "filename [--hitters  fangraphs-hitter-projections.csv --pitchers fangraphs-pitcher-projections.csv --auction auction-values.csv]",
                            overview: "Takes a scrape of the league rosters and adds the values for all the players on their team.")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")
let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitchers csv file.")
let auctionValuesFilenameOption = parser.add(option: "--auction", shortName: "-a", kind: String.self, usage: "Filename for the auction values file.")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
} catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
} catch let error {
    print(error.localizedDescription)
    exit(0)
}

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let auctionValuesFilename = parsedArguments.get(auctionValuesFilenameOption)

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

let estimateKeepers = true
// let rosterFile = RosterFile.CBAuctionCSV(auctionValuesFilename) Old school C&B csv file
// let rosterFile = RosterFile.ESPNScrapeCSV(auctionValuesFilename) // Scraped csv of full roster data
let rosterFile = RosterFile.FantraxRostersScrapeCSV(auctionValuesFilename)
_ = processTeamsWithRelativeValues(auctionValues: rosterFile,
                                   fangraphsHitterFilename: hitterFilename,
                                   fangraphsPitcherFilename: pitcherFilename,
                                   estimateKeepers: estimateKeepers)
