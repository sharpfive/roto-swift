import Foundation

func processTeams(at auctionValueFilename: String) {
    let auctionRepository = CBAuctionValueRepository(filename: auctionValueFilename)
    let teams = auctionRepository.getTeams()

    teams.forEach {
        print("\($0)")
    }
}

public func processTeamsWithRelativeValues(auctionValuesFilename: String, fangraphsHitterFilename: String, fangraphsPitcherFilename: String) -> [Team] {
    let auctionRepository = CBAuctionValueRepository(filename: auctionValuesFilename)
    let teams = auctionRepository.getTeams()

    print("teams: \(teams.count)")
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: fangraphsHitterFilename, pitcherFilename: fangraphsPitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()

    let valueTeams: [TeamPlayerRelativeValue] = teams.map { team in
        // convert to relative value and add to team
        let playerRelativeValues = joinRelativeValues(playerKeeperPrices: team.players, playerAuctions: projectedValues)

        return TeamPlayerRelativeValue(name: team.name, players: playerRelativeValues)
    }

    let teamKeeperRankings: [(String, Double)] = valueTeams.map { valueTeam in
        print("name: \(valueTeam.name)")

        // Show all players
        let valueablePlayers = valueTeam.players

        func calculateValue(for playerRelativeValue: PlayerRelativeValue) -> Double {
            return playerRelativeValue.relativeValue
        }

        // only show players with positive value
        // let valueablePlayers = valueTeam.players.filter { player in
        //     player.relativeValue > 0
        // }

        valueablePlayers.sorted(by: {calculateValue(for: $0)  > calculateValue(for: $1) })
            .filter { calculateValue(for: $0) > 0 }
            .forEach { player in
                print("   player:\(player.name) - value: \(calculateValue(for: player))")
        }

        let totalTeamValue: Double = valueablePlayers.map { player in
            // limit the penalty for a keeper to their keeper price
            // return max(player.relativeValue, Double(player.keeperPrice * -1))
            return max(calculateValue(for: player), 0)
            }.reduce(0.0, +)

        //print("total team value: \(totalTeamValue)")

        return (valueTeam.name, totalTeamValue)
    }

    teamKeeperRankings.sorted(by: { $0.1 > $1.1 }).forEach { tuple in
        print("team: \(tuple.0) - keeper ranking:\(tuple.1)")
    }
    return teams
}
