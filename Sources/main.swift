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

func calculateZScore(for batter: Batter, mean: Double, standardDeviation: Double) {
    return calculateZScore(value: batter.homeRuns, mean: mean, standardDeviation: standardDeviation) +
    calculateZScore(value: batter.runsBattedIn, mean: mean, standardDeviation: standardDeviation) +
    calculateZScore(value: batter.runs, mean: mean, standardDeviation: standardDeviation) +
    calculateZScore(value: batter.onBasePercentage, mean: mean, standardDeviation: standardDeviation) +
    calculateZScore(value: batter.stolenBases, mean: mean, standardDeviation: standardDeviation)
}


//let drop = try Droplet()

//let query = "Wat!!"
//let spotifyResponse = try drop.client.get("https://api.spotify.com/v1/search?type=artist&q=\(query)")
//print(spotifyResponse)

let filename = "/Users/jaim/code/xcode/command-line-tool/data/fg-2017-projections.csv"

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

//const let HR = "HR"

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
let hittersPerTeam = 12

let auctionDollarsAvailable = 260

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

let homeRunZScore = calculateZScore(value: <#T##Double#>, mean: <#T##Double#>, standardDeviation: <#T##Double#>)
//calculate Z scores
let zScores = batterPool.map {
    ($0.name, calculateZScore(value: <#T##Double#>, mean: <#T##Double#>, standardDeviation: <#T##Double#>))}



