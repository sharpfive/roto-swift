import Foundation
import CSV
import RotoSwift

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

//let filename = "/Users/jaim/code/xcode/roto-swift/data/fg-2017-projections.csv"
let filename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters.csv"
let outputFilename = "/Users/jaim/Dropbox/roto/2019/Zips/2019-04-19/Zips-projections-2021-batters-auctionvalues.csv"


//let batterData: [BatterFields] = [
//    .runs,
//    .runsBattedIn,
//    .homeRuns,
//    .steals,
//    .onBasePercentage
//]
//
//let dataFormat = DataFormat(identifier: "Name", dataValues: batterData)
//
////calculateProjections(with: filename)

saveZScores(from: filename, to: outputFilename)
