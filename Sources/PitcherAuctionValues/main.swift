import Foundation
import RotoSwift
import SPMUtility

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let parser = ArgumentParser(commandName: "PitcherAuctionValues",
                            usage: "filename [--pitchers  pitching-projections.csv --output output-auction-values-csv]",
                            overview: "Converts a set of pitching statistic projections and turns them into auction values")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")

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
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "PitcherAuctionValues", format: "csv")

guard let pitcherFilename = pitcherFilename else {
    print("Hitter filename is required")
    exit(0)
}

convertPitcherProjectionsFileToActionValues(from: pitcherFilename, to: outputFilename)
