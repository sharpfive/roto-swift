//
//  FantraxScrapeCSVRosterRepository.swift
//  
//
//  Created by Jaim Zuber on 4/3/21.
//

import Foundation
import CSV

public class FantraxScrapeCSVRosterRepository: TeamRepository {
    enum TeamAbbreviations: String, CaseIterable {
        case ARI
        case ATL
        case BAL
        case BOS
        case CHC
        case CHW
        case CLE
        case CIN
        case COL
        case DET
        case KC
        case HOU
        case LAA
        case LAD
        case MIA
        case MIN
        case MIL
        case NYM
        case NYY
        case OAK
        case PHI
        case PIT
        case SD
        case SF
        case SEA
        case STL
        case TB
        case TEX
        case TOR
        case WSH
    }

    enum PositionAbbreviations: String, CaseIterable {
        case C
        case FirstBase = "1B"
        case SecondBase = "2B"
        case ThirdBase = "3B"
        case SS
        case OF
        case RP
        case SP
        case DH
        case UT

        func spaceSurroundingString() -> String {
            return " \(self.rawValue) "
        }
    }

    let filename: String

    public init(filename: String) {
        self.filename = filename
    }

    public func getTeams() -> [Team] {
        let nameTeamPositionRow = 0
        let playerDataRow = 1

        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: true)

        var teams = [Team]()
        while let row = csv.next() {
            let teamName = row[nameTeamPositionRow]

            let playerDataString = row[playerDataRow]

            let names = extractPlayerNames(fromArray: playerDataString)

            let playerKeeperPrices = names.map { PlayerKeeperPrice(name: $0, keeperPrice: 1)}

            let team = Team(name: teamName, players: playerKeeperPrices)

            teams.append(team)
        }

        return teams
    }

    private func extractPlayerNames(fromArray playerDataString: String ) -> [String] {
        let separated = playerDataString.split(separator: "|")

        return separated.compactMap {
            extractName(from: String($0))
        }
    }

    private func extractName(from playerString: String) -> String? {
        // Yasmani Grandal C - CHWY Grandal
        // Check for position and return first part of string

        let positionAbbreviationStrings = PositionAbbreviations.allCases.map { $0.spaceSurroundingString() }

        guard let range = positionAbbreviationStrings.compactMap({
            return playerString.range(of: $0)
        }).first else { return nil }

        let playerNameString = String(playerString.prefix(upTo: range.lowerBound))


        return playerNameString
    }
}
