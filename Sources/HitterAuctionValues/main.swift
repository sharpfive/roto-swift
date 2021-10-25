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
