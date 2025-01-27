//
//  spotifyControls.swift
//  spotlight
//
//  Created by Monish on 1/24/25.
//

import Foundation

private func executeAppleScript(_ script: String) {
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    appleScript?.executeAndReturnError(&error)
    
    if let error = error {
        print("AppleScript Error: \(error)")
    }
}

// Play Spotify
private func playSpotify() {
    let script = """
    tell application "Spotify"
        play
    end tell
    """
    executeAppleScript(script)
}

// Pause Spotify
private func pauseSpotify() {
    let script = """
    tell application "Spotify"
        pause
    end tell
    """
    executeAppleScript(script)
}

// Skip to Next Track
private func nextSpotifyTrack() {
    let script = """
    tell application "Spotify"
        next track
    end tell
    """
    executeAppleScript(script)
}
