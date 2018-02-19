//
//  FanGraphsAuctionRepository.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation
import CSV

public class FanGraphsAuctionRepository
{
    let hitterFileName = "/Users/jaim/Dropbox/roto/2018/projections/2018-hitters-1.csv"
    let pitcherFileNamae = "/Users/jaim/Dropbox/roto/2018/projections/2018-pitchers.csv"
    
    enum auctionFields: String {
        case name = "ï»¿\"PlayerName\""
        case projectedAuctionValue = "Dollars"
    }
    
    func getAuctionValues() -> [PlayerAuction] {
        
        return getAuctionValues(for: hitterFileName) + getAuctionValues(for:pitcherFileNamae)
    }

    func getAuctionValues(for filename: String) -> [PlayerAuction] {
        
            let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)
        
            let csv = try! CSVReader(string: playerDataCSV,
                                     hasHeaderRow: true) // It must be true.
            let headerRow = csv.headerRow!
            let nameRowOptional = headerRow.index(of: auctionFields.name.rawValue)
        
            let projectedAuctionValueRowOptional = headerRow.index(of: auctionFields.projectedAuctionValue.rawValue)
        
            guard let nameRow = nameRowOptional,
                let projectedAuctionValueRow = projectedAuctionValueRowOptional

                else {
                    print("Unable to find rows")
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
                    
                    playerAuctions.append( PlayerAuction(name: name, zScore: 0.0, auctionValue: projectedAuctionValue))
                } else {
                    print("rejecting: \(trimmedString)")
                }
            }
        
        return playerAuctions
    }
}
