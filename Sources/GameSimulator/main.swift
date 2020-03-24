//
//  GameSimulator.swift
//  
//
//  Created by Jaim Zuber on 3/23/20.
//

import Foundation
import RotoSwift
import CSV
import SPMUtility

struct HitterProbability {
    let single: Double
    let double: Double
    let triple: Double
    let homeRun: Double
    let walk: Double
    let strikeOut: Double
    let hitByPitch: Double
}

struct PitcherProjection {
    let playerId: String
    let name: String
    let inningsPitched: Int
    let hits: Int
    // let doubles: Int
    // let triples: Int
    let homeRuns: Int
    let walks: Int
    let strikeouts: Int
    // let hitByPitch: Int

    var plateAppearances: Int {
        inningsPitched * 3 +
        hits +
//        doubles +
//        triples +
        homeRuns +
        walks
//        hitByPitch
    }
}

// Read in batter stats file
struct HitterProjection {
    let playerId: String
    let name: String
    let plateAppearances: Int
    let singles: Int
    let doubles: Int
    let triples: Int
    let homeRuns: Int
    let walks: Int
    let strikeouts: Int
    let hitByPitch: Int

    var probability: HitterProbability {
        let singleProbability: Double = Double(singles) / Double(plateAppearances)
        let doubleProbability: Double = Double(doubles) / Double(plateAppearances)
        let tripleProbability: Double = Double(triples) / Double(plateAppearances)
        let homeRunProbability: Double = Double(homeRuns) / Double(plateAppearances)
        let walkProbability: Double = Double(walks) / Double(plateAppearances)
        let strikeoutProbability: Double = Double(strikeouts) / Double(plateAppearances)
        let hitByPitchProbaility: Double = Double(hitByPitch) / Double(plateAppearances)

        let probabilities = [
            singleProbability,
            doubleProbability,
            tripleProbability,
            homeRunProbability,
            walkProbability,
            strikeoutProbability,
            hitByPitchProbaility
        ]

        // let totalProbabilities = probabilities.reduce(0, +)

        let normalizationFactor = 1.0// / totalProbabilities

        let normalizedProbabilitiesTotal = probabilities.map { $0 * normalizationFactor}
        .reduce(0, +)

        print("normalizedProbabilitiesTotal: \(normalizedProbabilitiesTotal)")

        return HitterProbability(single: singleProbability * normalizationFactor,
                                 double: doubleProbability * normalizationFactor,
                                 triple: tripleProbability * normalizationFactor,
                                 homeRun: homeRunProbability * normalizationFactor,
                                 walk: walkProbability * normalizationFactor,
                                 strikeOut: strikeoutProbability * normalizationFactor,
                                 hitByPitch: hitByPitchProbaility * normalizationFactor)
    }
}

func inputHitterProjections(filename: String) {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true)

    var hitterProjections = [HitterProjection]()
    while let row = csv.next() {
        guard let plateAppearances = Int(row[3]),
            let singles = Int(row[5]),
            let doubles = Int(row[6]),
            let triples = Int(row[7]),
            let homeRuns = Int(row[8]),
            let walks = Int(row[11]),
            let strikeouts = Int(row[12]),
            let hitByPitch = Int(row[13]) else {
                print("Invalid row: \(row)")
                exit(0)
        }

        let playerId = row[32]
        let playerName = row[0]

        let hitterProjection = HitterProjection(playerId: playerId,
                                                 name: playerName,
                                                 plateAppearances: plateAppearances,
                                                 singles: singles,
                                                 doubles: doubles,
                                                 triples: triples,
                                                 homeRuns: homeRuns,
                                                 walks: walks,
                                                 strikeouts: strikeouts,
                                                 hitByPitch: hitByPitch)

        hitterProjections.append(hitterProjection)
    }
}

func inputPitcherProjections(filename: String) -> [PitcherProjection] {
    let playerDataCSV = try! String(contentsOfFile: filename, encoding: String.Encoding.ascii)

    let csv = try! CSVReader(string: playerDataCSV,
                             hasHeaderRow: true)

    var pitcherProjections = [PitcherProjection]()
    while let row = csv.next() {
        guard let inningsPitchedDouble = Double(row[8]),
            let hits = Int(row[9]),
//            let doubles = Int(row[6]),
//            let triples = Int(row[7]),
            let homeRuns = Int(row[11]),
            let strikeouts = Int(row[12]),
            let walks = Int(row[13])
            //let hitByPitch = Int(row[13])
            else {
                print("Invalid Pitcher row: \(row)")
                exit(0)
        }

        let playerId = row[21]
        let playerName = row[0]
        let inningsPitched = Int(inningsPitchedDouble)

        let pitcherProjection = PitcherProjection(playerId: playerId,
                                                  name: playerName,
                                                  inningsPitched: inningsPitched,
                                                  hits: hits,
//                                                  doubles: doubles,
//                                                  triples: triples,
                                                  homeRuns: homeRuns,
                                                  walks: walks,
                                                  strikeouts: strikeouts)
        pitcherProjections.append(pitcherProjection)
    }

    return pitcherProjections
}

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv]",
overview: "Converts a set of hitter statistic projections and turns them into auction values")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parsedArguments: SPMUtility.ArgumentParser.Result

do {
    parsedArguments = try parser.parse(arguments)
} catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
} catch let error {
    print(error.localizedDescription)
    exit(0)
}

// Required fields
let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let outputFilename = parsedArguments.get(outputFilenameOption) ?? defaultFilename(for: "HitterAuctionValues", format: "csv")

guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

let hitterProjections = inputHitterProjections(filename: hitterFilename)
let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)

let totalSingles = hitterProjections.map { $0.singles }.reduce(0, +)
let totalDoubles = hitterProjections.map { $0.doubles }.reduce(0, +)
let totalTriples = hitterProjections.map { $0.triples}.reduct(0, +)

hitterProjections.prefix(upTo: 20).forEach {
    print($0)
    print($0.probability)
    print("--")
}

pitcherProjections.prefix(upTo: 20).forEach {
    print($0)
    // print($0.probability)
    print("--")
}
