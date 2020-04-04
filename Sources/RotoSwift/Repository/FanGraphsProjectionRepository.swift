//
//  FanGraphsProjectionRepository.swift
//
//  Created by Jaim Zuber on 4/4/20.
//

import Foundation
import CSV

public struct FanGraphsPlayer: FullNameHaving {
    public var fullName: String
    public var fangraphsID: String
}

struct CouchManagerToFanGraphsMapper {
    let fangraphsPlayers: [FanGraphsPlayer]
    let couchManagerPlayers: [CouchManagerLeagueRespository.AuctionEntry]


    let playerComparer = PlayerComparer()

}

public class FanGraphsProjectionRepository {
    let hitterFilename: String?
    let pitcherFilename: String?

    var nameFieldValue = "ï»¿\"PlayerName\""
    var idFieldValue = "playerId"

    public init(hitterFilename: String?, pitcherFilename: String?) {
        self.hitterFilename = hitterFilename
        self.pitcherFilename = pitcherFilename
    }

    public func getPlayers() -> [FanGraphsPlayer] {

        var players = [FanGraphsPlayer]()

        if let hitterFilename = hitterFilename {
            players += getPlayers(for: hitterFilename)
        }

        if let pitcherFilename = pitcherFilename {
            players += getPlayers(for: pitcherFilename)
        }

        return players
    }

    func getPlayers(for filename: String) -> [FanGraphsPlayer] {
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: true) // It must be true.
        let headerRow = csv.headerRow!
        let nameRowOptional = headerRow.index(of: nameFieldValue)

        let projectedAuctionValueRowOptional = headerRow.index(of: idFieldValue)

        guard let nameRow = nameRowOptional else {
            print("Unable to find name row")
            exit(0)
        }

        guard let projectedAuctionValueRow = projectedAuctionValueRowOptional else {
            print("Unable to find playerId row")
            exit(0)
        }

        var playerAuctions = [FanGraphsPlayer]()

        while let row = csv.next() {
            let projectedAuctionValueString = row[projectedAuctionValueRow]
            let fullName = row[nameRow]
//            // check if the string is negative
//            let isNegative = projectedAuctionValueString.contains("(")
//
//            let nonAlphaNumericCharactedSet = CharacterSet(charactersIn: "$()")
//            let trimmedString = projectedAuctionValueString.trimmingCharacters(in: nonAlphaNumericCharactedSet)
//
//            if let projectedAuctionAbsoluteValue = Double(trimmedString) {
//                let name = row[nameRow]
//
//                let projectedAuctionValue: Double
//                if isNegative {
//                    projectedAuctionValue = projectedAuctionAbsoluteValue * -1.0
//                } else {
//                    projectedAuctionValue = projectedAuctionAbsoluteValue
//                }

                playerAuctions.append( FanGraphsPlayer(fullName: fullName, fangraphsID: projectedAuctionValueString))
//            }
        }

        return playerAuctions
    }
}

import Foundation
