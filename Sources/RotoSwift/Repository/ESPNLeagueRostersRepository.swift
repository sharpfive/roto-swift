//
//  ESPNLeagueRostersRepository.swift
//  RotoSwiftPackageDescription
//
//  Created by Jaim Zuber on 4/1/18.
//

import Foundation

public class ESPNLeagueRostersRepository {

    enum ParseState {
        case beforeLeague
        case teamName
        case afterTeamName
        case player
        case complete
    }

    let leagueRostersToken = "League Rosters"
    let endOfTeamsToken = "Need Help?"

    public init() {}

    public func getLeagueRosters(for filename: String) -> League {

        var parseState: ParseState = ParseState.beforeLeague

        var teamName = ""
        var teams = [League.Team]()
        var players = [League.Player]()

        // open file and read text
        let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        var lineCount = 0

        leagueRostersDataString.enumerateLines { (lineString, _) in
            lineCount += 1

            switch parseState {
            case .beforeLeague:
                // print(lineString)
                if lineString == self.leagueRostersToken {
                    parseState = .teamName
                }
            case .teamName:
                // print("Found Team: \(lineString)")
                if lineString == self.endOfTeamsToken {
                    print("end of teams")
                    parseState = .complete
                    break
                }
                teamName = lineString
                parseState = .afterTeamName
            case .afterTeamName:
                // Header Info (throw away data)
                parseState = .player
            case .player:
                if lineString.isEmpty {
                    // team is complete
                    let team = League.Team(name: teamName, players: players)
                    teams.append(team)
                    // reset player list and team name
                    players = [League.Player]()
                    teamName = ""
                    parseState = .teamName
                    break
                }
                // Parse the player info
                if let player = self.parsePlayer(from: lineString) {
                    // print("Found Player: \(player.name)")
                    players.append(player)
                }
            case .complete:
                break
            }
        }

        // print("Ready to return")

        let league = League(teams: teams)

        return league
    }

    public func parsePlayer(from playerString: String) -> League.Player? {
        let playerComponents = playerString.components(separatedBy: "\t")

        var endOfNameIndex = 1
        repeat {
            endOfNameIndex+=1
        } while endOfNameIndex < playerComponents.count-1 &&
            !playerComponents[endOfNameIndex].hasSuffix(",")

        let beginningOfPlayerNameIndex = 1

        // trim any commas
        let playerNameComponents = playerComponents[beginningOfPlayerNameIndex...endOfNameIndex].map { $0.replacingOccurrences(of: ",", with: "") }

        let playerName = playerNameComponents.reduce("", { "\($0) \($1)"})

        if playerName.lengthOfBytes(using: .ascii) <= 3 {
            // empty position
            return nil
        }

        let player = League.Player(name: playerName)

        return player
    }
}
