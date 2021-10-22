import Foundation
import RotoSwift
import ArgumentParser

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

struct PitcherAuctionValues: ParsableCommand {
    @Argument(help: "CSV file of pitcher auction values")
    var pitcherAuctionFilename: String

    @Option(name: .shortAndLong, help: "CSV file to output the created auction values.")
    var outputFilename: String?

    mutating func run() throws {
        runMain(pitcherFilename: pitcherAuctionFilename,
                outputFilename: outputFilename ?? defaultFilename(for: "PitcherAuctionValues", format: "csv")
        )
    }
}

PitcherAuctionValues.main()

func runMain(pitcherFilename: String,
             outputFilename: String) {

    convertProjectionsFileToActionValues(from: pitcherFilename, to: outputFilename)
}
