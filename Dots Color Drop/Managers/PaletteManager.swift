//
//  PaletteManager.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI
import Combine

class PaletteManager: ObservableObject {
    @Published var currentPalette: ColorPalette?
    @Published var history: [ColorPalette] = []
    @Published var favorites: [ColorPalette] = []
    @Published var favoriteColors: [AppColor] = []
    
    private let maxHistoryCount = 50
    private let historyKey = "savedPalettes"
    private let favoritesKey = "favoritePalettes"
    private let favoriteColorsKey = "favoriteColors"
    
    init() {
        loadData()
    }
    
    func savePalette(_ palette: ColorPalette) {
        history.insert(palette, at: 0)
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        saveData()
    }
    
    func addToFavorites(_ palette: ColorPalette) {
        var updated = palette
        updated.isFavorite = true
        if !favorites.contains(where: { $0.id == palette.id }) {
            favorites.append(updated)
        }
        if let index = history.firstIndex(where: { $0.id == palette.id }) {
            history[index].isFavorite = true
        }
        saveData()
    }
    
    func removeFromFavorites(_ palette: ColorPalette) {
        favorites.removeAll(where: { $0.id == palette.id })
        if let index = history.firstIndex(where: { $0.id == palette.id }) {
            history[index].isFavorite = false
        }
        saveData()
    }
    
    func addFavoriteColor(_ color: AppColor) {
        if !favoriteColors.contains(where: { $0.hex == color.hex }) {
            favoriteColors.append(color)
            saveData()
        }
    }
    
    func removeFavoriteColor(_ color: AppColor) {
        favoriteColors.removeAll(where: { $0.hex == color.hex })
        saveData()
    }
    
    func deletePalette(_ palette: ColorPalette) {
        history.removeAll(where: { $0.id == palette.id })
        favorites.removeAll(where: { $0.id == palette.id })
        saveData()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
        if let encoded = try? JSONEncoder().encode(favoriteColors) {
            UserDefaults.standard.set(encoded, forKey: favoriteColorsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ColorPalette].self, from: data) {
            history = decoded
        }
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([ColorPalette].self, from: data) {
            favorites = decoded
        }
        if let data = UserDefaults.standard.data(forKey: favoriteColorsKey),
           let decoded = try? JSONDecoder().decode([AppColor].self, from: data) {
            favoriteColors = decoded
        }
    }
    
    func findSimilarPalettes(to palette: ColorPalette, limit: Int = 7) -> [ColorPalette] {
        let allPalettes = history.filter { $0.id != palette.id }
        
        return allPalettes.sorted { pal1, pal2 in
            let similarity1 = calculateSimilarity(palette, pal1)
            let similarity2 = calculateSimilarity(palette, pal2)
            return similarity1 > similarity2
        }.prefix(limit).map { $0 }
    }
    
    private func calculateSimilarity(_ pal1: ColorPalette, _ pal2: ColorPalette) -> Double {
        var totalSimilarity: Double = 0
        var count = 0
        
        for color1 in pal1.colors {
            var bestSimilarity: Double = 0
            for color2 in pal2.colors {
                let similarity = colorSimilarity(color1, color2)
                bestSimilarity = max(bestSimilarity, similarity)
            }
            totalSimilarity += bestSimilarity
            count += 1
        }
        
        return count > 0 ? totalSimilarity / Double(count) : 0
    }
    
    private func colorSimilarity(_ c1: AppColor, _ c2: AppColor) -> Double {
        let ui1 = c1.uiColor
        let ui2 = c2.uiColor
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let deltaR = abs(r1 - r2)
        let deltaG = abs(g1 - g2)
        let deltaB = abs(b1 - b2)
        
        let distance = sqrt(deltaR * deltaR + deltaG * deltaG + deltaB * deltaB)
        return 1.0 - min(distance, 1.0)
    }
}

