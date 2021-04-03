//
//  ESPNSCrapeCSVRosterRepository.swift
//  
//
//  Created by Jaim Zuber on 3/27/21.
//

import Foundation
import CSV

public protocol TeamRepository {
    func getTeams() -> [Team]
}

public class ESPNSCrapeCSVRosterRepository: TeamRepository {
    enum TeamAbbreviations: String, CaseIterable {
        case Ari
        case Atl
        case Bal
        case Bos
        case ChC
        case ChW
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
        case Wsh
    }

    enum FilterWords: String, CaseIterable {
        case DTD
        case IL10
        case IL60
        case SSPD
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
        let teamAbbreviationStrings = TeamAbbreviations.allCases.map { $0.rawValue }

        // Last because Gerrit Cole gets rejected because of Col abbreviation
//        guard let teamAbbreviationString = teamAbbreviationStrings.last(where: { abbreviation in
//            playerString.contains(abbreviation)
//        }),
//        let range = playerString.range(of: teamAbbreviationString) else {
//            return nil
//        }

        guard let range = teamAbbreviationStrings.compactMap { abbreviation in
            playerString.range(of: abbreviation)
        }.sorted { $0.lowerBound < $1.lowerBound }.last else {
            print("extractName rejecting \(playerString)")
            return nil
        }

        if range.lowerBound == playerString.startIndex {
            print("extractName rejecting \(playerString)")
            return nil
        }

        var preString = String(playerString.prefix(upTo: range.lowerBound))

        FilterWords.allCases.forEach { filterString in
            preString = preString.replacingOccurrences(of: filterString.rawValue, with: "")
        }

        return preString
    }
}
