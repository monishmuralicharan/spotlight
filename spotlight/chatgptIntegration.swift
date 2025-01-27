//
//  chatgptIntegration.swift
//  spotlight
//
//  Created by Monish on 1/26/25.
//

import Foundation

struct ChatGPTResponse: Decodable {
    // For GPT-3.5: see the official response structure
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
    
    struct Message: Decodable {
        let role: String
        let content: String
    }
}

func callChatGPT(with prompt: String, completion: @escaping (String?) -> Void) {
    // Replace this with your own API key
    let apiKey = "REPLACE_ME_WITH_YOUR_API_KEY"
    let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    let requestBody: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": [
            ["role": "system",
             "content": "You are a classification and task generation assistant for a Mac app that can do: open/close apps, control Spotify, web search, file open, file summarization, create calendar events, control volume, control brightness, or display info answers. Return JSON instructions if tasks are needed, or direct short text if info question."
            ],
            ["role": "user", "content": prompt]
        ],
        "temperature": 0.0
    ]
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
        completion(nil)
        return
    }
    
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = httpBody
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            // Extract content
            let content = decoded.choices.first?.message.content
            completion(content)
        } catch {
            print("Decoding error: \(error)")
            completion(nil)
        }
    }
    task.resume()
}
