//
//  CouchManagerLeagueRespository.swift
//  
//
//  Created by Jaim Zuber on 4/4/20.
//

import CSV
import Foundation

public class CouchManagerLeagueRespository {
    let filename: String

    public init(filename: String) {
        self.filename = filename
    }

    public struct AuctionEntry: TwoPartNameHaving, FullNameHaving {
        public let firstName: String
        public let lastName: String
        public let teamName: String
        public let auctionAmount: Int
        public let teamNumber: Int
        public let ottid: Int // identifier?

        public var fullName: String {
            return "\(firstName) \(lastName)"
        }
    }

    public struct DraftEntry: TwoPartNameHaving, FullNameHaving {
        public let firstName: String
        public let lastName: String
        public let teamName: String // Simulation league team name
        public let mlbTeam: String // Real life league team e.g. MLB

        public var fullName: String {
            return "\(firstName) \(lastName)"
        }
    }

    public func getDraftEntries() -> [DraftEntry] {

        let firstNameRow = 2
        let lastNameRow = 3
        let mlbTeamRow = 4 // Current MLB team
        let teamNameRow = 6

        var draftEntries = [DraftEntry]()

        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: true)

        while let row = csv.next() {
            guard row.count > teamNameRow else { continue }
            let firstName = row[firstNameRow]
            let lastName = row[lastNameRow]
            let teamName = row[teamNameRow]
            let mlbTeam = row[mlbTeamRow]


            let draftEntry = DraftEntry(firstName: firstName, lastName: lastName, teamName: teamName, mlbTeam: mlbTeam)

            draftEntries.append(draftEntry)
        }

        print("getDraftEntries count: \(draftEntries.count)")
        return draftEntries
    }

    public func getAuctionEntries() -> [AuctionEntry] {

        let firstNameRow = 0
        let lastNameRow = 1
        let auctionAmountRow = 2
        let teamNameRow = 3
        let teamNumberRow = 4
        let ottidRow = 5

        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: false)

        var auctionEntries = [AuctionEntry]()

        while let row = csv.next() {
            guard row.count > ottidRow,
                let teamNumber = Int(row[teamNumberRow]),
                let auctionAmount = Int(row[auctionAmountRow]),
                let ottid = Int(row[ottidRow]) else { continue }

            let firstName = row[firstNameRow]
            let lastName = row[lastNameRow]
            let teamName = row[teamNameRow]

            let auctionEntry = AuctionEntry(
                firstName: firstName,
                lastName: lastName,
                teamName: teamName,
                auctionAmount: auctionAmount,
                teamNumber: teamNumber,
                ottid: ottid
            )

            auctionEntries.append(auctionEntry)
        }

        return auctionEntries
    }
}
