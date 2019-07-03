//
//  PlayerFieldPositionRepository.swift
//  Basic
//
//  Created by Jaim Zuber on 7/2/19.
//

import Foundation
import CSV

public class PlayerFieldPositionRepository {

    enum PlayerCSVError: Error {
        case missingField(fieldName: String)
    }

    public func getPlayers(from filename: String) throws -> [League.Player] {
        let nameFieldValue = "ï»¿\"PlayerName\""
        let elligiblePositionsFieldValue = "POS"
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: true) // It must be true.

        let headerRow = csv.headerRow!
        let nameRowOptional = headerRow.index(of: nameFieldValue)

        guard let nameRow = nameRowOptional else {
            throw PlayerCSVError.missingField(fieldName: nameFieldValue)
        }

        let elligiblePositionsFieldValueOptional = headerRow.index(of: elligiblePositionsFieldValue)

        guard let elligiblePositionsRow = elligiblePositionsFieldValueOptional else {
            throw PlayerCSVError.missingField(fieldName: elligiblePositionsFieldValue)
        }

        var players = [League.Player]()

        while let row = csv.next() {
            let nameString = row[nameRow]
            let elligiblePositionsString = row[elligiblePositionsRow]

            guard let eligblePositions = extractPositions(from: elligiblePositionsString, separatorString: "/") else {
                continue
            }

            players.append(League.Player(name: nameString, eligiblePositions: eligblePositions))
        }

        return players
    }
}
