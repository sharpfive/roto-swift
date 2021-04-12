//
//  RosterBuilder.swift
//  CSV
//
//  Created by Jaim Zuber on 4/20/19.
//

import Foundation

public enum CSVFormat {
    case fangraphs
    case rotoswift
}

public func buildLeague(with filename: String) -> League {
    let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)
    let repository = ESPNLeagueRostersRepository2019()
    let leagueRosters = repository.getLeagueRosters(from: leagueRostersDataString)
    return leagueRosters
}

public func buildPlayerAuctionValuesArray(hitterFilename: String?, pitcherFilename: String?, csvFormat: CSVFormat = .fangraphs) -> [PlayerAuction] {
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)

    if csvFormat == .rotoswift {
        fangraphsRepository.auctionFieldValue = "AuctionValue"
        fangraphsRepository.nameFieldValue = "name"
    }
    let projectedValues = fangraphsRepository.getAuctionValues()
    return projectedValues
}
