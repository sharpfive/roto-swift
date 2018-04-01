import Foundation
import RotoSwift

print("LeagueRostersScrape")

let filename = "/Users/jaim/code/roto-swift/data/2017-espn.roster.txt"

// open file and read text
let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

var lineCount = 0

enum ParseState {
    case BeforeLeague
    case TeamName
    case AfterTeamName
    case Player
}






print("LineCount: \(String(describing:lineCount))")

// look for "League Rosters" text
// Next line is a Team Name


