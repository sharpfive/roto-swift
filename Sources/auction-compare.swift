import CSV

// import Glibc (for linux builds)
import Darwin

print("auction-compare")

struct PlayerAuction {
    let name: String
    // let zScore: Double
    let auctionValue: Double
}

// Get League Values from CSV

let filename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"

let playerDataCSV = try String(contentsOfFile: filename, encoding: String.Encoding.ascii)

let csv = try! CSVReader(string: playerDataCSV,
                         hasHeaderRow: false) // It must be true.

var playerAuctionValues = [PlayerAuction]()

let nameTeamPositionRow = 0
let auctionValueRow = 1

while let row = csv.next() {
	if let auctionValue = Int(row[auctionValueRow]),
		let nameTeamPosition = row[nameTeamPositionRow]
		let name = extractName(from: nameTeamPosition)
		{
			let playerAuctionValue = PlayerAuctionValue(name:)
			playerAuctionValues.append()
		}
}

func extractName(from nameTeamPosition: String) {
	
}

// Get Fangraphs Hitter Values
// Get Fangraphs Pitcher Values

// Extract player names from C&BCSV

// Print out names that don't match