//
//  MainTabView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var paletteManager = PaletteManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var achievementManager = AchievementManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(paletteManager)
                .environmentObject(settingsManager)
                .environmentObject(achievementManager)
                .tabItem {
                    Label(NSLocalizedString("home", comment: ""), systemImage: "house.fill")
                }
                .tag(0)
            
            HistoryView()
                .environmentObject(paletteManager)
                .environmentObject(settingsManager)
                .tabItem {
                    Label(NSLocalizedString("history", comment: ""), systemImage: "clock.fill")
                }
                .tag(1)
            
            FavoritesView()
                .environmentObject(paletteManager)
                .environmentObject(settingsManager)
                .tabItem {
                    Label(NSLocalizedString("favorites", comment: ""), systemImage: "heart.fill")
                }
                .tag(2)
            
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(achievementManager)
                .tabItem {
                    Label(NSLocalizedString("settings", comment: ""), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "#6C5CE7"))
    }
}

#Preview {
    MainTabView()
}



