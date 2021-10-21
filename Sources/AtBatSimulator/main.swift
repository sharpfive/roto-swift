//
//  File.swift
//  
//
//  Created by Jaim Zuber on 12/12/20.
//

import CSV
import Foundation
import SimulatorLib
import ArgumentParser

struct AtBatSimulator: ParsableCommand {
    @Argument(help: "CSV file of hitter projections")
    var hitterProjectionsFilename: String

    @Argument(help: "CSV file of pitcher projections")
    var pitcherProjectionsFilename: String

    mutating func run() throws {
        runMain(hitterFilename: hitterProjectionsFilename,
                pitcherFilename: pitcherProjectionsFilename)
    }
}

AtBatSimulator.main()

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

func runMain(hitterFilename: String, pitcherFilename: String) {
    let hitterProjections = inputHitterProjections(filename: hitterFilename)
    let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)

    let converter = ProbabilityLineupConverter(pitcherDictionary: pitcherProjections,
                                               batterDictionary: hitterProjections)

    let averageAtBatProbabilities = converter.baseAtBatProbabilites

    let pitcherId = "13125" //Gerrit Cole
    let pitcherProjection = pitcherProjections[pitcherId]!
    let pitcherProbability = converter.createPitcherProbability(for: pitcherProjection).probability


    let hitterId = "20123" //Juan Soto
    let hitterProjection = hitterProjections[hitterId]!
    let hitterProbability = hitterProjection.probability

    let atBatOutcomes = (0..<10000).map { _ in
        getAtBatEvent(pitcherProbability: pitcherProbability,
                                        batterProbability: hitterProbability,
                                        baseProbability: defaultAtBatEventProbability)
    }

    let atBatData = AtBatListData(atBatOutcomes: atBatOutcomes)

    print("AVG: \(atBatData.battingAverage)")
    print("OBP: \(atBatData.onBasePercentage)")
    print("SLG: \(atBatData.sluggingPercentage)")
    print("OPS: \(atBatData.onBasePlusSlugging)")
}
