//
//  AchievementManager.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI
import Combine

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    private let achievementsKey = "achievements"
    
    init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        let allAchievementIds = [
            "first_drop", "soft_pastel", "vivid_energy", "custom_artist",
            "gravity_master", "lock_drop", "perfect_harmony", "color_collector",
            "favorite_spark", "drift_explorer", "temperature_shift", "match_discovery"
        ]
        
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = allAchievementIds.map { Achievement(id: $0, isUnlocked: false, unlockedDate: nil) }
        }
    }
    
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    func checkAchievement(id: String) -> Bool {
        achievements.first(where: { $0.id == id })?.isUnlocked ?? false
    }
    
    func resetAchievements() {
        let allAchievementIds = [
            "first_drop", "soft_pastel", "vivid_energy", "custom_artist",
            "gravity_master", "lock_drop", "perfect_harmony", "color_collector",
            "favorite_spark", "drift_explorer", "temperature_shift", "match_discovery"
        ]
        
        achievements = allAchievementIds.map { Achievement(id: $0, isUnlocked: false, unlockedDate: nil) }
        UserDefaults.standard.removeObject(forKey: achievementsKey)
        saveAchievements()
    }
}

