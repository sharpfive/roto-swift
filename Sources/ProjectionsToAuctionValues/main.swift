//
//  main.swift
//  RotoSwift
//
//  Created by Jaim Zuber on 5/18/19.
//
import Foundation
import CSV
import RotoSwift

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

// Terminology
// Projections:
// A csv file of projected stats for a year
//
//
// Keeper Values:
// The amount paid for a play in a year
//
// Auction Values:
// The output of this program. This program converts the projected stats into auction values
//



let dateString = "2019-05-18"

let baseDirectoryString = "/Users/jaim/Dropbox/roto/projections/\(dateString)"
let inputDirectoryString = "\(baseDirectoryString)/input/"
let outputDirectoryString = "\(baseDirectoryString)/output/"

let keeperValuesFilenameString = "Keeper-Values-2019.csv"
let nextYearProjectionFilenameString = "Zips-projections-2020-batters.csv"
let followingYearProjectionFilenameString = "Zips-projections-2021-batters.csv"

let nextYearAuctionValuesFilenameString = "Zips-auction-values-2020-batters.csv"
let followingYearAuctionValuesFilenameString = "Zips-auction-values-2021-batters.csv"


let keeperValuesFullPathString = inputDirectoryString + keeperValuesFilenameString
let nextYearProjectionsFullPathString = inputDirectoryString + nextYearProjectionFilenameString
let followingYearProjectionsFullPathString = inputDirectoryString + followingYearProjectionFilenameString

let nextYearAuctionValuesFullPathString = outputDirectoryString + nextYearAuctionValuesFilenameString
let followingYearAuctionValuesFullPathString = outputDirectoryString + followingYearAuctionValuesFilenameString

// Convert the projectsion to projected auction values
convertProjectionsFileToActionValues(from: nextYearProjectionsFullPathString, to: nextYearAuctionValuesFullPathString)
convertProjectionsFileToActionValues(from: followingYearProjectionsFullPathString, to: followingYearAuctionValuesFullPathString)


// Get the keeper values
let auctionRepository = CBAuctionValueRepository(filename: keeperValuesFullPathString)
let keeperValues = auctionRepository.getAuctionValues()

print("keeperValues: \(keeperValues.count)")


// take the keeper values and create value


