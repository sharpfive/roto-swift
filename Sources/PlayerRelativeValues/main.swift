import Foundation
import CSV
import RotoSwift

func processRelativeValues(cbPathString: String, fangraphsHitterPathString: String, fangraphsPitcherPathString: String) {
    let auctionRepository = CBAuctionValueRepository(filename: cbPathString)
    let keeperValues = auctionRepository.getAuctionValues()
    
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterPathString, pitcherFilename: fangraphsPitcherPathString)
    let projectedValues = fangraphsRepository.getAuctionValues()
    
    let playerRelativeValues = joinRelativeValues(playerKeeperPrices: keeperValues, playerAuctions: projectedValues)
    
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

print("PlayerRelativeValues")

let cbFilename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"

let fangraphsHitterFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-hitters-1.csv"

let fangraphsPitcherFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-pitchers.csv"

processRelativeValues(cbPathString: cbFilename, fangraphsHitterPathString: fangraphsHitterFilename, fangraphsPitcherPathString: fangraphsPitcherFilename)
