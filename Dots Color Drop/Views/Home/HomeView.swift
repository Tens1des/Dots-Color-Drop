//
//  HomeView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var paletteManager: PaletteManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var achievementManager: AchievementManager
    
    @State private var selectedMode: GenerationMode = .random
    @State private var containers: [Container] = []
    @State private var currentPalette: [AppColor] = []
    @State private var customColors: [AppColor] = []
    @State private var isDropping = false
    @State private var showCustomColorPicker = false
    @State private var showHarmonyView = false
    @State private var showPaletteDetail = false
    
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
                // Header - fixed at top
                HStack {
                    // Logo placeholder
                    Image(systemName: "paintpalette.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Plinko")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(NSLocalizedString("offline", comment: ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.black.opacity(0.3))
                
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Mode selector
                        HStack(spacing: 12) {
                            ForEach(GenerationMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                    if mode == .custom {
                                        showCustomColorPicker = true
                                    }
                                }) {
                                    Text(mode.localizedName)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedMode == mode ?
                                            Color(hex: "#6C5CE7") :
                                            Color.clear
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                // Plinko Board Area
                ZStack {
                    PlinkoBoardView(
                        containers: $containers,
                        isDropping: $isDropping,
                        gravityStyle: settingsManager.settings.gravityStyle,
                        ballColors: getBallColors()
                    )
                    .frame(height: 300)
                            
                            // Custom colors preview
                            if selectedMode == .custom && !customColors.isEmpty {
                                VStack {
                                    HStack(spacing: 8) {
                                        ForEach(customColors) { color in
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        }
                                    }
                                    .padding(.top, 8)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Containers row
                        if !containers.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(containers) { container in
                                    ContainerView(container: container)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Result palette
                        if !currentPalette.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(currentPalette) { color in
                                        VStack(spacing: 4) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(color.color)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                            
                                            Text(color.hex)
                                                .font(.system(size: 10))
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Button(action: {
                                                paletteManager.addFavoriteColor(color)
                                            }) {
                                                Image(systemName: "heart")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Action buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    currentPalette = ColorGenerator.shared.shuffleColors(currentPalette)
                                }) {
                                    Text(NSLocalizedString("shuffle", comment: ""))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "#6C5CE7"))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showHarmonyView = true
                                }) {
                                    Text(NSLocalizedString("harmony", comment: ""))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "#45B7D1"))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    savePalette()
                                }) {
                                    Text(NSLocalizedString("save", comment: ""))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "#50EBB7"))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Drop Colors button
                        Button(action: {
                            dropColors()
                        }) {
                            Text(NSLocalizedString("drop_colors", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#6C5CE7"), Color(hex: "#FD79A8")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "#6C5CE7").opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .disabled(isDropping)
                    }
                }
            }
        }
        .sheet(isPresented: $showCustomColorPicker) {
            CustomColorPickerView(customColors: $customColors)
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showHarmonyView) {
            if !currentPalette.isEmpty {
                ColorHarmonyView(palette: currentPalette)
                    .environmentObject(settingsManager)
            }
        }
    }
    
    private func getBallColors() -> [AppColor] {
        let containerCount = settingsManager.settings.containerCount
        
        if selectedMode == .custom && !customColors.isEmpty {
            // Use custom colors, fill remaining if needed
            var colors = customColors
            if colors.count < containerCount {
                let additional = ColorGenerator.shared.generateColors(mode: .random, count: containerCount - colors.count)
                colors.append(contentsOf: additional)
            }
            return Array(colors.prefix(containerCount))
        } else {
            return ColorGenerator.shared.generateColors(mode: selectedMode, count: containerCount)
        }
    }
    
    private func dropColors() {
        isDropping = true
        currentPalette = []
        
        // Initialize containers
        let containerCount = settingsManager.settings.containerCount
        containers = (0..<containerCount).map { _ in
            Container(weight: .normal)
        }
        
        // Generate or use custom colors
        let colors = getBallColors()
        
        // Simulate ball drop (simplified - in real implementation would use physics)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Distribute colors to containers
            for (index, color) in colors.enumerated() {
                let containerIndex = index % containers.count
                containers[containerIndex].colors.append(color)
            }
            
            // Build palette from containers
            currentPalette = containers.compactMap { container in
                container.colors.first
            }
            
            // Automatically save to history
            if !currentPalette.isEmpty {
                let palette = ColorPalette(
                    name: "Palette \(Date().formatted(date: .abbreviated, time: .shortened))",
                    colors: currentPalette,
                    mode: selectedMode
                )
                paletteManager.savePalette(palette)
            }
            
            isDropping = false
            
            // Check achievements
            achievementManager.unlockAchievement(id: "first_drop")
            if selectedMode == .pastel {
                achievementManager.unlockAchievement(id: "soft_pastel")
            }
            if selectedMode == .vivid {
                achievementManager.unlockAchievement(id: "vivid_energy")
            }
            if selectedMode == .custom && !customColors.isEmpty {
                achievementManager.unlockAchievement(id: "custom_artist")
            }
        }
    }
    
    private func savePalette() {
        guard !currentPalette.isEmpty else { return }
        
        let palette = ColorPalette(
            name: "Palette \(Date().formatted(date: .abbreviated, time: .shortened))",
            colors: currentPalette,
            mode: selectedMode
        )
        
        paletteManager.savePalette(palette)
        achievementManager.unlockAchievement(id: "color_collector")
    }
}

#Preview {
    HomeView()
        .environmentObject(PaletteManager())
        .environmentObject(SettingsManager())
        .environmentObject(AchievementManager())
}

