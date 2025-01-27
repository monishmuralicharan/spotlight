//
//  findAllApps.swift
//  spotlight
//
//  Created by Monish on 1/24/25.
//

import Foundation
import AppKit
import SwiftUI

func findAllApps() -> [String: String] {
    let fileManager = FileManager.default
    
    // Directories you want to scan.
    // Add or remove entries as needed.
    let directories = [
        "/Applications",
        "/System/Applications",
        // Expanding "~" for user’s home directory:
        ("~/Applications" as NSString).expandingTildeInPath
    ]
    
    // This will hold name->path (e.g. "spotify" -> "/Applications/Spotify.app")
    var appsDict: [String : String] = [:]
    
    for directory in directories {
        do {
            // List everything in this directory
            let items = try fileManager.contentsOfDirectory(atPath: directory)
            for item in items {
                // We're only interested in .app bundles
                if item.hasSuffix(".app") {
                    let appName = item.replacingOccurrences(of: ".app", with: "")
                    let lowerKey = appName.lowercased()
                    
                    // Construct full path to the .app
                    let fullPath = "\(directory)/\(item)"
                    
                    // Store it in our dictionary
                    appsDict[lowerKey] = fullPath
                }
            }
        } catch {
            // If we can't read the directory (permissions, etc.), just skip
            print("Error reading contents of \(directory): \(error)")
        }
    }
    
    return appsDict
}
