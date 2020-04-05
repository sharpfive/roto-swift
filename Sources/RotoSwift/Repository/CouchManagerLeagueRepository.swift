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

    let firstNameRow = 0
    let lastNameRow = 1
    let auctionAmountRow = 2
    let teamNameRow = 3
    let teamNumberRow = 4
    let ottidRow = 5

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

    public func getAuctionEntries() -> [AuctionEntry] {
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

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
