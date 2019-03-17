//
//  processRelativeValues.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/19/18.
//

import Foundation
import CSV

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let cbFilename = "/Users/jaim/Dropbox/roto/2019/C&B-Keeper-Values-2019-Sheet1-final.csv"

let hitterFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-batters-2019-03-16.csv"

let pitcherFilename = "/Users/jaim/Dropbox/roto/2019/projections/FanGraphs-pitchers-2019-03-16.csv"

public func joinRelativeValues(playerKeeperPrices: [PlayerKeeperPrice], playerAuctions: [PlayerAuction]) -> [PlayerRelativeValue] {
    
    var playerRelativeValues = [PlayerRelativeValue]()
    
    playerKeeperPrices.forEach { nameKeeperValue in
        
        let fangraphPlayer = playerAuctions.first(where: { $0.name == nameKeeperValue.name})
        
        if let fangraphPlayer = fangraphPlayer {
            let playerRelativeValue = PlayerRelativeValue(name: nameKeeperValue.name, keeperPrice: nameKeeperValue.keeperPrice, projectedAuctionValue: fangraphPlayer.auctionValue )
            
            playerRelativeValues.append(playerRelativeValue)
        } else {
            print("Can't find \(String(describing: nameKeeperValue))")
        }
    }
    
    return playerRelativeValues
}

func processRelativeValues() {
    let auctionRepository = CBAuctionValueRepository(filename: cbFilename)
    let keeperValues = auctionRepository.getAuctionValues()
    
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()
    
    let playerRelativeValues = joinRelativeValues(playerKeeperPrices: keeperValues, playerAuctions: projectedValues)
    
    // Output to csv
    let csvOutputFilename = "/Users/jaim/Dropbox/roto/2019/projections/relative-values-2019.csv"
    let stream = OutputStream(toFileAtPath:csvOutputFilename, append:false)!
    let csvWriter = try! CSVWriter(stream: stream)
    
    try! csvWriter.write(row: ["name", "keeperPrice", "projectedAuctionValue", "relativeValue"])
    
    playerRelativeValues.sorted(by: { $0.relativeValue > $1.relativeValue } ).forEach { playerRelativeValue in
        
        // output to CSV
        csvWriter.beginNewRow()
        try! csvWriter.write(row: [
            playerRelativeValue.name,
            String(playerRelativeValue.keeperPrice),
            String(playerRelativeValue.projectedAuctionValue),
            String(playerRelativeValue.relativeValue)
            ])
    }
    
    csvWriter.stream.close()
}

func processTeams() {
    let auctionRepository = CBAuctionValueRepository(filename: cbFilename)
    let teams = auctionRepository.getTeams()
    
    
    
    teams.forEach {
        print("\($0)")
    }
}

public func processTeamsWithRelativeValues() -> [Team] {
    let auctionRepository = CBAuctionValueRepository(filename: cbFilename)
    let teams = auctionRepository.getTeams()
    
    let fangraphsRepository = FanGraphsAuctionRepository(hitterFilename: hitterFilename, pitcherFilename: pitcherFilename)
    let projectedValues = fangraphsRepository.getAuctionValues()
    
    let valueTeams: [TeamPlayerRelativeValue] = teams.map { team in
        // convert to relative value and add to team
        let playerRelativeValues = joinRelativeValues(playerKeeperPrices: team.players, playerAuctions: projectedValues)
        
        return TeamPlayerRelativeValue(name: team.name, players: playerRelativeValues)
    }
    
    let teamKeeperRankings: [(String, Double)] = valueTeams.map { valueTeam in
        print("name:\(valueTeam.name)")
        
        let valueablePlayers = valueTeam.players.filter { player in
            player.relativeValue > 0
        }
        
        valueablePlayers.sorted(by: {$0.relativeValue > $1.relativeValue})
            .forEach { player in
            print("   player:\(player.name) - value: \(player.relativeValue)")
            }
        
        let totalTeamValue: Double = valueablePlayers.map{ player in
            return player.relativeValue
        }.reduce(0.0, +)
        
        //print("total team value: \(totalTeamValue)")
        
        return (valueTeam.name, totalTeamValue)
    }
    
    teamKeeperRankings.sorted(by:{ $0.1 > $1.1 }).forEach { tuple in
        print("team: \(tuple.0) - keeper ranking:\(tuple.1)")
    }
    return teams
}

func calculateProjections() {
    let filename = "/Users/jaim/code/roto-swift/data/fg-2017-projections.csv"
    
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)
    
    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true) // It must be true.
    
    enum batterFields: String {
        case homeRuns = "HR"
        case name = "Name"
        case runs = "R"
        case runsBattedIn = "RBI"
        case onBasePercentage = "OBP"
        case steals = "SB"
    }
    
    let headerRow = csv.headerRow!
    
    print(headerRow)
    let homeRunsRowOptional = headerRow.index(of: batterFields.homeRuns.rawValue)
    let nameRowOptional:Int? = 0
    let runsRowOptional = headerRow.index(of: batterFields.runs.rawValue)
    let onBasePercentageRowOptional = headerRow.index(of: batterFields.onBasePercentage.rawValue)
    let stolenBasesRowOptional = headerRow.index(of: batterFields.steals.rawValue)
    let runsBattedInRowOptional = headerRow.index(of: batterFields.runsBattedIn.rawValue)
    
    guard let homeRunsRow = homeRunsRowOptional,
        let nameRow = nameRowOptional,
        let runsRow = runsRowOptional,
        let stolenBasesRow = stolenBasesRowOptional,
        let onBasePercentageRow = onBasePercentageRowOptional,
        let runsBattedInRow = runsBattedInRowOptional else {
            print("Unable to determine rows")
            //print("hrRow:\(String(describing:hrRowOptional)) - nameRow:\(String(describing:nameRowOptional))")
            exit(0)
    }
    
    var batters = [Batter]()
    
    while let row = csv.next() {
        if let homeRuns = Int(row[homeRunsRow]),
            let runs = Int(row[runsRow]),
            let onBasePercentage = Double(row[onBasePercentageRow]),
            let stolenBases = Int(row[stolenBasesRow]),
            let runsBattedIn = Int(row[runsBattedInRow])
        {
            let batter = Batter(name: row[nameRow], homeRuns: homeRuns, runs: runs, onBasePercentage: onBasePercentage, stolenBases: stolenBases, runsBattedIn: runsBattedIn)
            batters.append(batter)
        }
        
    }
    
    let numberOfTeams = 12
    let playersPerTeam = 24
    let numberOfPlayers = numberOfTeams * playersPerTeam
    let numberOfHitters = numberOfPlayers / 2
    let hittersPerTeam = 12
    
    // let auctionDollarsAvailable = 260
    let hitterAuctionDollarsAvailable = 130
    
    // Estimate of the player position that will be drafted at league minimum
    let replacementLevelBatterPosition = numberOfHitters - 3*numberOfTeams
    
    let batterPoolCount = hittersPerTeam * numberOfTeams
    
    let endIndex = min(batterPoolCount, batters.count)
    
    
    let batterPool = Array(batters[0..<endIndex])
    
    batterPool.forEach { (batter) in
        //print(batter)
    }
    
    print("\(batterPool.count) batters found")
    let homeRunsStandardDeviation = standardDeviation(for: batterPool.map{ $0.homeRuns})
    let meanHomeRuns = calculateMean(for: batterPool.map{ $0.homeRuns})
    print("HR standard deviation = \(homeRunsStandardDeviation) - Mean \(meanHomeRuns)")
    
    let runsStandardDeviation = standardDeviation(for: batterPool.map {$0.runs})
    let meanRuns = calculateMean(for: batterPool.map{ $0.runs})
    print("Runs standard deviation = \(runsStandardDeviation) - Mean \(meanRuns)")
    
    let runsBattedInStandardDeviation = standardDeviation(for: batterPool.map {$0.runsBattedIn})
    let meanRunsBattedIn = calculateMean(for: batterPool.map{ $0.runsBattedIn})
    print("RBI's deviation = \(runsBattedInStandardDeviation) - Mean \(meanRunsBattedIn)")
    
    let onBasePercentageStandardDeviation = standardDeviation(for: batterPool.map {$0.onBasePercentage})
    let meanOnBasePercentage = calculateMean(for: batterPool.map{ $0.onBasePercentage})
    print("OBP deviation = \(onBasePercentageStandardDeviation) - Mean \(meanOnBasePercentage)")
    
    let stolenBasesStandardDeviation = standardDeviation(for: batterPool.map {$0.stolenBases})
    let meanStolenBases = calculateMean(for: batterPool.map {$0.stolenBases})
    print("SB deviation = \(stolenBasesStandardDeviation) - Mean \(meanStolenBases)")
    
    //calculate Z scores
    let zScores = batterPool.map { batter in
        (batter.name,
         calculateZScore(value: batter.homeRuns, mean: meanHomeRuns, standardDeviation: homeRunsStandardDeviation) + // HR
            calculateZScore(value: batter.runs, mean: meanRuns, standardDeviation: runsStandardDeviation) + // R
            calculateZScore(value: batter.runsBattedIn, mean: meanRunsBattedIn, standardDeviation: runsBattedInStandardDeviation) + // RBI
            calculateZScore(value: batter.onBasePercentage, mean: meanOnBasePercentage, standardDeviation: onBasePercentageStandardDeviation),
         calculateZScore(value: batter.stolenBases, mean: meanStolenBases, standardDeviation: stolenBasesStandardDeviation) //SB
        )
        }.sorted(by: { return $0.1 > $1.1 })
    
    enum IntParsingError: Error {
        case overflow
        case invalidInput(String)
    }
    
    // The lowest total z-score player is replacement level
    if zScores.last == nil {
        print("Unable to get worst batter")
        return
    }
    
    let replacementBatter = zScores[replacementLevelBatterPosition]
    
    let replacementZScore = replacementBatter.1
    
    // subtract total-z-scores for each player from the replacement-z-score
    let adjustedBatters = zScores.map {
        ($0.0,
         $0.1 - replacementZScore
        )
    }
    
    // calculate and add z scores for all positions (total z-score)
    let totalZScores = adjustedBatters.map { $0.1}.reduce(0,+)
    
    // calculate the total amount of auction money
    let hitterAuctionMoney = numberOfTeams * hitterAuctionDollarsAvailable
    
    print("totalZScores - \(totalZScores)")
    print("hitterAuctionMoney - \(hitterAuctionMoney)")
    
    let playersAuctions: [PlayerAuction] = adjustedBatters.map { batter in
        let batterZScore = batter.1
        let auctionAmount = batterZScore / totalZScores * Double(hitterAuctionMoney)
        return PlayerAuction(name: batter.0, zScore: batterZScore, auctionValue: auctionAmount)
    }
    
    playersAuctions.forEach { playerAuction in
        print("\(playerAuction.name) - \(playerAuction.zScore) - \(playerAuction.auctionValue)")
    }
    
    let asdf = playersAuctions.map { $0.auctionValue}.reduce(0,+)
    print("playersAuctions: \(asdf)")
    
    // calculate the percentage of z-score a player has
    
    
    // use the percentage of z-score to determine the players total value (total-auction-pool & z-percentage)

}

