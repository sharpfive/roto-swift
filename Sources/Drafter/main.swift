import Foundation
import RotoSwift

// This will take projections and determine the best available free-agents
let hitterFilename = "/Users/jaim/Dropbox/roto/cash/streamer-projections-batters.csv"

let pitcherFilename = "/Users/jaim/Dropbox/roto/cash/streamer-projections-pitchers.csv"

var hitterValues = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename, pitcherFilename: nil)

var pitcherValues = buildPlayerAuctionValuesArray(hitterFilename: nil, pitcherFilename: pitcherFilename)


let couchManagerFilename = "/Users/jaim/Dropbox/roto/cash/2020-03-31-Auction.csv"
let couchManagerMinorLeagueFilename = "/Users/jaim/Dropbox/roto/cash/2020-03-25-MiLB-Auction.csv"
let couchManagerLeagueRepository = CouchManagerLeagueRespository(filename: couchManagerFilename)
let couchManagerMinorLeagueRepository = CouchManagerLeagueRespository(filename: couchManagerMinorLeagueFilename
)
let auctionEntries = couchManagerLeagueRepository.getAuctionEntries()
let minorLeagueAuctionEntries = couchManagerMinorLeagueRepository.getAuctionEntries()

auctionEntries.forEach { auctionEntry in
    let fullname = auctionEntry.fullName.trimmingCharacters(in: CharacterSet(charactersIn: "."))

    let previousHitterCount = hitterValues.count
    let previousPitcherCount = pitcherValues.count

    hitterValues = hitterValues.filter {
        // very basic compare happening here
        let trimmedName = $0.name.trimmingCharacters(in: CharacterSet(charactersIn: "."))

        return trimmedName.caseInsensitiveCompare(fullname) != .orderedSame
    }

    pitcherValues = pitcherValues.filter {
        $0.name.caseInsensitiveCompare(fullname) != .orderedSame
    }

    if hitterValues.count == previousHitterCount &&
        pitcherValues.count == previousPitcherCount {
        print("!!! can't find \(fullname)")
    }
}

minorLeagueAuctionEntries.forEach { auctionEntry in
    let fullname = auctionEntry.fullName.trimmingCharacters(in: CharacterSet(charactersIn: "."))

//    let previousHitterCount = hitterValues.count
//    let previousPitcherCount = pitcherValues.count

    hitterValues = hitterValues.filter {
        // very basic compare happening here
        let trimmedName = $0.name.trimmingCharacters(in: CharacterSet(charactersIn: "."))

        return trimmedName.caseInsensitiveCompare(fullname) != .orderedSame
    }

    pitcherValues = pitcherValues.filter {
        $0.name.caseInsensitiveCompare(fullname) != .orderedSame
    }

//    if hitterValues.count == previousHitterCount &&
//        pitcherValues.count == previousPitcherCount {
//        print("!!! can't find \(fullname)")
//    }
}

var sortedHitterValues = hitterValues.sorted(by: { $0.auctionValue > $1.auctionValue })
var sortedPitcherValues = pitcherValues.sorted(by: { $0.auctionValue > $1.auctionValue })

print("Here are the best available Jitters")
sortedHitterValues.prefix(upTo: 30).forEach {
    print($0)
}

print("Here are the best available Pitchers")
sortedPitcherValues.prefix(upTo: 30).forEach {
    print($0)
}
