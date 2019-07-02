import Foundation
import RotoSwift
import SPMUtility

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

//let filename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters.csv"
//let outputFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters-auctionvalues.csv"


let parser = ArgumentParser(commandName: "HitterAuctionValues",
                            usage: "filename [--hitters  hitter-projections.csv --output output-auction-values-csv]",
                            overview: "Converts a set of hitter statistic projections and turns them into auction values")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

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
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "HitterAuctionValues", format: "csv")

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

convertProjectionsFileToActionValues(from: hitterFilename, to: outputFilename)
