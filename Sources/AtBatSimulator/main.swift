//
//  File.swift
//  
//
//  Created by Jaim Zuber on 12/12/20.
//

import CSV
import Foundation
import SimulatorLib
import SPMUtility

struct AtBatListData {
    let atBatOutcomes: [AtBatOutcome]

    var singles: Int {
        return count(by: .single)
    }

    var doubles: Int {
        return count(by: .double)
    }

    var triples: Int {
        return count(by: .triple)
    }

    var homeRuns: Int {
        return count(by: .homerun)
    }

    var walks: Int {
        return count(by: .walk)
    }

    var strikeouts: Int {
        return count(by: .strikeout)
    }

    var hitByPitch: Int {
        return count(by: .hitByPitch)
    }

    var plateAppearances: Int {
        return atBatOutcomes.count
    }

    var atBats: Int {
        return plateAppearances - walks - hitByPitch
    }

    var totalHits: Int {
        return singles + doubles + triples + homeRuns
    }

    var battingAverage: Decimal {
        return Decimal(totalHits) / Decimal(atBats)
    }

    var onBasePercentage: Decimal {
        return Decimal(totalHits + walks + hitByPitch) / Decimal(plateAppearances)
    }

    var totalBases: Int {
        return singles + doubles*2 + triples*3 + homeRuns*4
    }

    var sluggingPercentage: Decimal {
        return Decimal(totalBases) / Decimal(atBats)
    }

    var onBasePlusSlugging: Decimal {
        return sluggingPercentage + onBasePercentage
    }

    func count(by outcome: AtBatOutcome) -> Int {
        return atBatOutcomes.filter {$0 == outcome}.count
    }
}


let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --output output-auction-values-csv --linup lineups.csv]",
overview: "Converts a set of hitter statistic projections and turns them into auction values")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let parsedArguments: SPMUtility.ArgumentParser.Result

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

do {
    parsedArguments = try parser.parse(arguments)
} catch let error as ArgumentParserError {
    print(error.description)
    exit(0)
} catch let error {
    print(error.localizedDescription)
    exit(0)
}

let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)

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

let converter = ProbabilityLineupConverter(pitcherDictionary: pitcherProjections,
                                           batterDictionary: hitterProjections)

let averageAtBatProbabilities = converter.baseAtBatProbabilites

let pitcherId = "13125" //Gerrit Cole
let pitcherProjection = pitcherProjections[pitcherId]!
let pitcherProbability = converter.createPitcherProbability(for: pitcherProjection)


let hitterId = "20123" //Juan Soto
let hitterProjection = hitterProjections[hitterId]!
let hitterProbability = hitterProjection.probability

print("hitterProbability :\(hitterProbability)")
print("baseProbability: \(averageAtBatProbabilities)")

let atBatOutcomes = (0..<10000).map { _ in
    getAtBatEvent(pitcherProbability: averageAtBatProbabilities,
                                    batterProbability: hitterProbability,
                                    baseProbability: averageAtBatProbabilities)
}

let atBatData = AtBatListData(atBatOutcomes: atBatOutcomes)

print("AVG: \(atBatData.battingAverage)")
print("OBP: \(atBatData.onBasePercentage)")
print("SLG: \(atBatData.sluggingPercentage)")
print("OPS: \(atBatData.onBasePlusSlugging)")














