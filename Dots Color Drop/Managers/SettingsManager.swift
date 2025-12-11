//
//  SettingsManager.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    @Published var settings: AppSettings
    
    private let settingsKey = "appSettings"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AppSettings()
        }
        
        setupLanguage()
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
        setupLanguage()
        // Trigger UI update
        objectWillChange.send()
    }
    
    private func setupLanguage() {
        UserDefaults.standard.set([settings.language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func resetSettings() {
        settings = AppSettings()
        saveSettings()
    }
}


