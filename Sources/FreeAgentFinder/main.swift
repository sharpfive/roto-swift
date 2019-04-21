
import Foundation
import RotoSwift

// This will take projections and determine the best available free-agents

let hitterFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-auctionvalues-batters.csv"

let hitterFilename2020 = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2020-batters-auctionvalues.csv"


let pitcherFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-auctionvalues-pitchers.csv"
let rosterFilename = "/Users/jaim/Dropbox/roto/2019/rosters/ESPN-2019-04-20.txt"

var hitterValues = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename, pitcherFilename: nil)
var hitterValuesIn2020 = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename2020, pitcherFilename: nil, csvFormat: .rotoswift)
var pitcherValues = buildPlayerAuctionValuesArray(hitterFilename: nil, pitcherFilename: pitcherFilename)
let league = buildLeague(with: rosterFilename)

var sortedHitterValues = hitterValues.sorted(by: { $0.auctionValue > $1.auctionValue })
var sortedPitcherValues = pitcherValues.sorted(by: { $0.auctionValue > $1.auctionValue })


let totalPlayerNames = league.teams.flatMap { $0.players.map { $0.name} }

// slow way to do this
totalPlayerNames.forEach { name in
    if let matchedHitter = sortedHitterValues.first(where: { $0.name == name } ) {
        sortedHitterValues = sortedHitterValues.filter( { $0.name != matchedHitter.name} )
    }

    if let matchedPitcher = sortedPitcherValues.first(where: { $0.name == name } ) {
        sortedPitcherValues = sortedPitcherValues.filter( { $0.name != matchedPitcher.name} )
    }
}

//print("totalPLayerNames: \(totalPlayerNames)")
print("Here are the best available hitters")
sortedHitterValues.prefix(upTo: 20).forEach { hitter in
    let valueIn2020 = hitterValuesIn2020.first(where: { $0.name == hitter.name })
    print("\(hitter) - 2020: \(valueIn2020)")
}

print("Here are the best available pitchers")
sortedPitcherValues.prefix(upTo: 20).forEach {
    print($0)
}

// Attempt to use Set functionality, this would be OK, but we need the
//let totalPlayerNames = league.teams.flatMap { $0.players.map { $0.name} }
//let hittersNames = hitterValues.map { $0.name }
//let totalPlayersSet = Set(totalPlayerNames)
//let hittersValuesSet = Set(hittersNames)







