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

let filename = "/Users/jaim/code/roto-swift/data/fg-2017-projections.csv"

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
var hrRowOptional = headerRow.index(of: batterFields.homeRuns.rawValue)
var nameRowOptional:Int? = 0
var runsRowOptional = headerRow.index(of: batterFields.runs.rawValue)
var onBasePercentageOptional = headerRow.index(of: batterFields.onBasePercentage.rawValue)
var stealsRowOptional = headerRow.index(of: batterFields.steals.rawValue)
    

guard let hrRow = Int(hrRowOptional),
      let nameRow = nameRowOptional,
      let runsRow = Int(runsRowOptional),
      let stolenBasesRow = Int(stealsRowOptional),
      let onBasePercentage = Double(onBasePercentageOptional) else {
    print("Unable to determine rows")
    print("hrRow:\(String(describing:hrRowOptional)) - nameRow:\(String(describing:nameRowOptional))")
    exit(0)
}

var batters = [Batter]()

while let row = csv.next() {
    if let hrCount = Int(row[hrRow]) {
        let batter = Batter(name: row[nameRow], homeRuns: hrCount, runs: row[runsRow], onBasePercentage: row[onBasePercentage], stolenBases: row[stolenBasesRow] )
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

