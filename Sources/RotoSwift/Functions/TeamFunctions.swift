import Foundation

func processTeams(at auctionValueFilename: String) {
    let auctionRepository = CBAuctionValueRepository(filename: auctionValueFilename)
    let teams = auctionRepository.getTeams()

    teams.forEach {
        print("\($0)")
    }
}

public func processTeamsWithRelativeValues(auctionValuesFilename: String, fangraphsHitterFilename: String, fangraphsPitcherFilename: String) -> [Team] {

    // If this is true, we calculate which players are still valuable. If false, we use the list as-is
    let estimateKeepers = true

    let auctionRepository = CBAuctionValueRepository(filename: auctionValuesFilename)
    let teams = auctionRepository.getTeams()

    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterFilename, pitcherFilename: fangraphsPitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()

    let valueTeams: [TeamPlayerRelativeValue] = teams.map { team in
        // convert to relative value and add to team
        let playerRelativeValues = joinRelativeValues(playerKeeperPrices: team.players, playerAuctions: projectedValues)

        return TeamPlayerRelativeValue(name: team.name, players: playerRelativeValues)
    }

    /// This calculates a moneyFactor to determine how "valuable" auction money is. If there are a bunch of players whose worth is 
    /// greater than that they are being paid, there is effective more money in the auction pool. This raises the prices of free agents
    /// so Having $$$ in hand won't get you the same value 
    let totalPositiveRelativeValue: Double = valueTeams.flatMap { $0.players }
                                               .filter { estimateKeepers ? $0.relativeValue > 0 : true }
                                               .map { $0.relativeValue }
                                               .reduce(0.0,+)

    print("totalPositiveRelativeValue: \(totalPositiveRelativeValue)")
    let moneyPool = Double(260 * 12)
    let moneyFactor = moneyPool / (totalPositiveRelativeValue + moneyPool)

    print("moneyFactor: \(moneyFactor)")


    let teamKeeperRankings: [(String, Double, Double)] = valueTeams.map { valueTeam in
        print("name: \(valueTeam.name)")

        // Show all players
        let teamPlayers = valueTeam.players

        func calculateValue(for playerRelativeValue: PlayerRelativeValue) -> Double {
            return playerRelativeValue.effectiveValue
        }

        // only show players with positive value
        // let valueablePlayers = valueTeam.players.filter { player in
        //     player.relativeValue > 0
        // }

        // teamPlayers.forEach {
        //     print("name: \($0.name) - av: \($0.projectedAuctionValue) - rv \($0.relativeValue) valueFactor: \(($0.projectedAuctionValue + $0.relativeValue) / abs($0.projectedAuctionValue))")
        // }

        let valueablePlayers: [PlayerRelativeValue]
        if estimateKeepers {
            valueablePlayers = teamPlayers.filter { ($0.projectedAuctionValue + $0.relativeValue) / abs($0.projectedAuctionValue) > moneyFactor }
        } else {
            valueablePlayers = teamPlayers
        }


        valueablePlayers.sorted(by: {calculateValue(for: $0)  > calculateValue(for: $1) })
            .forEach { player in
                print("   player:\(player.name) - value: \(calculateValue(for: player)) - relativeValue: \(player.relativeValue) - projectedAuctionValue: \(player.projectedAuctionValue)")
        }

        print("valuablePlayers count: \(valueablePlayers.count)")
        let totalValuableSalary = valueablePlayers.map { $0.keeperPrice }.reduce(0,+)
        let leftoverMoney: Double = 260.0 - Double(totalValuableSalary)

        let totalTeamValue: Double = valueablePlayers.map { player in
            // limit the penalty for a keeper to their keeper price
            // return max(player.relativeValue, Double(player.keeperPrice * -1))
            return max(player.projectedAuctionValue, 0)
            }.reduce(0.0, +)

        //print("total team value: \(totalTeamValue)")



        return (valueTeam.name, totalTeamValue, leftoverMoney)
    }

    teamKeeperRankings.sorted(by: { $0.1 + $0.2 * moneyFactor > $1.1 + $1.2 * moneyFactor }).forEach { tuple in
        print("team: \(tuple.0) - totalTeamValue: \(tuple.1) -  leftoverMoney: \(tuple.2) - powerRanking: \(tuple.1 + tuple.2 * moneyFactor)")
    }
    return teams
}
