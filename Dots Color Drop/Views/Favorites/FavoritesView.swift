//
//  FavoritesView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var paletteManager: PaletteManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedTab: FavoriteTab = .palettes
    @State private var showPaletteDetail: ColorPalette?
    
    enum FavoriteTab {
        case palettes
        case colors
    }
    
    var body: some View {
        ZStack {
            // Dark purple gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#1A1A2E"),
                    Color(hex: "#16213E"),
                    Color(hex: "#0F3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(NSLocalizedString("favorites", comment: ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.black.opacity(0.3))
                
                // Tab selector
                HStack(spacing: 0) {
                    Button(action: { selectedTab = .palettes }) {
                        Text(NSLocalizedString("favorites", comment: ""))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTab == .palettes ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == .palettes ?
                                Color(hex: "#6C5CE7") :
                                Color.clear
                            )
                    }
                    
                    Button(action: { selectedTab = .colors }) {
                        Text(NSLocalizedString("custom_colors", comment: ""))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTab == .colors ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == .colors ?
                                Color(hex: "#6C5CE7") :
                                Color.clear
                            )
                    }
                }
                .background(Color(hex: "#1E1E3F"))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                // Content
                if selectedTab == .palettes {
                    if paletteManager.favorites.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "heart")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("No favorite palettes")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(paletteManager.favorites) { palette in
                                    FavoritePaletteCardView(palette: palette)
                                        .onTapGesture {
                                            showPaletteDetail = palette
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                    }
                } else {
                    if paletteManager.favoriteColors.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("No favorite colors")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 16) {
                                ForEach(paletteManager.favoriteColors) { color in
                                    FavoriteColorCardView(color: color)
                                        .environmentObject(paletteManager)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
        }
        .sheet(item: $showPaletteDetail) { palette in
            PaletteDetailView(palette: palette)
                .environmentObject(paletteManager)
                .environmentObject(settingsManager)
        }
    }
}

struct FavoritePaletteCardView: View {
    let palette: ColorPalette
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Colors strip
            HStack(spacing: 0) {
                ForEach(palette.colors) { color in
                    RoundedRectangle(cornerRadius: 0)
                        .fill(color.color)
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Name
            Text(palette.name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1E1E3F"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FavoriteColorCardView: View {
    let color: AppColor
    @EnvironmentObject var paletteManager: PaletteManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Color swatch
            RoundedRectangle(cornerRadius: 12)
                .fill(color.color)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            // Hex code
            Text(color.hex)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            // Remove button
            Button(action: {
                paletteManager.removeFavoriteColor(color)
            }) {
                Text(NSLocalizedString("remove", comment: ""))
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1E1E3F"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FavoritesView()
        .environmentObject(PaletteManager())
        .environmentObject(SettingsManager())
}

