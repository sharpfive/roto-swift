//
//  ESPNLeagueRostersRepository2019.swift
//  RotoSwift
//
//  Created by Jaim Zuber on 3/25/19.
//

import Foundation

public class ESPNLeagueRostersRepository2019 {
    enum ParseState {
        case BeforeLeague
        case TeamName
        case ActivePosition
        case Name
        case Positions
        case Complete
    }

    let leagueRostersToken = "League Rosters"
    let endOfTeamsToken = "Fantasy Baseball Support"
    let endOfTeamToken = "View Team"
    let proposeTradeToken = "Propose Trade"
    let emptyToken = "Empty"

    public init() {

    }
    
    public func getLeagueRosters(from string: String) -> League {
        var teams = [League.Team]()

        var parseState: ParseState = .BeforeLeague
        var lineCount = 0

        var teamName: String = ""
        var players = [League.Player]()
        var activePosition: League.Position?
        var playerName: String?

        string.enumerateLines { (lineString, boolean) in
            lineCount += 1

            if lineString.isEmpty || lineString == self.proposeTradeToken {
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
                    // print("end of teams")
                    parseState = .Complete
                    break
                }
                print("Found Team: \(lineString)")
                teamName = lineString
                parseState = .ActivePosition
            case .ActivePosition:
                if lineString == self.endOfTeamToken {
                    // print("end of single team")
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
            case .Positions:
                let positions: [League.Position]

                // If the entire linestring converts to a Position, the player only has 1 position elligible
                if let singlePosition = League.Position(rawValue: lineString) {
                    positions = [singlePosition]
                } else {
                    // Otherwise it is a comma-delimited list
                    let positionArray = lineString.components(separatedBy: ",").compactMap { League.Position(rawValue: $0 )}

                    if positionArray.isEmpty {
                        return
                    }
                    positions = positionArray
                }

                // Player is complete
                guard let playerName = playerName,
                    let _ = activePosition else {
                        print("aiai error")
                        return
                }

                players.append(League.Player(name: playerName, eligiblePositions: positions))
                parseState = .ActivePosition
            case .Complete:
                break
            }
        }

        print(lineCount)
        return League(teams: teams)
    }
}

