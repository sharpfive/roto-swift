//
//  math.swift
//  command-line-toolPackageDescription
//
//  Created by Jaim Zuber on 2/18/18.
//

import Foundation

func calculateMean(for array: [Int]) -> Double {
    let total = array.reduce(0,+)
    return Double(total) / Double(array.count)
}

func calculateMean(for array: [Double]) -> Double {
    let total = array.reduce(0,+)
    return total / Double(array.count)
}

func calculateZScore(value: Int, mean: Double, standardDeviation:Double ) -> Double {
    return (Double(value) - mean) / standardDeviation
}

func calculateZScore(value: Double, mean: Double, standardDeviation:Double ) -> Double {
    return (value - mean) / standardDeviation
}

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

func standardDeviation(for array: [Double]) -> Double {
    let sum = array.reduce(0,+)
    let mean = Double(sum) / Double(array.count)
    let adjustedArray = array.map { (value) -> Double in
        return pow(Double(value) - mean, 2)
    }
    let adjustedSum = adjustedArray.reduce(0,+)
    let adjustedMean = Double(adjustedSum) / Double(adjustedArray.count)
    
    return adjustedMean.squareRoot()
}
