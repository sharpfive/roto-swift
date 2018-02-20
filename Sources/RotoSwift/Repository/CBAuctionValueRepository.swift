import Foundation
import CSV

/* Gets auction values for players from the C&B format */
public class CBAuctionValueRepository
{
	let filename = "/Users/jaim/Dropbox/roto/2018/projections/CB-auction-values-2018.csv"
    let nameTeamPositionRow = 0
    let auctionValueRow = 1
    
	func getAuctionValues() -> [PlayerKeeperPrice] {
        
		let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

		let csv = try! CSVReader(string: playerDataCSV,
		                         hasHeaderRow: false)

		var playerKeeperPrices = [PlayerKeeperPrice]()

		

		while let row = csv.next() {
            let nameTeamPosition = row[nameTeamPositionRow]
            
			if let keeperPrice = Int(row[auctionValueRow]),
				let name = extractName(from: nameTeamPosition)
				{
                    let playerKeeperPrice = PlayerKeeperPrice(name: name, keeperPrice: keeperPrice)
					playerKeeperPrices.append(playerKeeperPrice)
				}
		}
        
        return playerKeeperPrices
	}
    
    func getTeams() -> [Team] {
        
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)
        
        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: false)
        
        var teams = [Team]()
        var players = [PlayerKeeperPrice]()
        
        var currentTeamName: String?
        
        while let row = csv.next() {
            let auctionString = row[auctionValueRow]
            
            if auctionString.contains("$$") {
                
                if let currentTeamName = currentTeamName {
                    let newTeam = Team(name:currentTeamName, players: players)
                    teams.append(newTeam)
                    players = [PlayerKeeperPrice]()
                }
                currentTeamName = row[nameTeamPositionRow]
            } else {
                
                if let playerName = extractName(from: row[nameTeamPositionRow]),
                    let keeperPrice = Int(row[auctionValueRow]){
                    let newPlayer = PlayerKeeperPrice(name: playerName, keeperPrice: keeperPrice)
                    players.append(newPlayer)
                }
            }
        }
        
        if let currentTeamName = currentTeamName {
            let newTeam = Team(name:currentTeamName, players: players)
            teams.append(newTeam)
            players = [PlayerKeeperPrice]()
        }
        
        return teams
    }

	func extractName(from nameTeamPosition: String) -> String? {
        let separatedArray = nameTeamPosition.components(separatedBy: ",")
        
        if let firstValue = separatedArray.first {
            
            let trimCharacterSet = CharacterSet(charactersIn:"*")
            // trim non alpha-numerics
            let trimmedName = firstValue.trimmingCharacters(in: trimCharacterSet)
            
            if trimmedName.count == 0 {
                return nil
            } else {
                return trimmedName
            }
        }
        
		return nil
	}


}
