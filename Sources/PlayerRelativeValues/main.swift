import Foundation
import CSV
import RotoSwift

func processRelativeValues(cbPathString: String, fangraphsHitterPathString: String, fangraphsPitcherPathString: String, outputPathString: String) {
    let auctionRepository = CBAuctionValueRepository(filename: cbPathString)
    let keeperValues = auctionRepository.getAuctionValues()
    
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterPathString, pitcherFilename: fangraphsPitcherPathString)
    let projectedValues = fangraphsRepository.getAuctionValues()
    
    let playerRelativeValues = joinRelativeValues(playerKeeperPrices: keeperValues, playerAuctions: projectedValues)
    
    // Output to csv
    let stream = OutputStream(toFileAtPath:outputPathString, append:false)!
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

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

print("PlayerRelativeValues")

let cbFilename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"

let fangraphsHitterFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-03-10.fangraphs.batters-60.csv"

let fangraphsPitcherFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-03-10.fangraphs.pitchers-60.csv"

let dateString = Date().toString(dateFormat: "yyyy-MM-dd-HH:mm:ss")

let outputFile = "/Users/jaim/Dropbox/roto/2018/projections/\(dateString)-relative-values-2018.csv"

processRelativeValues(cbPathString: cbFilename, fangraphsHitterPathString: fangraphsHitterFilename, fangraphsPitcherPathString: fangraphsPitcherFilename, outputPathString: outputFile)
