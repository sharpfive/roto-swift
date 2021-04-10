//
//  YahooScrapeCSVRosterRepository.swift
//
//
//  Created by Jaim Zuber on 4/3/21.
//

import Foundation
import CSV

public class YahooScrapeCSVRosterRepository: TeamRepository {
    enum TeamAbbreviations: String, CaseIterable {
        case Ari
        case Atl
        case Bal
        case Bos
        case ChC
        case CWS
        case Cle
        case Cin
        case Col
        case Det
        case KC
        case Hou
        case LAA
        case LAD
        case Mia
        case Min
        case Mil
        case NYM
        case NYY
        case Oak
        case Phi
        case Pit
        case SD
        case SF
        case Sea
        case StL
        case TB
        case Tex
        case Tor
        case Was

        func spaceSurroundingString() -> String {
            return " \(self.rawValue) "
        }
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
        let nameTeamPositionRow = 1
        let playerDataRow = 0

        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

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

        let teamAbbreviationStrings = TeamAbbreviations.allCases.map { $0.spaceSurroundingString() }

        guard let range = teamAbbreviationStrings.compactMap({
            return playerString.range(of: $0)
        }).first else {
            print("aiai rejecting \(playerString)")
            return nil
        }

        let playerNameString = String(playerString.prefix(upTo: range.lowerBound))


        return playerNameString
    }
}
