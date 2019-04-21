//
//  RosterBuilder.swift
//  CSV
//
//  Created by Jaim Zuber on 4/20/19.
//

import Foundation
import RotoSwift

public func buildLeague(with filename: String) -> League {
    let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)
    let repository = ESPNLeagueRostersRepository2019()
    let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)
    return leagueRosters
}

public func buildPlayerAuctionValuesArray(hitterFilename: String, pitcherFilename: String) -> [PlayerAuction] {
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()
    return projectedValues
}
