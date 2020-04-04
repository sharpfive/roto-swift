import Foundation
import RotoSwift
import SPMUtility

func printValues(for leagueRosters: League, auctionValues: [PlayerAuction], top: Int) {
    var teamValues = [(name: String, value: Double)]()

    leagueRosters.teams.forEach { team in
        var teamValue = 0.0

        let players: [PlayerAuction] = team.players.compactMap { player in
            if let auctionPlayer = auctionValues.first(where: { $0.fullName == player.name }) {
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

let parser = ArgumentParser(commandName: "LeagueRostersScrape",
                            usage: "filename [--hitters  fangraphs-hitter-projections.csv --pitchers fangraphs-pitcher-projections.csv --rosters ESPN Rosters.txt]",
                            overview: "Takes a scrape of the league rosters and adds the values for all the players on their team.")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters csv file.")
let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitchers csv file.")
let rostersFilenameOption = parser.add(option: "--rosters", shortName: "-r", kind: String.self, usage: "Filename for the rosters file.")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
} catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
} catch let error {
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

// open file and read text
let leagueRostersDataString = try! String(contentsOfFile: rostersFilename, encoding: String.Encoding.ascii)

let repository = ESPNLeagueRostersRepository2019()

let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)

print("leagueRosters.teams.count: \(leagueRosters.teams.count)")

let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
let projectedValues = fangraphsRepository.getAuctionValues()

print("projectedValues.count \(projectedValues.count)")

print("All Players")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 30)

print("Top 15")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 15)

print("Top 10")
printValues(for: leagueRosters, auctionValues: projectedValues, top: 10)
