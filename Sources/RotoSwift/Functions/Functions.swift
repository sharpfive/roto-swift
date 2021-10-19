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

    let playerComparer = PlayerComparer()

    var playerRelativeValues = [PlayerRelativeValue]()

    playerKeeperPrices.forEach { nameKeeperValue in

        let fangraphPlayer = playerAuctions.first(where: {
            playerComparer.isSamePlayer(playerOne: $0, playerTwo: nameKeeperValue)
        })

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

public struct DataFormat {
    public let identifier: String
    public let dataValues: [BatterFields]

    public init(identifier: String, dataValues: [BatterFields]) {
        self.identifier = identifier
        self.dataValues = dataValues
    }
}

public enum BatterFields: String {
    case homeRuns = "HR"
    case name = "Name"
    case runs = "R"
    case runsBattedIn = "RBI"
    case onBasePercentage = "OBP"
    case steals = "SB"
}

public enum PitcherFields: String {
    case strikeouts = "SO"
    case ERA = "ERA"
    case WHIP = "WHIP"
    case inningsPitched = "IP"
}

func calculatePitcherZScores(with filename: String) -> [PitcherZScores] {
    let pitchers = convertFileToPitchers(filename: filename)
    let startingPitchers = pitchers.filter { $0.inningsPitched > 100 }
    return calculatePitcherZScores(for: startingPitchers)
}

public func calculateZScores(with filename: String) -> [BatterZScores] {
    let batters = convertFileToBatters(filename: filename)
    return calculateZScores(for: batters)
}

func calculatePitcherZScores(for pitchers: [Pitcher]) -> [PitcherZScores] {
    let strikeoutsStandardDeviation = standardDeviation(for: pitchers.map { $0.strikeouts })
    let meanStrikeouts = calculateMean(for: pitchers.map { $0.strikeouts })

    let eraStandardDeviation = standardDeviation(for: pitchers.map { $0.ERA })
    let meanERA = calculateMean(for: pitchers.map { $0.ERA })

    let whipStandardDeviation = standardDeviation(for: pitchers.map { $0.WHIP })
    let meanWHIP = calculateMean(for: pitchers.map { $0.WHIP })

    return pitchers.map { pitcher in
        PitcherZScores(name: pitcher.name,
                       strikeouts: calculateZScore(value: pitcher.strikeouts, mean: meanStrikeouts, standardDeviation: strikeoutsStandardDeviation),
                       WHIP: calculateZScore(value: pitcher.WHIP, mean: meanWHIP, standardDeviation: whipStandardDeviation) * -1.0,
                       ERA: calculateZScore(value: pitcher.ERA, mean: meanERA, standardDeviation: eraStandardDeviation) * -1.0)
    }
}

public func calculateZScores(for batters: [Batter]) -> [BatterZScores] {
    let homeRunsStandardDeviation = standardDeviation(for: batters.map { $0.homeRuns })
    let meanHomeRuns = calculateMean(for: batters.map { $0.homeRuns })

    let runsStandardDeviation = standardDeviation(for: batters.map { $0.runs })
    let meanRuns = calculateMean(for: batters.map { $0.runs })

    let runsBattedInStandardDeviation = standardDeviation(for: batters.map {$0.runsBattedIn})
    let meanRunsBattedIn = calculateMean(for: batters.map { $0.runsBattedIn })

    let onBasePercentageStandardDeviation = standardDeviation(for: batters.map { $0.onBasePercentage })
    let meanOnBasePercentage = calculateMean(for: batters.map { $0.onBasePercentage })

    let stolenBasesStandardDeviation = standardDeviation(for: batters.map { $0.stolenBases })
    let meanStolenBases = calculateMean(for: batters.map { $0.stolenBases })

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

public func convertPitcherProjectionsFileToActionValues(from sourceFilename: String, to outputFilename: String) {
    let pitchers = calculatePitcherZScores(with: sourceFilename).sorted(by: {$0.totalZScore > $1.totalZScore})

    let replacementPosition = 6 * 12 // # of pitchers for 12 teams

    let replacementZScore = pitchers[replacementPosition].totalZScore

    let adjustedPitcherZScores = pitchers.map {
        ($0, $0.totalZScore - replacementZScore)
    }

    let pitcherPercentage = 0.4
    let numberOfTeams = 12
    let auctionMoneyPerTeam = 260
    let totalAuctionMoney = numberOfTeams * auctionMoneyPerTeam
    let totalMoneyForPitchers = Double(totalAuctionMoney) * pitcherPercentage

    let totalZScores = adjustedPitcherZScores.reduce(0) { (previousResult, tuple) -> Double in
        if tuple.1 < 0 {
            return previousResult
        }

        return previousResult + tuple.1
    }

    // print("total Z Scores :\(totalZScores)")

    let auctionArray = adjustedPitcherZScores.map { tuple in
        (tuple.0, tuple.1 / totalZScores * totalMoneyForPitchers)
    }

    let stream = OutputStream(toFileAtPath: outputFilename, append: false)!
    let csvWriter = try! CSVWriter(stream: stream)

    let rows: [[String]] = auctionArray.map { tuple in
        let stringArray: [String] = [
            tuple.0.name,
            String(format: "%.2f", tuple.0.strikeouts),
            String(format: "%.2f", tuple.0.ERA),
            String(format: "%.2f", tuple.0.WHIP),
            String(format: "%.2f", tuple.0.totalZScore),
            String(format: "%.2f", tuple.1)
        ]
        return stringArray
    }

    try! csvWriter.write(row: ["name", "SO", "ERA", "WHIP", "Total", "AuctionValue"])

    rows.forEach { row in
        // output to CSV
        csvWriter.beginNewRow()
        try! csvWriter.write(row: row)
    }

    csvWriter.stream.close()
}

public func normalizeZScores(for batterZScores: [BatterZScores], replacementPosition: Int) -> [BatterZScores] {
    let replacementZScore = batterZScores[replacementPosition].totalZScore

    return batterZScores.map { batterZScore in
        var batterZScoreCopy = batterZScore
        batterZScoreCopy.totalZScore = batterZScore.totalZScore - replacementZScore
        return batterZScoreCopy
    }
}

public func convertProjectionsFileToActionValues(from sourceFilename: String, to outputFilename: String) {
    let batters = calculateZScores(with: sourceFilename).sorted(by: {$0.totalZScore > $1.totalZScore})

    let replacementPosition = 12 * 12 // 10 players for 12 teams

    let replacementZScore = batters[replacementPosition].totalZScore

    let adjustedBatterZScores = batters.map {
        ($0, $0.totalZScore - replacementZScore)
    }

    let hitterPercentage = 0.6
    let numberOfTeams = 12
    let auctionMoneyPerTeam = 260
    let totalAuctionMoney = numberOfTeams * auctionMoneyPerTeam
    let totalMoneyForHitters = Double(totalAuctionMoney) * hitterPercentage

    let totalZScores = adjustedBatterZScores.reduce(0) { (previousResult, tuple) -> Double in
        if tuple.1 < 0 {
            return previousResult
        }

        return previousResult + tuple.1
    }

    // print("total Z Scores :\(totalZScores)")

    let auctionArray = adjustedBatterZScores.map { tuple in
        (tuple.0, tuple.1 / totalZScores * totalMoneyForHitters)
    }

    let stream = OutputStream(toFileAtPath: outputFilename, append: false)!
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
    let hittersPerTeam = 7

    // let auctionDollarsAvailable = 260
    let hitterAuctionDollarsAvailable = 130

    // Estimate of the player position that will be drafted at league minimum
    let replacementLevelBatterPosition = hittersPerTeam * numberOfTeams

    let zScores = calculateZScores(for: batters)

    //calculate Z scores
    let combinedZScores = zScores.map { ($0.name, $0.totalZScore)}.sorted(by: { $0.1 > $1.1 })

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

    // subtract total-z-scores for each player from the replacement-z-score
    let adjustedBatters = combinedZScores.map {
        ($0.0,
         $0.1 - replacementZScore
        )
    }

    // calculate and add (all positive) z scores for all positions (total z-score)
    let totalZScores = adjustedBatters.filter({ $0.1 > 0 }).map { $0.1}.reduce(0, +)

    // calculate the total amount of auction money
    let hitterAuctionMoney = numberOfTeams * hitterAuctionDollarsAvailable

    print("totalZScores - \(totalZScores)")
    print("hitterAuctionMoney - \(hitterAuctionMoney)")

    let playersAuctions: [PlayerAuction] = adjustedBatters.map { batter in
        let batterZScore = batter.1
        let auctionAmount = batterZScore / totalZScores * Double(hitterAuctionMoney)
        return PlayerAuction(fullName: batter.0, zScore: batterZScore, auctionValue: auctionAmount)
    }

    for (index, playerAuction) in playersAuctions.enumerated() {
        print("\(index) - \(playerAuction.fullName) - \(playerAuction.zScore) - \(playerAuction.auctionValue)")
    }

    // Check out work, this should be roughly the number of teams * the auction $$$
    let totalAuctionValues = playersAuctions.filter({$0.auctionValue > 0}).map { $0.auctionValue }.reduce(0, +)
    print("Total auction amount: $\(totalAuctionValues)")

    // calculate the percentage of z-score a player has
    // use the percentage of z-score to determine the players total value (total-auction-pool & z-percentage)
}

public func convertFileToBatters(filename: String) -> [Batter] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true) // It must be true.

    let headerRow = csv.headerRow!

    print(headerRow)
    let homeRunsRowOptional = headerRow.firstIndex(of: BatterFields.homeRuns.rawValue)
    let nameRowOptional: Int? = 0
    let runsRowOptional = headerRow.firstIndex(of: BatterFields.runs.rawValue)
    let onBasePercentageRowOptional = headerRow.firstIndex(of: BatterFields.onBasePercentage.rawValue)
    let stolenBasesRowOptional = headerRow.firstIndex(of: BatterFields.steals.rawValue)
    let runsBattedInRowOptional = headerRow.firstIndex(of: BatterFields.runsBattedIn.rawValue)

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
            let runsBattedIn = Int(row[runsBattedInRow]) {
            let batter = Batter(name: row[nameRow], homeRuns: homeRuns, runs: runs, onBasePercentage: onBasePercentage, stolenBases: stolenBases, runsBattedIn: runsBattedIn)
            batters.append(batter)
        }
    }

    return batters
}

public func convertFileToPitchers(filename: String) -> [Pitcher] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.utf8)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true) // It must be true.

    let headerRow = csv.headerRow!

    print(headerRow)
    let strikeoutsRowOptional = headerRow.firstIndex(of: PitcherFields.strikeouts.rawValue)
    let nameRowOptional: Int? = 0
    let eraRowOptional = headerRow.firstIndex(of: PitcherFields.ERA.rawValue)
    let whipRowOptional = headerRow.firstIndex(of: PitcherFields.WHIP.rawValue)
    let inningsPitchedRowOptional = headerRow.firstIndex(of: PitcherFields.inningsPitched.rawValue)

    guard let strikeoutsRow = strikeoutsRowOptional,
        let nameRow = nameRowOptional,
        let eraRow = eraRowOptional,
        let whipRow = whipRowOptional,
        let inningsPitchedRow = inningsPitchedRowOptional else {
            print("Unable to find all specified rows")
            print("strikeOuts: \(String(describing: strikeoutsRowOptional)) - eraRow: \(String(describing: eraRowOptional))")
            exit(0)
    }

    var pitchers = [Pitcher]()

    while let row = csv.next() {
        if let strikeouts = Int(row[strikeoutsRow]),
            let WHIP = Double(row[whipRow]),
            let ERA = Double(row[eraRow]),
            let inningsPitched = Double(row[inningsPitchedRow]) {
            let pitcher = Pitcher(name: row[nameRow], strikeouts: strikeouts, WHIP: WHIP, ERA: ERA, inningsPitched: inningsPitched)
            pitchers.append(pitcher)
        }
    }

    return pitchers
}
