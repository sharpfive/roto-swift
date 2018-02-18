//import Vapor
//import HTTP

import CSV


// import Glibc (for linux builds)
import Darwin

print("Hello, world!")

print("Yo!")

struct Batter {
    let name: String
    let homeRuns: Int
    let runs: Int
    let onBasePercentage: Double
    let stolenBases: Int
    let runsBattedIn: Int
}

struct PlayerAuction {
    let name: String
    let zScore: Double
    let auctionValue: Double
}

func standardDeviation(for array: [Int]) -> Double {
    let sum = array.reduce(0,+)
    let mean = Double(sum) / Double(array.count)
    let adjustedArray = array.map { (value) -> Double in
        return pow(Double(value) - mean, 2)
    }
    let adjustedSum = adjustedArray.reduce(0,+)
    let adjustedMean = Double(adjustedSum) / Double(adjustedArray.count)
    
    return adjustedMean.squareRoot()
}

func calculateMean(for array: [Int]) -> Double {
    let total = array.reduce(0,+)
    return Double(total) / Double(array.count)
}

func calculateMean(for array: [Double]) -> Double {
    let total = array.reduce(0,+)
    return total / Double(array.count)
}

func standardDeviation(for array: [Double]) -> Double {
    let sum = array.reduce(0,+)
    let mean = Double(sum) / Double(array.count)
    let adjustedArray = array.map { (value) -> Double in
        return pow(Double(value) - mean, 2)
    }
    let adjustedSum = adjustedArray.reduce(0,+)
    let adjustedMean = Double(adjustedSum) / Double(adjustedArray.count)
    
    return adjustedMean.squareRoot()
}

func calculateZScore(value: Int, mean: Double, standardDeviation:Double ) -> Double {
    return (Double(value) - mean) / standardDeviation
}

func calculateZScore(value: Double, mean: Double, standardDeviation:Double ) -> Double {
    return (value - mean) / standardDeviation
}

let filename = "/Users/jaim/code/roto-swift/data/fg-2017-projections.csv"

let playerDataCSV = try String(contentsOfFile: filename, encoding: String.Encoding.ascii)

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
var homeRunsRow = headerRow.index(of: batterFields.homeRuns.rawValue)
var nameRow:Int? = 0
var runsRow = headerRow.index(of: batterFields.runs.rawValue)
var onBasePercentageRow = headerRow.index(of: batterFields.onBasePercentage.rawValue)
var stolenBasesRow = headerRow.index(of: batterFields.steals.rawValue)
var runsBattedInRow = headerRow.index(of: batterFields.runsBattedIn.rawValue)
    
print("runsRow:\(String(describing:runsRow))")
print("onBasePercentageRow:\(String(describing:onBasePercentageRow))")
print("stolenBasesRow:\(String(describing:stolenBasesRow))")
guard let homeRunsRow = homeRunsRow,
      let nameRow = nameRow,
      let runsRow = runsRow,
      let stolenBasesRow = stolenBasesRow,
      let onBasePercentageRow = onBasePercentageRow,
      let runsBattedInRow = runsBattedInRow else {
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

let auctionDollarsAvailable = 260
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
guard let worstBatter = zScores.last else {
    throw IntParsingError.invalidInput("asdfasdf")
//    throw Error(domain:"", code:0, userInfo:nil)
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







