import Foundation
import CSV

/* Gets auction values for players from the C&B format */
public class CBAuctionValueRepository
{
	let filename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"

	func getAuctionValues() -> [NameAuction] {
		let playerDataCSV = try String(contentsOfFile: filename, encoding: String.Encoding.ascii)

		let csv = try! CSVReader(string: playerDataCSV,
		                         hasHeaderRow: false) // It must be true.

		var playerAuctionValues = [NameAuction]()

		let nameTeamPositionRow = 0
		let auctionValueRow = 1

		while let row = csv.next() {
			if let auctionValue = Int(row[auctionValueRow]),
				let nameTeamPosition = row[nameTeamPositionRow],
				let name = extractName(from: nameTeamPosition)
				{
                    let playerAuctionValue = PlayerAuctionValue(name: name, auctionValue: auctionValue)
					playerAuctionValues.append(playerAuctionValue)
				}
		}
	}

	func extractName(from nameTeamPosition: String) -> String {
		return ""
	}


}
