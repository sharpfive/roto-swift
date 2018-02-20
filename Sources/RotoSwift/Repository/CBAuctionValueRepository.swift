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
                    let playerKeeperPrice = PlayerKeeperPrice(player: name, keeperPrice: keeperPrice)
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
        var players = [Player]()
        
        var currentTeamName: String?
        
        while let row = csv.next() {
            let auctionString = row[auctionValueRow]
            
            if auctionString.contains("$$") {
                
                if let currentTeamName = currentTeamName {
                    let newTeam = Team(name:currentTeamName, players: players)
                    teams.append(newTeam)
                    players = [Player]()
                }
                currentTeamName = row[nameTeamPositionRow]
            } else {
                
                if let playerName = extractName(from: row[nameTeamPositionRow]) {
                    let newPlayer = Player(name: playerName)
                    players.append(newPlayer)
                }
            }
        }
        
        if let currentTeamName = currentTeamName {
            let newTeam = Team(name:currentTeamName, players: players)
            teams.append(newTeam)
            players = [Player]()
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
