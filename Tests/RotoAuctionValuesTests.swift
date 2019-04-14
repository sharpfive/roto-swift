//
//  RotoAuctionValuesTests.swift
//  LeagueRostersScrapeTests
//
//  Created by Jaim Zuber on 4/14/19.
//

import XCTest
@testable import RotoSwift

class RotoAuctionValuesTests: XCTestCase {

    static let filename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-12/Zips-projections-ros-batters.csv"

    let batters = convertFileToBatters(filename: filename)

    override func setUp() {
    }

    override func tearDown() {
    }

    func testNumberOfPlayersIsX() {
        XCTAssert(batters.count == 405)
    }

    func testFirstPlayerIsTrout() {
        let firstBatter = batters.first
        XCTAssertEqual("Mike Trout", firstBatter?.name)
    }

    func testLastPlayerIsGore() {
        let firstBatter = batters.last
        XCTAssertEqual("Terrance Gore", firstBatter?.name)
    }
}
