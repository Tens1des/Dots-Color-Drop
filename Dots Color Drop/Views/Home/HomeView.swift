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
    @State private var shuffleMode: ShuffleMode = .random
    @State private var showShuffleMenu = false
    @State private var temperatureShift: CGFloat = 0.0
    @State private var originalPalette: [AppColor] = []
    
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
                // Header - fixed at top with improved design
                VStack(spacing: 0) {
                    HStack {
                        // Logo
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#6C5CE7"), Color(hex: "#FD79A8")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Plinko")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Offline badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text(NSLocalizedString("offline", comment: ""))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    // User profile
                    UserProfileView(
                        userName: settingsManager.settings.userName,
                        avatar: settingsManager.settings.selectedAvatar
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Mode selector - improved design
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(GenerationMode.allCases, id: \.self) { mode in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedMode = mode
                                        }
                                        if mode == .custom {
                                            showCustomColorPicker = true
                                        }
                                    }) {
                                        Text(mode.localizedName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.7))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Group {
                                                    if selectedMode == mode {
                                                        LinearGradient(
                                                            colors: [Color(hex: "#6C5CE7"), Color(hex: "#8B7AE8")],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    } else {
                                                        Color.white.opacity(0.1)
                                                    }
                                                }
                                            )
                                            .cornerRadius(25)
                                            .shadow(
                                                color: selectedMode == mode ? Color(hex: "#6C5CE7").opacity(0.4) : Color.clear,
                                                radius: 8,
                                                x: 0,
                                                y: 4
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                        
                // Plinko Board Area
                ZStack {
                    PlinkoBoardView(
                        containers: $containers,
                        isDropping: $isDropping,
                        gravityStyle: settingsManager.settings.gravityStyle,
                        ballColors: getBallColors(),
                        physicsEnabled: settingsManager.settings.physicsEnabled,
                        onBallReachedBottom: { ball, containerIndex in
                            handleBallReachedBottom(ball: ball, containerIndex: containerIndex)
                        },
                        onBallCollision: { ball1, ball2 in
                            handleBallCollision(ball1: ball1, ball2: ball2)
                        }
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
                        
                        // Containers row with colors below
                        if !containers.isEmpty {
                            HStack(spacing: 8) {
                                ForEach($containers.indices, id: \.self) { index in
                                    VStack(spacing: 8) {
                                        ContainerView(container: $containers[index])
                                            .frame(maxWidth: .infinity)
                                        
                                        // Container weight control - individual for each container
                                        Menu {
                                            Button(action: {
                                                containers[index].weight = .weak
                                            }) {
                                                Label(ContainerWeight.weak.localizedName, systemImage: containers[index].weight == .weak ? "checkmark" : "")
                                            }
                                            Button(action: {
                                                containers[index].weight = .normal
                                            }) {
                                                Label(ContainerWeight.normal.localizedName, systemImage: containers[index].weight == .normal ? "checkmark" : "")
                                            }
                                            Button(action: {
                                                containers[index].weight = .strong
                                            }) {
                                                Label(ContainerWeight.strong.localizedName, systemImage: containers[index].weight == .strong ? "checkmark" : "")
                                            }
                                        } label: {
                                            Text(containers[index].weight.localizedName)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white.opacity(0.8))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(Color(hex: "#6C5CE7").opacity(0.3))
                                                )
                                        }
                                        
                                        // Color from palette displayed below container
                                        // Always reserve space, even if empty
                                        VStack(spacing: 4) {
                                            if index < currentPalette.count {
                                                Circle()
                                                    .fill(currentPalette[index].color)
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                                    )
                                                    .shadow(color: currentPalette[index].color.opacity(0.5), radius: 6, x: 0, y: 3)
                                                
                                                Text(currentPalette[index].hex)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.9))
                                                
                                                Button(action: {
                                                    paletteManager.addFavoriteColor(currentPalette[index])
                                                }) {
                                                    Image(systemName: "heart.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                            } else {
                                                // Empty placeholder to maintain layout
                                                Circle()
                                                    .fill(Color.clear)
                                                    .frame(width: 50, height: 50)
                                                
                                                Text("")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .frame(height: 14)
                                                
                                                Color.clear
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                        .padding(.top, 4)
                                        .frame(height: 80) // Fixed height to maintain layout
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Color Temperature Slider
                        if !currentPalette.isEmpty {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Temperature")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Button(action: {
                                        temperatureShift = 0.0
                                        applyTemperatureShift()
                                    }) {
                                        Text("Reset")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "snowflake")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Slider(value: $temperatureShift, in: -0.1...0.1) { _ in
                                        applyTemperatureShift()
                                    }
                                    .tint(Color(hex: "#6C5CE7"))
                                    
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Action buttons - improved design
                        if !currentPalette.isEmpty {
                            HStack(spacing: 12) {
                                Menu {
                                    Button(action: {
                                        shuffleMode = .random
                                        shufflePalette()
                                    }) {
                                        Label("Random", systemImage: shuffleMode == .random ? "checkmark" : "")
                                    }
                                    Button(action: {
                                        shuffleMode = .lightToDark
                                        shufflePalette()
                                    }) {
                                        Label("Light → Dark", systemImage: shuffleMode == .lightToDark ? "checkmark" : "")
                                    }
                                    Button(action: {
                                        shuffleMode = .darkToLight
                                        shufflePalette()
                                    }) {
                                        Label("Dark → Light", systemImage: shuffleMode == .darkToLight ? "checkmark" : "")
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "shuffle")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(NSLocalizedString("shuffle", comment: ""))
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#6C5CE7"))
                                    .cornerRadius(14)
                                    .shadow(color: Color(hex: "#6C5CE7").opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                
                                Button(action: {
                                    showHarmonyView = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(NSLocalizedString("harmony", comment: ""))
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#45B7D1"))
                                    .cornerRadius(14)
                                    .shadow(color: Color(hex: "#45B7D1").opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                
                                Button(action: {
                                    savePalette()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(NSLocalizedString("save", comment: ""))
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#50EBB7"))
                                    .cornerRadius(14)
                                    .shadow(color: Color(hex: "#50EBB7").opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Drop Colors button - improved design
                        Button(action: {
                            dropColors()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 24))
                                Text(NSLocalizedString("drop_colors", comment: ""))
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#6C5CE7"), Color(hex: "#FD79A8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "#6C5CE7").opacity(0.6), radius: 15, x: 0, y: 8)
                            .scaleEffect(isDropping ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isDropping)
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
    
    @State private var ballsProcessed = 0
    @State private var totalBalls = 0
    @State private var colorsToDistribute: [AppColor] = []
    
    private func dropColors() {
        isDropping = true
        currentPalette = []
        ballsProcessed = 0
        
        // Initialize or update containers, preserving weights and locks
        let containerCount = settingsManager.settings.containerCount
        
        // If containers exist, preserve their weights and locks
        if containers.count == containerCount {
            // Just clear colors but keep weights and locks
            for i in 0..<containers.count {
                containers[i].colors = []
            }
        } else {
            // Create new containers with preserved weights if possible
            let oldWeights = containers.map { $0.weight }
            let oldLocks = containers.map { $0.isLocked }
            containers = (0..<containerCount).map { index in
                Container(
                    isLocked: index < oldLocks.count ? oldLocks[index] : false,
                    weight: index < oldWeights.count ? oldWeights[index] : .normal
                )
            }
        }
        
        // Generate or use custom colors
        let colors = getBallColors()
        colorsToDistribute = colors
        totalBalls = colors.count
        
        if !settingsManager.settings.physicsEnabled {
            // For non-physics mode, use simple animation with delay
            let duration = settingsManager.settings.gravityStyle == .fast ? 1.5 : settingsManager.settings.gravityStyle == .bouncy ? 2.5 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                // Simple distribution for non-physics mode
                // Keep all original colors for display in containers
                for (index, color) in colors.enumerated() {
                    let containerIndex = index % containers.count
                    if !containers[containerIndex].isLocked {
                        containers[containerIndex].colors.append(color)
                    }
                }
                
                // Build palette from containers - mix colors from each container
                currentPalette = containers.compactMap { container in
                    if !container.colors.isEmpty {
                        return ColorGenerator.shared.mixColors(container.colors)
                    }
                    return nil
                }
                
                // Automatically save to history
                savePaletteToHistory()
                
                isDropping = false
                
                // Check achievements
                checkAchievements()
            }
        }
        // For physics mode, distribution happens via handleBallReachedBottom callback
    }
    
    private func handleBallReachedBottom(ball: Ball, containerIndex: Int) {
        // Add color to container, but skip if container is locked
        // Keep all original colors for display in container
        if containerIndex < containers.count {
            if !containers[containerIndex].isLocked {
                containers[containerIndex].colors.append(ball.color)
            }
        }
        
        ballsProcessed += 1
        
        // Check if all balls have reached bottom
        if ballsProcessed >= totalBalls {
                // Build palette from containers - mix colors from each container
                currentPalette = containers.compactMap { container in
                    if !container.colors.isEmpty {
                        return ColorGenerator.shared.mixColors(container.colors)
                    }
                    return nil
                }
                
                // Save original palette for temperature shift
                originalPalette = currentPalette
                
                // Automatically save to history
                savePaletteToHistory()
            
            isDropping = false
            
            // Check achievements
            checkAchievements()
        }
    }
    
    private func handleBallCollision(ball1: Ball, ball2: Ball) {
        // Mix spark effect is handled in PlinkoBoardView
    }
    
    private func savePaletteToHistory() {
        if !currentPalette.isEmpty {
            let palette = ColorPalette(
                name: "Palette \(Date().formatted(date: .abbreviated, time: .shortened))",
                colors: currentPalette,
                mode: selectedMode
            )
            paletteManager.savePalette(palette)
        }
    }
    
    private func checkAchievements() {
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
    
    private func shufflePalette() {
        withAnimation(.spring(response: 0.3)) {
            switch shuffleMode {
            case .random:
                currentPalette = ColorGenerator.shared.shuffleColors(currentPalette)
            case .lightToDark:
                currentPalette = ColorGenerator.shared.sortLightToDark(currentPalette)
            case .darkToLight:
                currentPalette = ColorGenerator.shared.sortDarkToLight(currentPalette)
            }
        }
    }
    
    private func applyTemperatureShift() {
        if temperatureShift == 0.0 {
            // Reset to original palette
            if !originalPalette.isEmpty {
                currentPalette = originalPalette
            }
        } else {
            // Apply temperature shift to original palette
            let basePalette = originalPalette.isEmpty ? currentPalette : originalPalette
            currentPalette = ColorGenerator.shared.applyTemperatureShift(basePalette, shift: temperatureShift)
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

