import Foundation
import RotoSwift

// This will take projections and determine the best available free-agents
let hitterFilename = "/Users/jaim/Dropbox/roto/cash/streamer-projections-batters.csv"

//let hitterFilename2020 = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2020-batters-auctionvalues.csv"
//let hitterFilename2021 = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters-auctionvalues.csv"

let pitcherFilename = "/Users/jaim/Dropbox/roto/cash/streamer-projections-pitchers.csv"

var hitterValues = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename, pitcherFilename: nil)

//var hitterValuesIn2020 = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename2020, pitcherFilename: nil, csvFormat: .rotoswift)
//var hitterValuesIn2021 = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename2021, pitcherFilename: nil, csvFormat: .rotoswift)

var pitcherValues = buildPlayerAuctionValuesArray(hitterFilename: nil, pitcherFilename: pitcherFilename)


let couchManagerFilename = "/Users/jaim/Dropbox/roto/cash/2020-03-22-Auction.csv"
let couchManagerLeagueRepository = CouchManagerLeagueRespository(filename: couchManagerFilename)

let auctionEntries = couchManagerLeagueRepository.getAuctionEntries()

// print("auction Entries: \(auctionEntries)")

auctionEntries.forEach { auctionEntry in
    let fullname = auctionEntry.fullName

    let previousHitterCount = hitterValues.count
    let previousPitcherCount = pitcherValues.count

    hitterValues = hitterValues.filter {
        // very basic compare happening here
        $0.name.caseInsensitiveCompare(fullname) != .orderedSame
    }

    pitcherValues = pitcherValues.filter {
        $0.name.caseInsensitiveCompare(fullname) != .orderedSame
    }

    if hitterValues.count == previousHitterCount &&
        pitcherValues.count == previousPitcherCount {
        print("!!! can't find \(fullname)")
    }
}

var sortedHitterValues = hitterValues.sorted(by: { $0.auctionValue > $1.auctionValue })
var sortedPitcherValues = pitcherValues.sorted(by: { $0.auctionValue > $1.auctionValue })

print("Here are the best available Jitters")
sortedHitterValues.prefix(upTo: 20).forEach {
    print($0)
}

print("Here are the best available Pitchers")
sortedPitcherValues.prefix(upTo: 20).forEach {
    print($0)
}



//let totalPlayerNames = league.teams.flatMap { $0.players.map { $0.name} }
//
//// slow way to do this
//totalPlayerNames.forEach { name in
//    if let matchedHitter = sortedHitterValues.first(where: { $0.name == name } ) {
//        sortedHitterValues = sortedHitterValues.filter( { $0.name != matchedHitter.name} )
//    }
//
//    if let matchedPitcher = sortedPitcherValues.first(where: { $0.name == name } ) {
//        sortedPitcherValues = sortedPitcherValues.filter( { $0.name != matchedPitcher.name} )
//    }
//}

//struct PlayerKeeperValue {
//    let name: String
//    let value: Double
//    let nextYearValue: Double
//    let followingYearValue: Double
//
//    var totalValue: Double {
//        return value + futureValue
//    }
//
//    var futureValue: Double {
//        return nextYearValue + followingYearValue
//    }
//}
//
//struct PlayerKeeperActualValue {
//    let auctionIncrement = 5
//    let playerKeeperValue: PlayerKeeperValue
//    let currentAuctionCost: Int
//
//    var nextYearValue: Double {
//        return playerKeeperValue.nextYearValue - Double(nextYearAuctionValue)
//    }
//
//    var followingYearValue: Double {
//        return playerKeeperValue.followingYearValue - Double(followingYearAuctionValue)
//    }
//
//    var nextYearAuctionValue: Int {
//        return currentAuctionCost + auctionIncrement
//    }
//
//    var followingYearAuctionValue: Int {
//        return currentAuctionCost + auctionIncrement*2
//    }
//}
//
//print("Here are the best available hitters")

//let nextTwoYearsHitters: [PlayerKeeperValue] = sortedHitterValues.prefix(upTo: 100).map { hitter in
//    let valueIn2020 = hitterValuesIn2020.first(where: { $0.name == hitter.name })?.auctionValue ?? 0.0
//    let valueIn2021 = hitterValuesIn2021.first(where: { $0.name == hitter.name })?.auctionValue ?? 0.0
//    return PlayerKeeperValue(name: hitter.name, value: hitter.auctionValue, nextYearValue: valueIn2020, followingYearValue: valueIn2021)
//}

//nextTwoYearsHitters.sorted(by: { $0.futureValue > $1.futureValue }).forEach {
//    print("\($0) - total: \($0.totalValue) - future: \($0.futureValue)")
//}

//sortedHitterValues.prefix(upTo: 20).forEach { hitter in
//    let valueIn2020 = hitterValuesIn2020.first(where: { $0.name == hitter.name })
//    print("\(hitter) - 2020: \(valueIn2020)")
//}

//print("Here are the best available pitchers")
//sortedPitcherValues.prefix(upTo: 20).forEach {
//    print($0)
//}

// Attempt to use Set functionality, this would be OK, but we need the
//let totalPlayerNames = league.teams.flatMap { $0.players.map { $0.name} }
//let hittersNames = hitterValues.map { $0.name }
//let totalPlayersSet = Set(totalPlayerNames)
//let hittersValuesSet = Set(hittersNames)
