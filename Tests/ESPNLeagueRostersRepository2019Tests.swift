//
//  ESPNLeagueRostersRepository2019Tests.swift
//  LeagueRostersScrapeTests
//
//  Created by Jaim Zuber on 7/1/19.
//

import XCTest
import RotoSwift

class ESPNLeagueRostersRepository2019Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNumberOfTeamsIsTwelveVersionOne() throws {
        let league = createLeague(with: "data/ESPN-rosters-2019-07-01.txt")

        XCTAssertEqual(league.teams.count, 12)
    }

    func testAllTeamsHavePlayers() throws {
        let league = createLeague(with: "data/ESPN-rosters-2019-07-01.txt")
        league.teams.forEach { team in
            XCTAssertFalse(team.players.isEmpty)
        }
    }

    func testTeamOneHasPeteAlonso() {
        let league = createLeague(with: "data/ESPN-rosters-2019-07-01.txt")
        XCTAssertTrue(league.teams.first?.players.contains { $0.name == "Pete Alonso" } == true)
    }

    func testJonathanVillarExists() {
        let league = createLeague(with: "data/ESPN-rosters-2019-07-01.txt")
        let villar = findPlayer(inLeague: league, named: "Jonathan Villar")
        XCTAssertNotNil(villar)
    }

    func testJonathanVillarPlaysTwoPositions() {
        let league = createLeague(with: "data/ESPN-rosters-2019-07-01.txt")
        let villar = findPlayer(inLeague: league, named: "Jonathan Villar")
        XCTAssertEqual(villar?.eligiblePositions.count, 2)
    }

    func findPlayer(inLeague league: League, named name: String) -> League.Player? {
        let allPlayers = league.teams.flatMap { $0.players }

        return allPlayers.first { player in
            player.name == name
        }
    }

    func createLeague(with filename: String, version: Int? = nil) -> League {
        let repository = ESPNLeagueRostersRepository2019()
        let leagueRostersDataString = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

        let league = repository.getLeagueRosters(from: leagueRostersDataString)
        return league
    }
}
