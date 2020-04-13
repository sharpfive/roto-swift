//
//  SimulationLeagueHTMLFactory.swift
//  
//
//  Created by Jaim Zuber on 4/13/20.
//

import Plot
import Publish
import SimulatorLib

class SimulationLeagueHTMLFactory: HTMLFactory {
    typealias Site = SimulationLeague

    enum Errors: Error {
        case noItemHandlerForSection(Site.SectionID)
    }

    func makeIndexHTML(for index: Index, context: PublishingContext<SimulationLeague>) throws -> HTML {

        let sections = context.sections

        return HTML(
            .head(
                .title("Simulated Baseball Games")
            ),
            .body(
                .h1("Simulated Baseball Games"),
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

        let teams = metadata.teams

        return HTML(
            .head(
                .title(leagueName)
            ),
            .body(
                .div(
                    .h1(
                        .text("League: \(leagueName)")
                    ),
                    .forEach(teams) { team in
                        .div(
                            .h2(
                                .text(team.name)
                            ),
                            .h3(
                                .text("Batters")
                            ),
                            .table(
                                .tr(
                                    .th("Name")
                                ),
                                .forEach(team.batters) { batter in
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
                                .forEach(team.pitchers) { pitcher in
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

    func makeRostersHTML(leagueName: String, teams: [Team]) -> HTML {
        return HTML(
            .head(
                .title(leagueName)
            ),
            .body(
                .div(
                    .h1(
                        .text("League: \(leagueName)")
                    ),
                    .forEach(teams) { team in
                        .div(
                            .h2(
                                .text(team.name)
                            ),
                            .h3(
                                .text("Batters")
                            ),
                            .table(
                                .tr(
                                    .th("Name")
                                ),
                                .forEach(team.batters) { batter in
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
                                .forEach(team.pitchers) { pitcher in
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
    }

    func makeGameHTML(for game: GameViewModel) -> HTML {
        return HTML(
            .head(
                .title(
                    game.title
                )
            ),
            .body(
                .h1(.text(game.title))
            )
        )
    }

    func makeItemHTML(for item: Item<SimulationLeague>, context: PublishingContext<SimulationLeague>) throws -> HTML {
        let leagueName = item.metadata.leagueName
        let teams = item.metadata.teams

        switch item.sectionID {
        case .rosters:
            return makeRostersHTML(leagueName: leagueName, teams: teams)
        case .game:
            return makeGameHTML(for: item.metadata.game!)
        default:
            throw(Errors.noItemHandlerForSection(item.sectionID))
        }
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

