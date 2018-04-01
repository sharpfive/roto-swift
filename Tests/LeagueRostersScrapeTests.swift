//
//  LeagueRostersScrapeTests.swift
//  RotoSwiftPackageDescription
//
//  Created by Jaim Zuber on 4/1/18.
//

import Foundation
import XCTest

class LeagueRostersScrapeTests: XCTestCase {
    func testCreatingFile() throws {
        
        XCTAssertNotNil(nil)
    }
    
    func testCreatingFile2() throws {
        let filename = "/Users/jaim/code/roto-swift/data/2017-espn.roster.txt"
        
        let repository = ESPNLeagueRostersRepository()
        let league = repository.getLeagueRosters(for: filename)
        
        XCTAssertEquals(league.teams, 12)
    }
}
