import Foundation
import RotoSwift

enum RuleFormat {
    case singleYear
    case threeYearAuction
}

let ruleFormat = RuleFormat.singleYear
let csvFormat = CSVFormat.fangraphs

// This will take projections and determine the best available free-agents
//let hitterFilename = "/Users/jaim/Dropbox/roto/C&B/2021/projections/2021-04-10/FanGraphs Leaderboard Batters.csv"
let hitterFilename = "/Users/jaim/Dropbox/roto/cash/2021/projections/2021-04-12/FanGraphs Leaderboard Batters.csv"


let hitterFilenameNextYear: String?
let hitterFilenameFollowingYear: String?

if case .threeYearAuction = ruleFormat {
    hitterFilenameNextYear = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2020-batters-auctionvalues.csv"
    hitterFilenameFollowingYear = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters-auctionvalues.csv"
} else {
    hitterFilenameNextYear = nil
    hitterFilenameFollowingYear = nil
}

//let pitcherFilename = "/Users/jaim/Dropbox/roto/C&B/2021/projections/2021-04-10/FanGraphs Leaderboard Pitchers.csv"
let pitcherFilename = "/Users/jaim/Dropbox/roto/cash/2021/projections/2021-04-12/FanGraphs Leaderboard Pitchers.csv"

//let rosterFilename = "/Users/jaim/Dropbox/roto/C&B/2021/rosters/2021-04-10-ESPN_Baseball_Rosters2__629542443.csv"
let rosterFilename = "/Users/jaim/Dropbox/roto/cash/2021/Fantrax_Rosters__982415678-2021-04-12_Team_Names.csv"


let hitterValues = buildPlayerAuctionValuesArray(hitterFilename: hitterFilename, pitcherFilename: nil)

let hitterValuesNextYear: [PlayerAuction]?
let hitterValuesFollowingYear: [PlayerAuction]?

if case .threeYearAuction = ruleFormat {
    hitterValuesNextYear = buildPlayerAuctionValuesArray(hitterFilename: hitterFilenameNextYear, pitcherFilename: nil, csvFormat: csvFormat)
    hitterValuesFollowingYear = buildPlayerAuctionValuesArray(hitterFilename: hitterFilenameFollowingYear, pitcherFilename: nil, csvFormat: csvFormat)
} else {
    hitterValuesNextYear = nil
    hitterValuesFollowingYear = nil
}

var pitcherValues = buildPlayerAuctionValuesArray(hitterFilename: nil, pitcherFilename: pitcherFilename)
let league = buildLeague(with: rosterFilename)

let rosterFile = RosterFile.FantraxRostersScrapeCSV(rosterFilename) // RosterFile.ESPNScrapeCSV(rosterFilename)

let teams = buildTeams(from: rosterFile)

var sortedHitterValues = hitterValues.sorted(by: { $0.auctionValue > $1.auctionValue })
var sortedPitcherValues = pitcherValues.sorted(by: { $0.auctionValue > $1.auctionValue })

let playerComparer = PlayerComparer()

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

struct PlayerKeeperValue {
    let name: String
    let value: Double
    let nextYearValue: Double
    let followingYearValue: Double

    var totalValue: Double {
        return value + futureValue
    }

    var futureValue: Double {
        return nextYearValue + followingYearValue
    }
}

struct PlayerKeeperActualValue {
    let auctionIncrement = 5
    let playerKeeperValue: PlayerKeeperValue
    let currentAuctionCost: Int

    var nextYearValue: Double {
        return playerKeeperValue.nextYearValue - Double(nextYearAuctionValue)
    }

    var followingYearValue: Double {
        return playerKeeperValue.followingYearValue - Double(followingYearAuctionValue)
    }

    var nextYearAuctionValue: Int {
        return currentAuctionCost + auctionIncrement
    }

    var followingYearAuctionValue: Int {
        return currentAuctionCost + auctionIncrement*2
    }
}

print("Here are the best available hitters")

if case .threeYearAuction = ruleFormat {
    let nextTwoYearsHitters: [PlayerKeeperValue] = sortedHitterValues.prefix(upTo: 100).map { hitter in
        let nextYearValue = hitterValuesNextYear?.first(where: { $0.fullName == hitter.fullName })?.auctionValue ?? 0.0
        let followingYearValue = hitterValuesFollowingYear?.first(where: { $0.fullName == hitter.fullName })?.auctionValue ?? 0.0
        return PlayerKeeperValue(name: hitter.fullName, value: hitter.auctionValue, nextYearValue: nextYearValue, followingYearValue: followingYearValue)
    }

    nextTwoYearsHitters.sorted(by: { $0.futureValue > $1.futureValue }).forEach {
        print("\($0) - total: \($0.totalValue) - future: \($0.futureValue)")
    }
} else {
    // single year

    let allPlayers = teams.flatMap {
        $0.players
    }

    let freeAgentHitters = sortedHitterValues.filter { playerAuction -> Bool in
        !allPlayers.contains {
            playerComparer.isSamePlayer(playerOne: playerAuction, playerTwo: $0)
        }
    }

    freeAgentHitters.prefix(20).forEach {
        print($0)
    }

    print("-----------------")
    let freeAgentPitchers = sortedPitcherValues.filter { playerAuction -> Bool in
        !allPlayers.contains {
            playerComparer.isSamePlayer(playerOne: playerAuction, playerTwo: $0)
        }
    }

    freeAgentPitchers.prefix(20).forEach {
        print($0)
    }
}

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
