import ArgumentParser
import Foundation

import RotoSwift

// swift run Drafter ~/Dropbox/roto/cash/streamer-projections-batters.csv ~/Dropbox/roto/cash/streamer-projections-pitchers.csv ~/Dropbox/roto/cash/2020/2020-03-31-Auction.csv ~/Dropbox/roto/cash/2020/2020-03-25-MiLB-Auction.csv

struct Drafter: ParsableCommand {
    @Argument(help: "CSV file of hitter projections")
    var hitterProjectionsFilename: String

    @Argument(help: "CSV file of pitcher projections")
    var pitcherProjectionsFilename: String

    @Argument(help: "Couchmanager Major League filename")
    var couchManagerFilename: String

    @Argument(help: "Couchmanager Minor League filename")
    var couchManagerMinorLeagueFilename: String

    mutating func run() throws {
        runMain(hitterFilename: hitterProjectionsFilename,
                pitcherFilename: pitcherProjectionsFilename,
                couchManagerFilename: couchManagerFilename,
                couchManagerMinorLeagueFilename: couchManagerMinorLeagueFilename)
    }
}

Drafter.main()

func runMain(hitterFilename: String,
             pitcherFilename: String,
             couchManagerFilename: String,
             couchManagerMinorLeagueFilename: String) {

    // This will take projections and determine the best available free-agents
    var hitterValues = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename, pitcherFilename: nil)

    var pitcherValues = buildPlayerAuctionValuesArray(hitterFilename: nil, pitcherFilename: pitcherFilename)

    let couchManagerLeagueRepository = CouchManagerLeagueRespository(filename: couchManagerFilename)
    let couchManagerMinorLeagueRepository = CouchManagerLeagueRespository(filename: couchManagerMinorLeagueFilename
    )
    let auctionEntries = couchManagerLeagueRepository.getAuctionEntries()
    let minorLeagueAuctionEntries = couchManagerMinorLeagueRepository.getAuctionEntries()

    let playerComparer = PlayerComparer()

    auctionEntries.forEach { auctionEntry in
        let previousHitterCount = hitterValues.count
        let previousPitcherCount = pitcherValues.count

        hitterValues = hitterValues.filter {
            return !playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }

        pitcherValues = pitcherValues.filter {
           return !playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }

        if hitterValues.count == previousHitterCount &&
            pitcherValues.count == previousPitcherCount {
            print("!!! can't find \(auctionEntry.fullName)")
        }
    }

    minorLeagueAuctionEntries.forEach { auctionEntry in
        hitterValues = hitterValues.filter {
            return !playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }

        pitcherValues = pitcherValues.filter {
            return !playerComparer.isSamePlayer(playerOne: auctionEntry, playerTwo: $0)
        }
    }

    var sortedHitterValues = hitterValues.sorted(by: { $0.auctionValue > $1.auctionValue })
    var sortedPitcherValues = pitcherValues.sorted(by: { $0.auctionValue > $1.auctionValue })

    print("Here are the best available Hitters")
    sortedHitterValues.prefix(upTo: 30).forEach {
        print($0)
    }

    print("Here are the best available Pitchers")
    sortedPitcherValues.prefix(upTo: 30).forEach {
        print($0)
    }
}
