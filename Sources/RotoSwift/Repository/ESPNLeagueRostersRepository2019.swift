//
//  ESPNLeagueRostersRepository2019.swift
//  RotoSwift
//
//  Created by Jaim Zuber on 3/25/19.
//

import Foundation

public class ESPNLeagueRostersRepository2019 {
    enum ParseState {
        case beforeLeague
        case teamName
        case activePosition
        case name
        case positions
        case complete
    }

    let leagueRostersToken = "League Rosters"
    let endOfTeamsToken = "Fantasy Baseball Support"
    let endOfTeamToken = "View Team"
    let proposeTradeToken = "Propose Trade"
    let emptyToken = "Empty"

    public init() {}

    public func getLeagueRosters(from string: String) -> League {
        var teams = [League.Team]()

        var parseState: ParseState = .beforeLeague

        var teamName: String = ""
        var players = [League.Player]()
        var activePosition: League.RosterPosition?
        var playerName: String?

        string.enumerateLines { (lineString, _) in
            if lineString.isEmpty || lineString == self.proposeTradeToken {
                return
            }

            switch parseState {
            case .beforeLeague:
                // print(lineString)
                if lineString.hasPrefix(self.leagueRostersToken) {
                    parseState = .teamName
                }
            case .teamName:
                if lineString == self.endOfTeamsToken {
                    // print("end of teams")
                    parseState = .complete
                    break
                }
                // print("Found Team: \(lineString)")
                teamName = lineString
                parseState = .activePosition
            case .activePosition:
                if lineString == self.endOfTeamToken {
                    // print("end of single team")
                    let newTeam = League.Team(name: teamName, players: players)
                    teams.append(newTeam)
                    teamName = ""
                    players = [League.Player]()
                    parseState = .teamName
                }
                // Wait for a line only consisting of a position
                guard let position = League.RosterPosition(rawValue: lineString) else { return }
                activePosition = position
                parseState = .name

            case .name:
                if lineString != self.emptyToken {
                    if !isValidPlayerName(name: lineString) {
                        break
                    }

                    playerName = lineString
                    // print("found player: \(String(describing: playerName))")
                    parseState = .positions
                } else {
                    parseState = .activePosition
                }
            case .positions:
                guard let positions = extractPositions(from: lineString) else { break }

                // Player is complete
                guard let playerName = playerName,
                    activePosition != nil else {
                        print("Error: Unable to parse a player")
                        return
                }

                players.append(League.Player(name: playerName, eligiblePositions: positions))
                parseState = .activePosition
            case .complete:
                break
            }
        }

        return League(teams: teams)
    }

}

func isValidPlayerName(name: String) -> Bool {
    // check for duplicated strings
    let stringLength = name.count / 2

    let firstHalf = name.prefix(stringLength)
    let secondHalf = name.suffix(stringLength)

    return firstHalf != secondHalf
}
