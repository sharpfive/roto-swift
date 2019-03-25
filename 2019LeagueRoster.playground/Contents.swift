import UIKit

public struct League {

    public let teams: [Team]

    public struct Team {
        public let name: String
        public let players: [Player]
    }

    public struct Player {
        public let name: String

        public init(name: String) {
            self.name = name
        }
        //        let positions: [Position]
    }

    public enum Position : String {
        case Catcher = "C"
        case FirstBase = "1B"
        case SecondBase = "2B"
        case ThirdBase = "3B"
        case ShortStop = "SS"
        case Outfield = "OF"
        case StartingPitcher = "SP"
        case ReliefPitcher = "RP"
        case Bench = "Bench"
    }
}

class ESPNLeagueRostersRepository2019 {
    enum ParseState {
        case BeforeLeague
        case TeamName
        //case AfterTeamName
        case ActivePosition
        case Name
        //case Team
        case Positions
        //case HowAcquired

        //case Player
        case Complete
    }

    let leagueRostersToken = "League Rosters"
    let endOfTeamsToken = "Fantasy Baseball Support"
    let endOfTeamToken = "Propose Trade"
    let emptyToken = "Empty"

    public func getLeagueRosters(from string: String) -> League {
        var teams = [League.Team]()

        var parseState: ParseState = .BeforeLeague
        var lineCount = 0

        var teamName: String = ""
        var players = [League.Player]()
        var activePosition: League.Position?
        var playerName: String?
        var currentTeam: League.Team?

        string.enumerateLines { (lineString, boolean) in
            lineCount += 1

            if lineString.isEmpty {
                return
            }

            switch parseState {
            case .BeforeLeague:
                // print(lineString)
                if lineString.hasPrefix(self.leagueRostersToken) {
                    parseState = .TeamName
                }
            case .TeamName:
                if lineString == self.endOfTeamsToken {
                    print("end of teams")
                    parseState = .Complete
                    break
                }
                print("Found Team: \(lineString)")
                teamName = lineString
                parseState = .ActivePosition
            case .ActivePosition:
                if lineString == self.endOfTeamToken {
                    print("end of single team")
                    let newTeam = League.Team(name: teamName, players: players)
                    teams.append(newTeam)
                    teamName = ""
                    players = [League.Player]()
                    parseState = .TeamName
                }
                // Wait for a line only consisting of a position
                guard let position = League.Position(rawValue: lineString) else { return }
                activePosition = position
                parseState = .Name

            case .Name:
                if lineString != self.emptyToken {
                    playerName = lineString
                    print("found player: \(String(describing: playerName))")
                    parseState = .Positions
                } else {
                    parseState = .ActivePosition
                }
//                if lineString.isEmpty {
//                    // team is complete
//                    let team = League.Team(name: teamName, players: players)
//                    teams.append(team)
//                    // reset player list and team name
//                    players = [League.Player]()
//                    teamName = ""
//
//                    parseState = .TeamName
//                    break
//                }
//            // Parse the player info
//            if let player = self.parsePlayer(from: lineString) {
//                // print("Found Player: \(player.name)")
//                players.append(player)
//            }
            case .Positions:
                var positionIsValid = false
                if let _ = League.Position(rawValue: lineString) {
                    positionIsValid = true
                }

                // should be a comma separated string with the elligible positions C,1B,3B
                if !positionIsValid {
                    // check for comma delimited array
                    let positionArray = lineString.components(separatedBy: ",")
                    guard let firstPosition = positionArray.first,
                        let _ = League.Position(rawValue: firstPosition) else { return }
                }

                // Player is complete
                guard let playerName = playerName,
                    let _ = activePosition else {
                        print("aiai error")
                        return
                    }

                players.append(League.Player(name: playerName))
                parseState = .ActivePosition
            case .Complete:
            break
        }
        }

        print(lineCount)
        return League(teams: teams)
    }
}


var pointsRange = 1...12
var numberOfTeams = 12
var numberOfCategories = 10
var auctionDollarsPerTeam = 260

let winningPoints = 100.0

let singleCategoryPoints = pointsRange.reduce(0,+)
let allTeamPoints = singleCategoryPoints * numberOfCategories
let averageTeamPoints = allTeamPoints / numberOfTeams

let allTeamAuctionDollars = auctionDollarsPerTeam * numberOfTeams

let winningPointsPercentage = winningPoints / Double(allTeamPoints)
let winningAuctionValue = winningPointsPercentage * Double(allTeamAuctionDollars)


let dirs = NSSearchPathForDirectoriesInDomains(
    FileManager.SearchPathDirectory.documentDirectory,
    FileManager.SearchPathDomainMask.userDomainMask,
    true)

import PlaygroundSupport
// let valuePercentage = winningAuctionValue / Double(auctionDollarsPerTeam)
let filename = "2019-03-24-espn.rosters.txt"

print(playgroundSharedDataDirectory)

let pathURL = playgroundSharedDataDirectory.appendingPathComponent(filename)
let pathString = pathURL.absoluteString

let leagueRostersDataString = try! String(contentsOf: pathURL, encoding: String.Encoding.ascii)


let repository = ESPNLeagueRostersRepository2019()
let league = repository.getLeagueRosters(from: leagueRostersDataString)

print(league.teams.count)
print(league.teams)


