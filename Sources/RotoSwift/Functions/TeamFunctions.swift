import Foundation

func processTeams(at auctionValueFilename: String) {
    let auctionRepository = CBAuctionValueRepository(filename: auctionValueFilename)
    let teams = auctionRepository.getTeams()

    teams.forEach {
        print("\($0)")
    }
}
