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


//let drop = try Droplet()

//let query = "Wat!!"
//let spotifyResponse = try drop.client.get("https://api.spotify.com/v1/search?type=artist&q=\(query)")
//print(spotifyResponse)

//let filename = "/Users/jaim/code/roto-swift/data/fg-2017-projections.csv"
let filename = "/Users/jaim/code/xcode/command-line-tool/data/fg-2017-projections.csv"

//let url = URL(fileURLWithPath: "/tmp/foo")
let playerDataCSV = try String(contentsOfFile: filename, encoding: String.Encoding.ascii)

//print(file)


let csv = try! CSVReader(string: playerDataCSV,
                         hasHeaderRow: true) // It must be true.



enum batterFields: String {
    case homeRuns = "HR"
    case name = "Name"
    case runs = "Runs"
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
    

guard let homeRunsRow = homeRunsRow,
      let nameRow = nameRow,
      let runsRow = runsRow,
      let stolenBasesRow = stolenBasesRow,
      let onBasePercentageRow = onBasePercentageRow else {
    print("Unable to determine rows")
    //print("hrRow:\(String(describing:hrRowOptional)) - nameRow:\(String(describing:nameRowOptional))")
    exit(0)
}

var batters = [Batter]()

while let row = csv.next() {
    if let homeRuns = Int(row[homeRunsRow]),
       let runs = Int(row[runsRow]),
       let onBasePercentage = Double(row[onBasePercentageRow]),
       let stolenBases = Int(row[stolenBasesRow])
       {
        let batter = Batter(name: row[nameRow], homeRuns: homeRuns, runs: runs, onBasePercentage: onBasePercentage, stolenBases: stolenBases )
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
    print(batter)
}

print("\(batterPool.count) batters found")
let homeRunsStandardDeviation = standardDeviation(for: batterPool.map({ (batter) -> Int in
    batter.homeRuns
}))
print("HR standard deviation = \(homeRunsStandardDeviation)")

