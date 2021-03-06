import Foundation
import CSV

struct PlayerMap {
    let fangraphsId: String
    let ottId: String
    let firstName: String
    let lastName: String
    let fullName: String
}

public protocol TwoPartNameHaving {
    var firstName: String { get }
    var lastName: String { get }
}

public protocol FullNameHaving {
    var fullName: String { get }
}

/* Gets auction values for players from the C&B format */
public class CBAuctionValueRepository: TeamRepository {
    let filename: String

    let nameTeamPositionRow = 0
    let auctionValueRow = 1

    public init(filename: String) {
        self.filename = filename
    }

	public func getAuctionValues() -> [PlayerKeeperPrice] {
		let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

		let csv = try! CSVReader(string: playerDataCSV,
		                         hasHeaderRow: false)

		var playerKeeperPrices = [PlayerKeeperPrice]()

		while let row = csv.next() {
            let nameTeamPosition = row[nameTeamPositionRow]

			if let keeperPrice = Int(row[auctionValueRow]),
				let name = extractName(from: nameTeamPosition) {
                    let playerKeeperPrice = PlayerKeeperPrice(name: name, keeperPrice: keeperPrice)
					playerKeeperPrices.append(playerKeeperPrice)
				}
		}

        return playerKeeperPrices
	}

    public func getTeams() -> [Team] {

        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: false)

        var teams = [Team]()
        var players = [PlayerKeeperPrice]()

        var currentTeamName: String?

        while let row = csv.next() {
            let auctionString = row[auctionValueRow]
            if auctionString.contains("$$") {
                if let currentTeamName = currentTeamName {
                    let newTeam = Team(name: currentTeamName, players: players)
                    teams.append(newTeam)
                    players = [PlayerKeeperPrice]()
                }
                currentTeamName = row[nameTeamPositionRow]
            } else {
                if let playerName = extractName(from: row[nameTeamPositionRow]),
                    let keeperPrice = Int(row[auctionValueRow]) {
                    let newPlayer = PlayerKeeperPrice(name: playerName, keeperPrice: keeperPrice)
                    players.append(newPlayer)
                }
            }
        }

        if let currentTeamName = currentTeamName {
            let newTeam = Team(name: currentTeamName, players: players)
            teams.append(newTeam)
            players = [PlayerKeeperPrice]()
        }

        return teams
    }

	func extractName(from nameTeamPosition: String) -> String? {
        let separatedArray = nameTeamPosition.components(separatedBy: ",")

        if let firstValue = separatedArray.first {

            let trimCharacterSet = CharacterSet(charactersIn: "*")
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
