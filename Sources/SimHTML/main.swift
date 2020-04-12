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
import Publish

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
                                .td(
                                    .text(pitcher.fullName)
                                )
                            )
                        }
                    )
                )
            }
        )
    )
)


print(html.render(indentedBy: .spaces(4)))

struct SimulationLeague: Website {
    enum SectionID: String, WebsiteSectionID {
        case rosters
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        let leagueName: String
        var teams: [Team]
    }

    var url = URL(string: "https://cooking-with-john.com")!
    var name = "The League"
    var description = "Baseball Simulation"
    var language: Language { .english }
    var imagePath: Path? { "images/logo.png" }
}

class SimulationLeagueHTMLFactory: HTMLFactory {
    typealias Site = SimulationLeague

    func makeIndexHTML(for index: Index, context: PublishingContext<SimulationLeague>) throws -> HTML {

        let sections = context.sections

        return HTML(
            .head(
                .title("The Title")
            ),
            .body(
                .h1("Here is some Index text"),
                .div(
                    .h2(
                        .text("Sections")
                    ),
                    .ul(
                        .forEach(sections) { section in
                            .li(
                                .a(
                                    .href("\(section.path)/index.html"),
                                    .text("\(section.path)")
                                )
                            )
                        }
                    )
                )
            )
        )
    }

    func makeSectionHTML(for section: Section<SimulationLeague>, context: PublishingContext<SimulationLeague>) throws -> HTML {


        switch (section.id, section.item(at: section.path)?.metadata) {
        case (.rosters, .some(let metadata)):
            return leagueHTML(for: metadata)
        case (.about, _):
            return aboutHTML()
        default:
            return defaultHTML(for: section)
        }
    }

    func leagueHTML(for metadata: SimulationLeague.ItemMetadata ) -> HTML {

        return HTML(
            .head(
                .title("League Info")
            ),
            .body(
                .h1(
                    .text("Here is text for \(metadata.leagueName)")
                ),
                .h2(
                    .text("Here are rosters \(metadata.teams)")
                )
            )
        )

    }

    func aboutHTML() -> HTML {
        return HTML(
            .head(
                .title("About")
            ),
            .body(
                .h1(
                    .text("About these stats")
                ),
                .p(
                    .text("This is a collection of simulated stats for baseball games. Not much else here yet. It is intended for amusement purposes only. Although its effectiveness to that point is debateable."
                    ),
                    .br(),
                    .text("Want to simulate your league with projected 2020 stats? Let us know.")
                )
            )
        )
    }

    func defaultHTML(for section: Section<SimulationLeague>) -> HTML {
        return HTML(
            .head(
                .title("Section :\(section.id)")
            ),
            .body(
                .h1(
                    .text("Default text for \(section.id)")
                )
            )
        )
    }

    func makeItemHTML(for item: Item<SimulationLeague>, context: PublishingContext<SimulationLeague>) throws -> HTML {
        let leagueName = item.metadata.leagueName
        let teams = item.metadata.teams

        return HTML(
            .head(
                .title("Item :\(leagueName)")
            ),
            .body(
                .h1(
                    .text("Here is text for \(leagueName)")
                ),
                .table(
                    .tr(
                        .th("Name")
                    ),
                    .forEach(teams) { team in
                        .tr(
                            .td(.text(team.name))
                        )
                    }
                )
            )
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<SimulationLeague>) throws -> HTML {
        return HTML(
            .head(
                .title("Page")
            ),
            .body(
                .h1(
                    .text("A Page")
                )
            )
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<SimulationLeague>) throws -> HTML? {
        return HTML(
            .head(
                .title("Tag List")
            ),
            .body(
                .h1(
                    .text("Tag List")
                )
            )
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<SimulationLeague>) throws -> HTML? {
        return HTML(
            .head(
                .title("Tag Details")
            ),
            .body(
                .h1(
                    .text("Tag Details")
                )
            )
        )
    }
}

extension Theme where Site == SimulationLeague {
    static var league: Self {
        Theme(htmlFactory: SimulationLeagueHTMLFactory())
    }
}

try SimulationLeague().publish(
    withTheme: .league,
    additionalSteps: [
        .addItem(Item(
            path: "rosters",
            sectionID: .rosters,
            metadata: SimulationLeague.ItemMetadata(
                leagueName: leagueName,
                teams: lineups
            ),
            tags: ["roster"],
            content: Content(
                title: "Roster"
            )
        ))
    ]
)
