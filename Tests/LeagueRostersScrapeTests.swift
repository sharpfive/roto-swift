//
//  LeagueRostersScrapeTests.swift
//  RotoSwiftPackageDescription
//
//  Created by Jaim Zuber on 4/1/18.
//

import Foundation
import XCTest

import RotoSwift

class LeagueRostersScrapeTests: XCTestCase {
    
    func testNumberOfTeamsIsTwelve() throws {
        let filename = "/Users/jaim/code/roto-swift/data/2017-espn.roster.txt"
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        
        XCTAssertEqual(league.teams.count, 12)
    }
    
    func testWestCalhounExists() throws {
        let filename = "/Users/jaim/code/roto-swift/data/2017-espn.roster.txt"
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        
        XCTAssertTrue(league.teams.contains(where: {$0.name == "WEST CALHOUN FADEAWAY"}))
    }
    
    func testWestCalhounHas23Players() throws {
        let filename = "/Users/jaim/code/roto-swift/data/2017-espn.roster.txt"
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        
        let westCalhoun = league.teams.first(where: {$0.name == "WEST CALHOUN FADEAWAY"})
        
        XCTAssertEqual(westCalhoun?.players.count, 23)
    }
}
