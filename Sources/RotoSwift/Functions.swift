//
//  processRelativeValues.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/19/18.
//

import Foundation
import CSV

// import Glibc (for linux builds)
import Darwin

func processRelativeValues() {
    let auctionRepository = CBAuctionValueRepository()
    let keeperValues = auctionRepository.getAuctionValues()
    
    let fangraphsRepository = FanGraphsAuctionRepository()
    let projectedValues = fangraphsRepository.getAuctionValues()
    
    var playerRelativeValues = [PlayerRelativeValue]()
    
    keeperValues.forEach { nameKeeperValue in
        
        let fangraphPlayer = projectedValues.first(where: { $0.name == nameKeeperValue.name})
        
        if let fangraphPlayer = fangraphPlayer {
            let playerRelativeValue = PlayerRelativeValue(name: nameKeeperValue.name, keeperPrice: nameKeeperValue.keeperPrice, projectedAuctionValue: fangraphPlayer.auctionValue )
            
            playerRelativeValues.append(playerRelativeValue)
        } else {
            print("Can't find \(String(describing: nameKeeperValue))")
        }
    }
    
    // Output to csv
    let csvOutputFilename = "/Users/jaim/Dropbox/roto/2018/projections/relative-values-2018.csv"
    let stream = OutputStream(toFileAtPath:csvOutputFilename, append:false)!
    let csvWriter = try! CSVWriter(stream: stream)
    
    try! csvWriter.write(row: ["name", "keeperPrice", "projectedAuctionValue", "relativeValue"])
    
    playerRelativeValues.sorted(by: { $0.relativeValue > $1.relativeValue } ).forEach { playerRelativeValue in
        
        // output to CSV
        csvWriter.beginNewRow()
        try! csvWriter.write(row: [
            playerRelativeValue.name,
            String(playerRelativeValue.keeperPrice),
            String(playerRelativeValue.projectedAuctionValue),
            String(playerRelativeValue.relativeValue)
            ])
    }
    
    csvWriter.stream.close()
}

func processTeams() {
    let auctionRepository = CBAuctionValueRepository()
    let teams = auctionRepository.getTeams()
    
    teams.forEach {
        print("\($0)")
    }
}

func processTeamsWithRelativeValues() -> [Team] {
    let auctionRepository = CBAuctionValueRepository()
    let teams = auctionRepository.getTeams()
    return teams
}

