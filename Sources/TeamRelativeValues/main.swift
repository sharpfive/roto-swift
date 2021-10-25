import Foundation
import CSV
import RotoSwift

import ArgumentParser


#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

struct TeamRelativeValuesCommand: ParsableCommand {
    @Argument(help: "CSV file of hitter auction values")
    var hitterAuctionValuesFilename: String

    @Argument(help: "CSV file of pitcher auction values")
    var pitcherAuctionValuesFilename: String

    @Argument(help: "json file with league auction data")
    var auctionFilename: String

    mutating func run() throws {
        try runMain(hitterFilename: hitterAuctionValuesFilename,
                pitcherFilename: pitcherAuctionValuesFilename,
                    auctionValuesFilename: auctionFilename)
    }
}

TeamRelativeValuesCommand.main()


func runMain(hitterFilename: String,
             pitcherFilename: String,
             auctionValuesFilename: String) throws {
    let estimateKeepers = true
    // let rosterFile = RosterFile.CBAuctionCSV(auctionValuesFilename) Old school C&B csv file
    // let rosterFile = RosterFile.ESPNScrapeCSV(auctionValuesFilename) // Scraped csv of full roster data
    // let rosterFile = RosterFile.FantraxRostersScrapeCSV(auctionValuesFilename)
    let rosterFile = RosterFile.YahooRostersScrapeCSV(auctionValuesFilename)
    _ = processTeamsWithRelativeValues(rosterFile: rosterFile,
                                       fangraphsHitterFilename: hitterFilename,
                                       fangraphsPitcherFilename: pitcherFilename,
                                       estimateKeepers: estimateKeepers)


}
