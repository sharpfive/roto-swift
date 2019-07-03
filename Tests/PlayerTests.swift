//
//  PlayerTests.swift
//  LeagueRostersScrapeTests
//
//  Created by Jaim Zuber on 7/2/19.
//

import XCTest
@testable import RotoSwift

class PlayerTests: XCTestCase {
    let firstBase = League.Player(name: "Joe 1B",
                                  eligiblePositions: [League.FieldPosition.firstBase])
    let secondBaseOutfield = League.Player(name: "Jack 2B OF",
                                           eligiblePositions: [League.FieldPosition.secondBase,
                                                League.FieldPosition.outfield
                                                ])
    func testFirstBase() {
        XCTAssertTrue(firstBase.isEligible(for: League.FieldPosition.firstBase))
        XCTAssertFalse(firstBase.isEligible(for: League.FieldPosition.catcher))
        XCTAssertFalse(firstBase.isEligible(for: League.FieldPosition.secondBase))
        XCTAssertFalse(firstBase.isEligible(for: League.FieldPosition.thirdBase))
        XCTAssertFalse(firstBase.isEligible(for: League.FieldPosition.shortStop))
        XCTAssertFalse(firstBase.isEligible(for: League.FieldPosition.outfield))
        XCTAssertTrue(firstBase.isEligible(for: League.FieldPosition.designatedHitter))
    }

    func testSecondBaseOutfield() {
        XCTAssertFalse(secondBaseOutfield.isEligible(for: League.FieldPosition.firstBase))
        XCTAssertFalse(secondBaseOutfield.isEligible(for: League.FieldPosition.catcher))
        XCTAssertTrue(secondBaseOutfield.isEligible(for: League.FieldPosition.secondBase))
        XCTAssertFalse(secondBaseOutfield.isEligible(for: League.FieldPosition.thirdBase))
        XCTAssertFalse(secondBaseOutfield.isEligible(for: League.FieldPosition.shortStop))
        XCTAssertTrue(secondBaseOutfield.isEligible(for: League.FieldPosition.outfield))
        XCTAssertTrue(secondBaseOutfield.isEligible(for: League.FieldPosition.designatedHitter))
    }

}
