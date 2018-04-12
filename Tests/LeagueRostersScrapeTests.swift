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
        let league = createLeague()
        
        XCTAssertEqual(league.teams.count, 12)
    }
    
    func testWestCalhounExists() throws {
        let league = createLeague()
        
        XCTAssertTrue(league.teams.contains(where: {$0.name == "WEST CALHOUN FADEAWAY"}))
    }
    
    func testWestCalhounHas23Players() throws {
        let league = createLeague()
        
        let westCalhoun = league.teams.first(where: {$0.name == "WEST CALHOUN FADEAWAY"})
        
        XCTAssertEqual(westCalhoun?.players.count, 24)
    }
    
    func testSouthWestSnakeOilers() throws {
        let team = getTeam(named: "SOUTHWEST SNAKE OILERS")
        XCTAssertEqual(team.name, "SOUTHWEST SNAKE OILERS")
    }
    
    func testSouthwestHas27Players() throws {
        let team = getTeam(named: "SOUTHWEST SNAKE OILERS")
        XCTAssertEqual(team.players.count, 27)
    }
    
    func getTeam(named name: String) -> League.Team {
        let league = createLeague()
        return league.teams.first(where: {$0.name == name})!
    }
    
    func createLeague() -> League {
        let filename = "/Users/jaim/code/xcode/roto-swift/data/2017-espn.roster.txt"
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        return league
    }
}
