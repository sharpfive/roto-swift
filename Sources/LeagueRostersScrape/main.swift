import Foundation
import RotoSwift

print("LeagueRostersScrape")

let filename = "/Users/jaim/Dropbox/roto/2019/rosters/ESPN-2019-03-25.txt"

// open file and read text
let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)


let repository = ESPNLeagueRostersRepository2019()

let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)

print("leagueRosters: \(leagueRosters.teams.count)")


