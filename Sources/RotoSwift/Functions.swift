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
            let playerRelativeValue = PlayerRelativeValue(name: nameKeeperValue.name,
                                                          keeperPrice: nameKeeperValue.keeperPrice,
                                                          projectedAuctionValue: fangraphPlayer.auctionValue)
            
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
        
        // Show all players
        let valueablePlayers = valueTeam.players

        // only show players with positive value
        // let valueablePlayers = valueTeam.players.filter { player in
        //     player.relativeValue > 0
        // }
        
        valueablePlayers.sorted(by: {$0.relativeValue > $1.relativeValue})
            .forEach { player in
            print("   player:\(player.name) - value: \(player.relativeValue)")
            }
        
        let totalTeamValue: Double = valueablePlayers.map { player in
            // limit the penalty for a keeper to their keeper price
            return max(player.relativeValue, Double(player.keeperPrice * -1))
        }.reduce(0.0, +)
        
        //print("total team value: \(totalTeamValue)")
        
        return (valueTeam.name, totalTeamValue)
    }
    
    teamKeeperRankings.sorted(by:{ $0.1 > $1.1 }).forEach { tuple in
        print("team: \(tuple.0) - keeper ranking:\(tuple.1)")
    }
    return teams
}

public func covertFileToArray(with filename: String, dataFormat: [BatterFields]) {

}

public struct DataFormat {
    public let identifier: String
    public let dataValues: [BatterFields]

    public init(identifier: String, dataValues: [BatterFields]) {
        self.identifier = identifier
        self.dataValues = dataValues
    }
}

// aiai halfway thought through, the name is an identifier, but we need to store type info to be able to calculate fields like OBP
public enum BatterFields: String {
    case homeRuns = "HR"
    case name = "Name"
    case runs = "R"
    case runsBattedIn = "RBI"
    case onBasePercentage = "OBP"
    case steals = "SB"
}


func calculateZScores(with filename: String) -> [BatterZScores] {
    let batters = convertFileToBatters(filename: filename)
    return calculateZScores(for: batters)
}

func calculateZScores(for batters: [Batter]) -> [BatterZScores]{
    let homeRunsStandardDeviation = standardDeviation(for: batters.map{ $0.homeRuns})
    let meanHomeRuns = calculateMean(for: batters.map{ $0.homeRuns})

    let runsStandardDeviation = standardDeviation(for: batters.map {$0.runs})
    let meanRuns = calculateMean(for: batters.map{ $0.runs})

    let runsBattedInStandardDeviation = standardDeviation(for: batters.map {$0.runsBattedIn})
    let meanRunsBattedIn = calculateMean(for: batters.map{ $0.runsBattedIn})

    let onBasePercentageStandardDeviation = standardDeviation(for: batters.map {$0.onBasePercentage})
    let meanOnBasePercentage = calculateMean(for: batters.map{ $0.onBasePercentage})

    let stolenBasesStandardDeviation = standardDeviation(for: batters.map {$0.stolenBases})
    let meanStolenBases = calculateMean(for: batters.map {$0.stolenBases})

    return batters.map { batter in
        return BatterZScores(name: batter.name,
                      homeRuns: calculateZScore(value: batter.homeRuns, mean: meanHomeRuns, standardDeviation: homeRunsStandardDeviation),
                      runs: calculateZScore(value: batter.runs, mean: meanRuns, standardDeviation: runsStandardDeviation),
                      onBasePercentage: calculateZScore(value: batter.onBasePercentage, mean: meanOnBasePercentage, standardDeviation: onBasePercentageStandardDeviation),
                      stolenBases: calculateZScore(value: batter.stolenBases, mean: meanStolenBases, standardDeviation: stolenBasesStandardDeviation),
                      runsBattedIn: calculateZScore(value: batter.runsBattedIn, mean: meanRunsBattedIn, standardDeviation: runsBattedInStandardDeviation)
        )
    }
}

public func convertProjectionsFileToActionValues(from sourceFilename: String, to outputFilename: String) {
    let batters = calculateZScores(with: sourceFilename).sorted(by: {$0.totalZScore > $1.totalZScore} )

    let replacementPosition = 9 * 12 // 9 players for 12 teams

    let replacementZScore = batters[replacementPosition].totalZScore

    //TODO need to offset so the last person has a score of 0

    let adjustedBatterZScores = batters.map {
        ($0, $0.totalZScore - replacementZScore)
    }


    let totalAuctionMoney = 130*12

    let totalZScores = adjustedBatterZScores.reduce(0) { (previousResult, tuple) -> Double in
        if tuple.1 < 0 {
            return previousResult
        }

        return previousResult + tuple.1
    }

    print("total Z Scores :\(totalZScores)")

    let auctionArray = adjustedBatterZScores.map { tuple in
        (tuple.0, tuple.1 / totalZScores * Double(totalAuctionMoney))
    }


    let stream = OutputStream(toFileAtPath:outputFilename, append:false)!
    let csvWriter = try! CSVWriter(stream: stream)

    let rows: [[String]] = auctionArray.map { tuple in
        let stringArray: [String] = [
            tuple.0.name,
            String(format: "%.2f", tuple.0.runs),
            String(format: "%.2f", tuple.0.homeRuns),
            String(format: "%.2f", tuple.0.runsBattedIn),
            String(format: "%.2f", tuple.0.onBasePercentage),
            String(format: "%.2f", tuple.0.stolenBases),
            String(format: "%.2f", tuple.0.totalZScore),
            String(format: "%.2f", tuple.1)
        ]
        return stringArray
    }

    try! csvWriter.write(row: ["name", "R", "HR", "RBI", "OBP", "SB", "Total", "AuctionValue"])

    rows.forEach { row in
        // output to CSV
        csvWriter.beginNewRow()
        try! csvWriter.write(row: row)
    }

    csvWriter.stream.close()
}

public func calculateProjections(with filename: String) {

    let batters = convertFileToBatters(filename: filename)

    let numberOfTeams = 12
    let playersPerTeam = 24
    let numberOfPlayers = numberOfTeams * playersPerTeam
    let hittersPerTeam = 7
    
    // let auctionDollarsAvailable = 260
    let hitterAuctionDollarsAvailable = 130
    
    // Estimate of the player position that will be drafted at league minimum
    let replacementLevelBatterPosition = hittersPerTeam * numberOfTeams

    let zScores = calculateZScores(for: batters)

    //calculate Z scores
    let combinedZScores = zScores.map{ ($0.name, $0.totalZScore) }.sorted(by: { $0.1 > $1.1 })

    enum IntParsingError: Error {
        case overflow
        case invalidInput(String)
    }
    
    // The lowest total z-score player is replacement level
    if let worstBatter = combinedZScores.last {
        print("worstBatter: \(worstBatter)")
    } else {
        print("Unable to get worst batter")
        return
    }
    
    let replacementBatter = combinedZScores[replacementLevelBatterPosition]

    print("replacement batter is: \(replacementBatter)")
    
    let replacementZScore = replacementBatter.1

    let numberOfBatterResults = min(replacementLevelBatterPosition*2, batters.count)
    // subtract total-z-scores for each player from the replacement-z-score
    let adjustedBatters = combinedZScores.map {
        ($0.0,
         $0.1 - replacementZScore
        )
    }
    
    // calculate and add (all positive) z scores for all positions (total z-score)
    let totalZScores = adjustedBatters.filter({ $0.1 > 0 }).map { $0.1}.reduce(0,+)
    
    // calculate the total amount of auction money
    let hitterAuctionMoney = numberOfTeams * hitterAuctionDollarsAvailable
    
    print("totalZScores - \(totalZScores)")
    print("hitterAuctionMoney - \(hitterAuctionMoney)")
    
    let playersAuctions: [PlayerAuction] = adjustedBatters.map { batter in
        let batterZScore = batter.1
        let auctionAmount = batterZScore / totalZScores * Double(hitterAuctionMoney)
        return PlayerAuction(name: batter.0, zScore: batterZScore, auctionValue: auctionAmount)
    }

    for (index, playerAuction) in playersAuctions.enumerated() {
        print("\(index) - \(playerAuction.name) - \(playerAuction.zScore) - \(playerAuction.auctionValue)")

    }

    // Check out work, this should be roughly the number of teams * the auction $$$
    let totalAuctionValues = playersAuctions.filter({$0.auctionValue > 0}).map { $0.auctionValue}.reduce(0,+)
    print("Total auction amount: $\(totalAuctionValues)")
    
    // calculate the percentage of z-score a player has
    
    
    // use the percentage of z-score to determine the players total value (total-auction-pool & z-percentage)

}

func convertFileToBatters(filename: String) -> [Batter] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true) // It must be true.

    let headerRow = csv.headerRow!

    print(headerRow)
    let homeRunsRowOptional = headerRow.index(of: BatterFields.homeRuns.rawValue)
    let nameRowOptional:Int? = 0
    let runsRowOptional = headerRow.index(of: BatterFields.runs.rawValue)
    let onBasePercentageRowOptional = headerRow.index(of: BatterFields.onBasePercentage.rawValue)
    let stolenBasesRowOptional = headerRow.index(of: BatterFields.steals.rawValue)
    let runsBattedInRowOptional = headerRow.index(of: BatterFields.runsBattedIn.rawValue)

    guard let homeRunsRow = homeRunsRowOptional,
        let nameRow = nameRowOptional,
        let runsRow = runsRowOptional,
        let stolenBasesRow = stolenBasesRowOptional,
        let onBasePercentageRow = onBasePercentageRowOptional,
        let runsBattedInRow = runsBattedInRowOptional else {
            print("Unable to find all specified rows")
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

    return batters
}


