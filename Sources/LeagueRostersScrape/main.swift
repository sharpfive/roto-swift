import Foundation
import RotoSwift
import SPMUtility

func printValues(for leagueRosters: League, auctionValues: [PlayerAuction], top: Int) {
    var teamValues = [(name: String, value: Double)]()

    leagueRosters.teams.forEach { team in
        var teamValue = 0.0

        let players: [PlayerAuction] = team.players.compactMap { player in
            if let auctionPlayer = auctionValues.first(where: { $0.name == player.name }) {
                return auctionPlayer
            } else {
                print("\(player.name) not found")
                return nil
            }
        }

        let playerPool = players.sorted(by: { $0.auctionValue > $1.auctionValue })
            .filter({ $0.auctionValue > 0.0})
            .prefix(top)

        teamValue = playerPool.map({ $0.auctionValue}).reduce(0, +)

        teamValues.append((name: team.name, value: teamValue))
    }

    let orderedTeamValues = teamValues.sorted(by: { $0.value > $1.value })

    orderedTeamValues.forEach {
        print("team: \($0.name): \($0.value)")
    }
}

print("LeagueRostersScrape")

let parser = ArgumentParser(commandName: "LeagueRostersScrape", usage: "filename [--hitters  fangraphs-hitter-projections.csv --pitchers fangraphs-pitcher-projections.csv --rosters ESPN Rosters.txt]", overview: "Takes a scrape of the league rosters and adds the values for all the players on their team.")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")
let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitchers csv file.")
let rostersFilenameOption = parser.add(option: "--rosters", shortName: "-r", kind: String.self, usage: "Filename for the rosters file.")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
}
catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
}
catch let error {
    print(error.localizedDescription)
    exit(0)
}

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let rostersFilename = parsedArguments.get(rostersFilenameOption)

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

guard let rostersFilename = rostersFilename else {
    print("Rosters filename is required")
    exit(0)
}

//let filename = "/Users/jaim/Dropbox/roto/projections/2019-05-29/ESPN-rosters.txt"

// open file and read text
let leagueRostersDataString = try! String(contentsOfFile: rostersFilename, encoding: String.Encoding.ascii)

let repository = ESPNLeagueRostersRepository2019()

let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)

print("leagueRosters.teams.count: \(leagueRosters.teams.count)")

//let hitterFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-auctionvalues-batters.csv"
//
//let pitcherFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-auctionvalues-pitchers.csv"

let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
let projectedValues = fangraphsRepository.getAuctionValues()

print("projectedValues.count \(projectedValues.count)")

print("All Players")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 30)

print("Top 15")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 15)

print("Top 10")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 10)

func printValues2(for leagueRosters: League, auctionValues: [PlayerAuction], top: Int) {
    //var teamValues = [(name: String, value: Double)]()
    //var totalTeamValues = 0.0

    let teamPlayerValues = leagueRosters.teams.map { team -> (String, [PlayerAuction]) in
        let playerAuctionValues: [PlayerAuction] = team.players.compactMap { player in
            if let auctionPlayer = auctionValues.first(where: { $0.name == player.name }) {
                return auctionPlayer
            } else {
                print("\(player.name) not found")
                return nil
            }
        }

        return (team.name, playerAuctionValues)
    }
}

//    leagueRosters.teams.forEach { team in
//        var teamValue = 0.0
//
//    let teamPlayerValues = leagueRosters.teams.map { team -> (String, [PlayerAuction]) in
//        let playerAuctionValues: [PlayerAuction] = team.players.compactMap { player in
//            if let auctionPlayer = auctionValues.first(where: { $0.name == player.name }) {
//                return auctionPlayer
//            } else {
//                print("\(player.name) not found")
//                return nil
//            }
//        }
//
//        return (team.name, playerAuctionValues)
//    }
//
//
//
////    leagueRosters.teams.forEach { team in
////        var teamValue = 0.0
////
////        let players: [PlayerAuction] = team.players.compactMap { player in
////            if let auctionPlayer = auctionValues.first(where: { $0.name == player.name }) {
////                return auctionPlayer
////            } else {
////                print("\(player.name) not found")
////                return nil
////            }
////        }
////
////        let playerPool = players.sorted(by: { $0.auctionValue > $1.auctionValue })
////            //.filter({ $0.auctionValue > 0.0})
////            .prefix(top)
////
////        teamValue = playerPool.map({ $0.auctionValue}).reduce(0,+)
////
////        teamValues.append((name: team.name, value: teamValue))
////        totalTeamValues = totalTeamValues + teamValue
////    }
////
////    let orderedTeamValues = teamValues.sorted(by: { $0.value > $1.value } )
////
////    orderedTeamValues.forEach {
////        print("team: \($0.name): \($0.value)")
////    }
//}
////
////printValues2(for: leagueRosters, auctionValues: projectedValues, top: 30)
////
////leagueRosters.teams.map { $0.players.reduce(0, { (result, player) -> Double in
////    return result + player.auctionValue
////})}
