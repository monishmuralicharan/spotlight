//
//  ContentView.swift
//  spotlight
//
//  Created by Monish on 1/22/25.
//


import SwiftUI

@main
struct spotlightApp: App {
    var body: some Scene {
        WindowGroup {
            // The "main" entry point calls ContentView
            ContentView()
                .background(Color.clear)  // SwiftUI-level clear background
                .onAppear {
                    // Make the window background fully transparent
                    if let window = NSApplication.shared.windows.first {
                        window.isOpaque = false
                        window.backgroundColor = .clear
                        window.titleVisibility = .hidden
                        window.titlebarAppearsTransparent = true

                        // (Optional) remove the title bar completely:
                         window.styleMask.remove(.titled)
                        //
                        // (Optional) to make it borderless:
                         window.styleMask.remove(.resizable)
                         window.styleMask.remove(.closable)
                         window.styleMask.remove(.miniaturizable)
                    }
                }
        }
    }
}
