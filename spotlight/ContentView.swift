//
//  ContentView.swift
//  spotlight
//
//  Created by Monish on 1/22/25.
//

import SwiftUI
import AppKit  // For NSWorkspace

struct ParsedCommand {
    let intent: String   // e.g. "open_app"
    let target: String   // e.g. "spotify"
}

struct ContentView: View {
    @State private var query: String = ""
    @State private var results: [String] = []
    
    // We store commands in the original “display” form (like "Open Spotify")
    // so the user sees exactly what they typed.
    @State private var storedCommands: [String] = []
    
    // A dictionary from the “normalized” version (like "open spotify")
    // to the final parse result. This prevents re-parsing duplicates.
    @State private var storedParsedCommands: [String: ParsedCommand] = [:]

    // Instead of hardcoding knownApps, we’ll load them onAppear
    @State private var knownApps: [String : String] = [:]
    
    // we’ll store the text-based answer to display.
    @State private var infoResult: String = ""

    var body: some View {
        VStack(spacing: 10) {
            // Search Bar
            TextField("What can I do for you?", text: $query)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1)) // Slight background for the text field
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .onChange(of: query) { newValue in
                    filterResults(for: newValue)
                }
                .onSubmit {
                    handleUserInput()
                }
            
            // If we got a text-based info result from ChatGPT or local
            // “info-only” tasks, display it here:
            if !infoResult.isEmpty {
                Text(infoResult)
                    .padding()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
            }

            // Results List
            if !query.isEmpty {
                List {
                    ForEach(results, id: \.self) { result in
                        Text(result)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                // If the user taps an entry, treat it as input
                                query = result
                                handleUserInput()
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 200) // Limit list height
            }
            // Stored Commands - make them clickable
            if !storedCommands.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stored Commands:")
                        .font(.headline)
                        .padding(.leading, 20)

                    ForEach(storedCommands, id: \.self) { cmd in
                        Button(action: {
                            handleStoredCommand(cmd)
                        }) {
                            HStack(spacing: 8) {
                                // Optional icon to indicate "history" or "repeat"
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .foregroundColor(.accentColor)
                                
                                Text(cmd)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.15))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 10)
            }
        }
        .frame(width: 600)
        //.padding()
        // Removed the .background(BlurView(...)) line
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
        .onAppear {
            // Load all apps once when the view appears
            knownApps = findAllApps()
            /*
            for (appName, path) in knownApps {
                    print("'\(appName)' => \(path)")
                }
             */
        }
    }
    
    // MARK: - Handling New Input

    private func handleUserInput() {
        let raw = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }
        
        infoResult = ""
        
        // We now call a classification method that uses ChatGPT (or local rules)
        // to figure out what tasks to do. We keep a local reference to `raw`
        // so we can store it in the history if needed.
        classifyAndExecuteQuery(raw) { resultText in
            // If there's an info-based result, we set infoResult to display it.
            if let text = resultText {
                self.infoResult = text
            }
        }
        
        // Move to top of stored commands for quick history access
        moveCommandToTop(raw)
        // Clear the search query
        query = ""

        /*
        // Always store and parse the command in lowercase
        let lower = raw.lowercased()

        // Check if we already have a parsed command for this
        if storedParsedCommands.keys.contains(lower) {
            // It's known; move it to top, re-execute
            moveCommandToTop(lower)
            reExecuteParsedCommand(lower)
        } else {
            // It's new; parse it
            let parsed = parseManualCommand(lower)
            storedParsedCommands[lower] = parsed

            // Add the command (lowercased) to history
            
            
            // Execute
            executeParsedCommand(parsed)
        }
        
        moveCommandToTop(lower)

        // Clear the search query
        query = ""
         */
    }
    
    // Called when user clicks on a stored command button
    private func handleStoredCommand(_ cmd: String) {
        infoResult = ""
        classifyAndExecuteQuery(cmd) { resultText in
            if let text = resultText {
                self.infoResult = text
            }
        }
        moveCommandToTop(cmd)
    }
    
    // Normalize command for dictionary keys (lowercase, trimmed, etc.)
    private func normalizedCommand(_ input: String) -> String {
        return input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func moveCommandToTop(_ command: String) {
        if let idx = storedCommands.firstIndex(of: command) {
            storedCommands.remove(at: idx)
        }
        storedCommands.insert(command, at: 0)
    }
    
    // MARK: - Parsing & Executing Commands
    
    // TEMP: This is a placeholder for your “parse logic.”
    private func parseManualCommand(_ lower: String) -> ParsedCommand {
        if lower.hasPrefix("open ") {
            let target = lower.dropFirst("open".count).trimmingCharacters(in: .whitespaces)
            return ParsedCommand(intent: "open_app", target: target)
        } else {
            return ParsedCommand(intent: "unknown", target: lower)
        }
    }
    
    // Re-execute a known command without re-parsing
    private func reExecuteParsedCommand(_ norm: String) {
        guard let parsed = storedParsedCommands[norm] else {
            print("No parsed command found for \(norm).")
            return
        }
        executeParsedCommand(parsed)
    }
    
    // Actually perform the action based on parsed data
    private func executeParsedCommand(_ parsed: ParsedCommand) {
        switch parsed.intent {
        case "open_app":
            openApp(named: parsed.target)
        default:
            print("Unknown intent: \(parsed.intent). Could handle more logic here.")
        }
    }
    
    private func openApp(named name: String) {
        
        let lower = name.lowercased()
        if let path = knownApps[lower] {
            let url = URL(fileURLWithPath: path)
            NSWorkspace.shared.open(url)
        } else {
            print("App '\(name)' not found in knownApps dictionary.")
        }
    }

    // MARK: - Filter Results (Optional)
    private func filterResults(for query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }

        let partial = query.lowercased()

        // For demonstration, let’s show possible "Open ..." suggestions from known apps
        let matchedKeys = knownApps.keys.filter { $0.contains(partial) }
        let openSuggestions = matchedKeys.map { "Open \($0.capitalized)" }

        // You could add more suggestions: "Close X", "Search X", etc.
        // For now, we combine them:
        results = openSuggestions
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
