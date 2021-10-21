import Foundation
import RotoSwift

import ArgumentParser

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

struct HitterAuctionValues: ParsableCommand {
    @Argument(help: "CSV file of hitter auction values")
    var hitterAuctionFilename: String

    @Option(name: .shortAndLong, help: "CSV file to output the created auction values.")
    var outputFilename: String?

    mutating func run() throws {
        let outputFilename = outputFilename ?? defaultFilename(for: "HitterAuctionValues", format: "csv")

        runMain(hitterFilename: hitterAuctionFilename,
                outputFilename: outputFilename
        )
    }
}

HitterAuctionValues.main()

func runMain(hitterFilename: String,
             outputFilename: String) {

    convertProjectionsFileToActionValues(from: hitterFilename, to: outputFilename)
}

//let parser = ArgumentParser(commandName: "HitterAuctionValues",
//                            usage: "filename [--hitters  hitter-projections.csv --output output-auction-values-csv]",
//                            overview: "Converts a set of hitter statistic projections and turns them into auction values")
//
//let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")
//
//let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")
//
//let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
//
//let parsedArguments: SPMUtility.ArgumentParser.Result
//
//do {
//    parsedArguments = try parser.parse(arguments)
//} catch let error as ArgumentParserError {
//    print(error.description)
//    exit(0)
//} catch let error {
//    print(error.localizedDescription)
//    exit(0)
//}
//
//// Required fields
//let hitterFilename = parsedArguments.get(hitterFilenameOption)
//let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "HitterAuctionValues", format: "csv")
//
//guard let hitterFilename = hitterFilename else {
//    print("Hitter filename is required")
//    exit(0)
//}

