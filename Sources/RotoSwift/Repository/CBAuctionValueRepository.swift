import Foundation
import CSV

/* Gets auction values for players from the C&B format */
public class CBAuctionValueRepository
{
	let filename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"

	func getAuctionValues() -> [PlayerKeeperPrice] {
        
		let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

		let csv = try! CSVReader(string: playerDataCSV,
		                         hasHeaderRow: false) // It must be true.

		var playerKeeperPrices = [PlayerKeeperPrice]()

		let nameTeamPositionRow = 0
		let auctionValueRow = 1

		while let row = csv.next() {
            let nameTeamPosition = row[nameTeamPositionRow]
            
			if let keeperPrice = Int(row[auctionValueRow]),
				let name = extractName(from: nameTeamPosition)
				{
                    let playerKeeperPrice = PlayerKeeperPrice(player: name, keeperPrice: keeperPrice)
					playerKeeperPrices.append(playerKeeperPrice)
				}
		}
        
        return playerKeeperPrices
	}

	func extractName(from nameTeamPosition: String) -> String? {
        let separatedArray = nameTeamPosition.components(separatedBy: ",")
        
        if let firstValue = separatedArray.first {
            
            // trim non alpha-numerics
            return firstValue.trimmingCharacters(in: .punctuationCharacters)
        }
        
		return nil
	}


}
