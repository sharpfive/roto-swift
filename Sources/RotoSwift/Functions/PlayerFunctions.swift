//
//  PlayerFunctions.swift
//  Basic
//
//  Created by Jaim Zuber on 7/2/19.
//

import Foundation

func extractPositions(from lineString: String, separatorString: String = ",") -> [League.FieldPosition]? {
    // If the entire linestring converts to a Position, the player only has 1 position elligible
    if let singlePosition = League.FieldPosition(rawValue: lineString) {
        return [singlePosition]
    } else {
        // Otherwise it is a comma-delimited list
        let positionArray = lineString.components(separatedBy: separatorString)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { League.FieldPosition(rawValue: $0 ) }

        if positionArray.isEmpty {
            return nil
        } else {
            return positionArray
        }
    }
}
