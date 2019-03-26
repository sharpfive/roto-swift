import Foundation
import RotoSwift

print("LeagueRostersScrape")

let filename = "/Users/jaim/Dropbox/roto/2019/rosters/ESPN-2019-03-25.txt"

// open file and read text
let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)


let repository = ESPNLeagueRostersRepository2019()

let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)

print("leagueRosters: \(leagueRosters.teams.count)")


let hitterFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-batters-2019-03-23.csv"

let pitcherFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-pitchers-2019-03-23.csv"

let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
let projectedValues = fangraphsRepository.getAuctionValues()

var teamValues = [(name: String, value: Double)]()

leagueRosters.teams.forEach { team in
    var teamValue = 0.0

    let players: [PlayerAuction] = team.players.compactMap { player in
        if let auctionPlayer = projectedValues.first(where: { $0.name == player.name }) {
            return auctionPlayer
        } else {
            print("\(player.name) not found")
            return nil
        }
    }

    let playerPool = players.sorted(by: { $0.auctionValue > $1.auctionValue })
                            .filter({ $0.auctionValue > 0.0})
                            .prefix(15)

    teamValue = playerPool.map({ $0.auctionValue}).reduce(0,+)


    //team.players.sorted(by: { player. })
//    team.players.forEach { player in
//        // find player.name in projectedValues
//        if let playerProjection = projectedValues.first(where: { $0.name == player.name }) {
//            //print("player: \(playerProjection.name) = \(playerProjection.auctionValue)")
//            if playerProjection.auctionValue > 0 {
//                teamValue = teamValue + playerProjection.auctionValue
//            }
//        }
//    }

    teamValues.append((name: team.name, value: teamValue))
}

let orderedTeamValues = teamValues.sorted(by: { $0.value > $1.value } )
orderedTeamValues.forEach {
    print("team: \($0.name): \($0.value)")
}

//print("\(orderedTeamValues)")


