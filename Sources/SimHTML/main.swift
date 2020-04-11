//
//  main.swift
//  
//
//  Created by Jaim Zuber on 4/5/20.
//

import Foundation
import Plot
import SPMUtility
import SimulatorLib

// ex swift run SimHTML --hitters ~/Dropbox/roto/sim/Steamer-600-Projections-batters.csv --pitchers ~/Dropbox/roto/sim/Steamer-600-Projections-pitchers.csv --lineups ~/Dropbox/roto/cash/2020-04-05-Auction-final.csv

let parser = ArgumentParser(commandName: "GameSimulator",
usage: "filename [--hitters  hitter-projections.csv --pitchers  pitching-projections.csv --linup lineups.csv]",
overview: "Converts a lineup into html")

let hitterFilenameOption = parser.add(option: "--hitters", shortName: "-h", kind: String.self, usage: "Filename for the hitters projections.")

let pitcherFilenameOption = parser.add(option: "--pitchers", shortName: "-p", kind: String.self, usage: "Filename for the pitcher projections.")

let outputFilenameOption = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Filename for output")

let lineupsFilenameOption = parser.add(option: "--lineups", shortName: "-l", kind: String.self, usage: "Filename for the team lineups.")

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

let hitterFilename = parsedArguments.get(hitterFilenameOption)
let pitcherFilename = parsedArguments.get(pitcherFilenameOption)
let lineupsFileName = parsedArguments.get(lineupsFilenameOption)


guard let hitterFilename = hitterFilename else {
    print("Hitter filename is required")
    exit(0)
}

guard let pitcherFilename = pitcherFilename else {
    print("Pitcher filename is required")
    exit(0)
}

guard let lineupsFilename = lineupsFileName else {
    print("Lineup filename is required")
    exit(0)
}

let hitterProjections = inputHitterProjections(filename: hitterFilename)
let pitcherProjections = inputPitcherProjections(filename: pitcherFilename)
let lineups = createLineups(filename: lineupsFilename, batterProjections: hitterProjections, pitcherProjections: pitcherProjections)

let leagueName = "CIK"

let html = HTML(
    .head(
        .title(leagueName)
    ),
    .body(
        .div(
            .h1(
                .text("League: \(leagueName)")
            ),
            .forEach(lineups) { lineup in
                .div(
                    .h2(
                        .text(lineup.name)
                    ),
                    .h3(
                        .text("Batters")
                    ),
                    .table(
                        .tr(
                            .th("Name")
                        ),
                        .forEach(lineup.batters) { batter in
                            .tr(
                                .td(.text(batter.fullName))
                            )
                        }
                    ),
                    .h3(
                        .text("Pitchers")
                    ),
                    .table(
                        .tr(
                            .th("Name")
                        ),
                        .forEach(lineup.pitchers) { pitcher in
                            .tr(
                                .td(.text(pitcher.fullName))
                            )
                        }
                    )
                )
            }
        )
    )
)


print(html.render(indentedBy: .spaces(4)))
