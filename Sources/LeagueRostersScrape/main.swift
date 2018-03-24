import Foundation
import RotoSwift

func parsePlayer(from playerString: String) -> League.Player? {
    let playerComponents = playerString.components(separatedBy:"\t")
    
    playerComponents.forEach {
        print($0)
    }
    var endOfNameIndex = 1
    repeat  {
        endOfNameIndex+=1
    } while endOfNameIndex < playerComponents.count-1 &&
                !playerComponents[endOfNameIndex].hasSuffix(",")
    
    let beginningOfPlayerNameIndex = 1
    
    // let lengthOfPlayerName = endOfNameIndex - beginningOfPlayerNameIndex
    
    // trim any commas
    let playerNameComponents = playerComponents[beginningOfPlayerNameIndex...endOfNameIndex].map { $0.replacingOccurrences(of: ",", with: "") }
    
    let playerName = playerNameComponents.reduce("", { "\($0) \($1)"})
    
    let player = League.Player(name: playerName)
    
    return player
}

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

let leagueRostersToken = "League Rosters"

var parseState: ParseState = ParseState.BeforeLeague

var teamName = ""
var players = [League.Player]()

leagueRostersDataString.enumerateLines { (lineString, boolean) in
    lineCount += 1
    

    switch parseState {
    case .BeforeLeague:
        print(lineString)
        if lineString == leagueRostersToken {
            parseState = .TeamName
        }
    case .TeamName:
        print("Found Team: \(lineString)")
        teamName = lineString
        parseState = .AfterTeamName
    case .AfterTeamName:
        // Header Info (throw away data)
        parseState = .Player
    case .Player:
        if lineString.isEmpty {
            parseState = .TeamName
            break
        }
        // Parse the player info
        if let player = parsePlayer(from: lineString) {
            print("Found Player: \(player.name)")
            players.append(player)
        } else {
            print("Can't parse line: \(lineString)")
        }
    }
}
print("LineCount: \(String(describing:lineCount))")

// look for "League Rosters" text
// Next line is a Team Name


