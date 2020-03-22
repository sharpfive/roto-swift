import Foundation
import CSV

public class CouchManagerLeagueRespository {
    let filename: String

    public init(filename: String) {
        self.filename = filename
    }

    let firstNameRow = 0
    let lastNameRow = 1
    let auctionAmountRow = 2
    let teamNameRow = 3
    let teamNumberRow = 4
    let ottidRow = 5

    public struct AuctionEntry {
        let firstName: String
        let lastName: String
        let teamName: String
        let auctionAmount: Int
        let teamNumber: Int
        let ottid: Int // identifier?

        public var fullName: String {
            return "\(firstName) \(lastName)"
        }
    }

    public func getAuctionEntries() -> [AuctionEntry] {
        let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let csv = try! CSVReader(string: playerDataCSV,
                                 hasHeaderRow: false)

        var auctionEntries = [AuctionEntry]()

        while let row = csv.next() {
            guard let teamNumber = Int(row[teamNumberRow]),
                let auctionAmount = Int(row[auctionAmountRow]),
                let ottid = Int(row[ottidRow]) else { continue }

            let firstName = row[firstNameRow]
            let lastName = row[lastNameRow]
            let teamName = row[teamNameRow]

            let auctionEntry = AuctionEntry(
                firstName: firstName,
                lastName: lastName,
                teamName: teamName,
                auctionAmount: auctionAmount,
                teamNumber: teamNumber,
                ottid: ottid
            )

            auctionEntries.append(auctionEntry)
        }

        return auctionEntries
    }
}

/* Gets auction values for players from the C&B format */
public class CBAuctionValueRepository {
    let filename: String

    let nameTeamPositionRow = 0
    let auctionValueRow = 1

    public init(filename: String) {
        self.filename = filename
    }

	public func getAuctionValues() -> [PlayerKeeperPrice] {
		let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

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
