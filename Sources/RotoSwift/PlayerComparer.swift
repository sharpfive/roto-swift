//
//  PlayerComparer.swift
//  
//
//  Created by Jaim Zuber on 4/4/20.
//

import Foundation

// This is an optimistic name comparer. Desiged for simplicity. It will split out the first and last name if the underlying type supports it
// For cases where only full names are supported it does a simple string compare. No attempt is made to ignore a "Jr" or replace a commonly
// different first name i.e. Jake/Jacob
// It also does some comparisons by checking if a first or last name is contained in another players full name. This will break if a player
// like John Johnson enters the league but it all works for now
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
        var trimmedString = string.replacingOccurrences(of: " Jr", with: "")
        trimmedString = string.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        trimmedString = trimmedString.replacingOccurrences(of: "ó", with: "o")
        trimmedString = trimmedString.replacingOccurrences(of: "ñ", with: "n")
        trimmedString = trimmedString.replacingOccurrences(of: "é", with: "e")
        trimmedString = trimmedString.replacingOccurrences(of: "á", with: "a")
        trimmedString = trimmedString.replacingOccurrences(of: "ú", with: "u")
        trimmedString = trimmedString.replacingOccurrences(of: "í", with: "i")
        trimmedString = trimmedString.replacingOccurrences(of: " (Batter)", with: "")
        trimmedString = trimmedString.replacingOccurrences(of: " (Pitcher)", with: "")


        return trimmedString
    }

    private lazy var nameDifferencesExtracted: [String: String] = {
        var dictionary = nameDifferences

        // now map the values to their keys (Zach -> Zack, Zack -> Zach)
        for (_, value) in dictionary.enumerated() {
            dictionary[value.value] = value.key
        }

        return dictionary
    }()

    private var nameDifferences: [String: String] = [
        // Keep it in code until it becomes a problem.
        "Zack": "Zach",
        "Jake": "Jakob",
        "Nick": "Nicholas",
        "Yuli": "Yulieski",
        "Nate": "Nathaniel",
        "Alex": "Alexander"
    ]
}


