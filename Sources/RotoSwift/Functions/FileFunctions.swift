//
//  FileFunctions.swift
//  RotoSwift
//
//  Created by Jaim Zuber on 7/1/19.
//

import Foundation

public func defaultFilename(for application: String, format: String) -> String {
    let dateString = Date().toString(dateFormat: "yyyy-MM-dd-HH:mm:ss")

    return "\(FileManager.default.currentDirectoryPath)/\(application)-\(dateString).\(format)"
}
