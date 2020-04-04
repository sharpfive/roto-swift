//
//  FanGraphsAuctionRepository.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation
import CSV

public class FanGraphsAuctionRepository {
    let hitterFilename: String?
    let pitcherFilename: String?

    var nameFieldValue = "ï»¿\"PlayerName\""
    var auctionFieldValue = "Dollars"

    public init(hitterFilename: String?, pitcherFilename: String?) {
        self.hitterFilename = hitterFilename
        self.pitcherFilename = pitcherFilename
    }

    public func getAuctionValues() -> [PlayerAuction] {

        var players = [PlayerAuction]()

        if let hitterFilename = hitterFilename {
            players += getAuctionValues(for: hitterFilename)
        }

        if let pitcherFilename = pitcherFilename {
            players += getAuctionValues(for: pitcherFilename)
        }

        return players
    }

    func getAuctionValues(for filename: String) -> [PlayerAuction] {
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: true) // It must be true.
        let headerRow = csv.headerRow!
        let nameRowOptional = headerRow.index(of: nameFieldValue)

        let projectedAuctionValueRowOptional = headerRow.index(of: auctionFieldValue)

        guard let nameRow = nameRowOptional else {
            print("Unable to find name row")
            exit(0)
        }

        guard let projectedAuctionValueRow = projectedAuctionValueRowOptional else {
            print("Unable to find auction value row")
            exit(0)
        }

        var playerAuctions = [PlayerAuction]()

        while let row = csv.next() {
            let projectedAuctionValueString = row[projectedAuctionValueRow]

            // check if the string is negative
            let isNegative = projectedAuctionValueString.contains("(")

            let nonAlphaNumericCharactedSet = CharacterSet(charactersIn: "$()")
            let trimmedString = projectedAuctionValueString.trimmingCharacters(in: nonAlphaNumericCharactedSet)

            if let projectedAuctionAbsoluteValue = Double(trimmedString) {
                let name = row[nameRow]

                let projectedAuctionValue: Double
                if isNegative {
                    projectedAuctionValue = projectedAuctionAbsoluteValue * -1.0
                } else {
                    projectedAuctionValue = projectedAuctionAbsoluteValue
                }

                playerAuctions.append( PlayerAuction(fullName: name, zScore: 0.0, auctionValue: projectedAuctionValue))
            } else {
                print("rejecting: \(trimmedString)")
            }
        }

        return playerAuctions
    }
}
