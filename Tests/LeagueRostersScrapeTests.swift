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
        let league = createLeague(with: "data/2017-espn.roster.txt")
        
        XCTAssertEqual(league.teams.count, 12)
    }
    
    func testWestCalhounExists() throws {
        let league = createLeague(with: "data/2017-espn.roster.txt")
        
        XCTAssertTrue(league.teams.contains(where: {$0.name == "WEST CALHOUN FADEAWAY"}))
    }
    
    func testWestCalhounHas23Players() throws {
        let league = createLeague(with: "data/2017-espn.roster.txt")
        
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
    
    func testProjectionsExist() throws {

        let auctionValues = getProjections()
        
        XCTAssert(auctionValues.count > 0)
    }
    
    func findBestFreeAgent() throws {
        let league = createLeague(with: "data/2018-08-12-espn-roster-cb.txt")
        //data/fg-2017-projections.csv
        //let projections =
    }
    
    func getProjections() -> [PlayerAuction] {
        let hitterFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-hitters-1.csv"
        let pitcherFilename = "/Users/jaim/Dropbox/roto/2018/projections/2018-pitchers.csv"
        
        let auctionRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
        
        let auctionValues = auctionRepository.getAuctionValues()
        
        return auctionValues
    }
    
    func getTeam(named name: String) -> League.Team {
        let league = createLeague(with: "data/2017-espn.roster.txt")
        return league.teams.first(where: {$0.name == name})!
    }
    
    func createLeague(with filename: String) -> League {
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        return league
    }
}
