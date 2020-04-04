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

//extension FullNameHaving {
//    func noJr() -> String {
//        return self //TODO remove JR
//    }
//}

public class PlayerComparer {
    public init() {}

    public func isSamePlayer(playerOne: FullNameHaving, playerTwo: FullNameHaving) -> Bool {
        let playerOneTrimmed = trim(playerOne.fullName)
        let playerTwoTrimmed = trim(playerTwo.fullName)

        if playerOneTrimmed.caseInsensitiveCompare(playerTwoTrimmed) == .orderedSame {
            return true
        }

        if let playerOneHalf = playerOne as? TwoPartNameHaving {
            return isSamePlayer(playerOne: playerOneHalf, playerTwo: playerTwo)
        } else if let playerTwoHalf = playerTwo as? TwoPartNameHaving {
            return isSamePlayer(playerOne: playerTwoHalf, playerTwo: playerOne)
        }

        return false
    }

//    private func isSamePlayer(playerOne: TwoPartNameHaving, playerTwo: TwoPartNameHaving) -> Bool {
//        return false
//    }

    private func isSamePlayer(playerOne: TwoPartNameHaving, playerTwo: FullNameHaving) -> Bool {
        if !playerTwo.fullName.contains(playerOne.lastName) {
            return false
        }

        // last name match is probable, check first name
        if playerTwo.fullName.contains(playerOne.firstName) {
            // close enough
            return true
        }

        // else check for nameDifference
        if let differentName = nameDifferencesExtracted[playerOne.firstName],
            playerTwo.fullName.contains(differentName) {
            return true
        }

        return false
    }

    private func trim(_ string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return trimmedString
    }

    lazy var nameDifferencesExtracted: [String: String] = {
        var dictionary = nameDifferences

        // now map the values to their keys (Zach -> Zack, Zack -> Zach)
        for (_, value) in dictionary.enumerated() {
            dictionary[value.value] = value.key
        }

        print("nameDifferencesExtracted \(dictionary)")
        return dictionary
    }()

    var nameDifferences: [String: String] = [
        "Zack": "Zach",
        "Jake": "Jakob",
        "Nick": "Nicholas",
        "Yuli": "Yulieski",
        "Nate": "Nathaniel"
    ]
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
