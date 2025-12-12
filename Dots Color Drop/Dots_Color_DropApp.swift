//
//  Dots_Color_DropApp.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

@main
struct Dots_Color_DropApp: App {
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if settingsManager.settings.hasSeenOnboarding {
                    MainTabView()
                        .environmentObject(settingsManager)
                } else {
                    OnboardingView()
                        .environmentObject(settingsManager)
                }
            }
            .id(settingsManager.settings.hasSeenOnboarding)
            .preferredColorScheme(.light)
        }
    }
}
