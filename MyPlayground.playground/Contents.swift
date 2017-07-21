//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

struct Batter {
    let homeRuns: Int
}

let leader = Batter(homeRuns: 40)
let pipsqueak = Batter(homeRuns: 1)
let averageDude = Batter(homeRuns: 15)
let goodPowerHitter = Batter(homeRuns: 30)

let batters = [
    leader,
    pipsqueak,
    pipsqueak,
    averageDude,
    averageDude,
    averageDude,
    goodPowerHitter
]

let sortedBatterArray = batters.sorted { (batter1, batter2) -> Bool in
    return batter1.homeRuns > batter2.homeRuns
}

func calculateMedianIndex(lengthOfArray: Int) -> Int {
    return lengthOfArray / 2
}

let medianBatter = sortedBatterArray[calculateMedianIndex(lengthOfArray: sortedBatterArray.count)]

print(medianBatter.homeRuns)

// from Soroush
extension Sequence where Self.Iterator.Element: SignedInteger {
    var sum: Self.Iterator.Element {
        return self.reduce(0, +)
    }
}

extension Sequence where Self.Iterator.Element: BinaryFloatingPoint {
    var sum: Self.Iterator.Element {
        return self.reduce(0, +)
    }
}

let homeRuns = sortedBatterArray.map { (batter) -> Int in
    return batter.homeRuns
}

//let totalHomeRunsSum = homeRuns.reduce(0) { x,y in
//                                                    x + y
//                                          }

let totalHomeRunsSum = homeRuns.reduce(0,+)
let meanHomeRuns = totalHomeRunsSum / homeRuns.count

let adjustedArray = sortedBatterArray.map { (batter) -> Int in
    (batter.homeRuns - meanHomeRuns)^2
}


let adjustedMean = Double(adjustedArray.reduce(0,+)) / Double(adjustedArray.count)

let standardDeviation = adjustedMean.squareRoot()


print(homeRuns)

let totalHomeRuns = homeRuns.sum

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

let asdf = 1

let testArray = [600,470,170,430,300]

let stdDev = standardDeviation(for: testArray)


//let adjustedBatters = sortedBatterArray.map { (batter) -> T in
//    // subtract median home runs and square the result
//    return (batter.homeRuns - medianBatter.homeRuns)^2
//}


