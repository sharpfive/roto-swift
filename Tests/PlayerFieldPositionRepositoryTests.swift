//
//  PlayerFieldPositionRepositoryTests.swift
//  LeagueRostersScrapeTests
//
//  Created by Jaim Zuber on 7/2/19.
//

import XCTest
@testable import RotoSwift

class PlayerFieldPositionRepositoryTests: XCTestCase {
    enum TestError: Error {
        case unexpectedNilError
    }

    var repository: PlayerFieldPositionRepository!
    var players: [League.Player]!

    let playerDataFilenameString = "data/FanGraphs-batters-2019-03-16.csv"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        repository = PlayerFieldPositionRepository()
        players = try! repository.getPlayers(from: playerDataFilenameString)
    }


    func testHasPlayers() throws {
        XCTAssertFalse(players.isEmpty)
    }

    func testPlayerCountIs500() throws {
        // one player is PR/PH, we don't need to handle that case
        XCTAssertEqual(players.count, 499)
    }
}
