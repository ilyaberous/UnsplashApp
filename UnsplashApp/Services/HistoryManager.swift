//
//  HistoryManager.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import Foundation


final class HistoryManager {
    private let defaults = UserDefaults.standard
    private var history: [String]
    lazy var lastHints: [String] = []
    lazy var filteredHints: [String] = []
    
    init() {
        guard let history = defaults.stringArray(forKey: "search_history") else {
            defaults.set([], forKey: "search_history")
            self.history = defaults.stringArray(forKey: "search_history")!
            return
        }
        self.history = history
    }
    
    func saveQueryInHistory(_ query: String) {
        if history.contains(query) {
            history = history.filter { $0 != query }
        }
        history.append(query)
        defaults.set(history, forKey: "search_history")
    }
    
    func filter(query: String) -> [String] {
        filteredHints = history.filter { $0.lowercased().contains(query.lowercased()) }
        return filteredHints
    }
    
    func getLastStringHints() -> [String] {
        if history.count < 5 {
            lastHints = history.reversed()
        } else {
            lastHints = history.suffix(5).reversed()
        }
        return lastHints
    }
}
