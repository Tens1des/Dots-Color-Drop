//
//  SettingsView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var achievementManager: AchievementManager
    
    @State private var showAchievements = false
    @State private var customColors: [AppColor] = []
    @State private var showColorPicker = false
    @State private var selectedColor: Color = .blue
    @State private var containerCount: Int = 6
    @State private var showOnboarding = false
    
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(NSLocalizedString("settings", comment: ""))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(Color.black.opacity(0.3))
                    
                    VStack(spacing: 20) {
                        // Containers section
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(NSLocalizedString("containers", comment: "")): \(containerCount)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Slider(
                                    value: Binding(
                                        get: { Double(containerCount) },
                                        set: { newValue in
                                            let intValue = Int(newValue)
                                            containerCount = intValue
                                            settingsManager.settings.containerCount = intValue
                                            settingsManager.saveSettings()
                                        }
                                    ),
                                    in: 3...7,
                                    step: 1
                                )
                                .tint(Color(hex: "#45B7D1"))
                            }
                            .padding(16)
                        }
                        
                        // Language section
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("language", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("", selection: Binding(
                                    get: { settingsManager.settings.language },
                                    set: { 
                                        settingsManager.settings.language = $0
                                        settingsManager.saveSettings()
                                    }
                                )) {
                                    ForEach(AppLanguage.allCases, id: \.self) { language in
                                        Text(language.displayName)
                                            .tag(language)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(Color(hex: "#6C5CE7"))
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                            }
                            .padding(16)
                        }
                        
                        // Text Size section
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("text_size", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("", selection: Binding(
                                    get: { settingsManager.settings.textSize },
                                    set: { 
                                        settingsManager.settings.textSize = $0
                                        settingsManager.saveSettings()
                                    }
                                )) {
                                    ForEach(TextSize.allCases, id: \.self) { size in
                                        Text(size.localizedName)
                                            .tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(Color(hex: "#6C5CE7"))
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                            }
                            .padding(16)
                        }
                        
                        // Physics toggle
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(NSLocalizedString("physics_animation", comment: ""))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { settingsManager.settings.physicsEnabled },
                                        set: {
                                            settingsManager.settings.physicsEnabled = $0
                                            settingsManager.saveSettings()
                                        }
                                    ))
                                    .tint(Color(hex: "#6C5CE7"))
                                }
                            }
                            .padding(16)
                        }
                        
                        // Gravity Style section
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("Gravity Style", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("", selection: Binding(
                                    get: { settingsManager.settings.gravityStyle },
                                    set: {
                                        settingsManager.settings.gravityStyle = $0
                                        settingsManager.saveSettings()
                                    }
                                )) {
                                    ForEach(GravityStyle.allCases, id: \.self) { style in
                                        Text(style.localizedName)
                                            .tag(style)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(Color(hex: "#6C5CE7"))
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                            }
                            .padding(16)
                        }
                        
                        // Custom Colors section
                        SettingsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("custom_colors", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if customColors.isEmpty {
                                    Text(NSLocalizedString("No custom colors", comment: ""))
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(customColors) { color in
                                                HStack(spacing: 8) {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(color.color)
                                                        .frame(width: 50, height: 50)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.white, lineWidth: 1)
                                                        )
                                                    
                                                    Button(action: {
                                                        customColors.removeAll(where: { $0.id == color.id })
                                                        saveCustomColors()
                                                    }) {
                                                        Text(NSLocalizedString("remove", comment: ""))
                                                            .font(.subheadline)
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    showColorPicker = true
                                }) {
                                    Text(NSLocalizedString("add_color", comment: ""))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "#6C5CE7"))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(16)
                        }
                        
                        // Achievements button
                        Button(action: {
                            showAchievements = true
                        }) {
                            Text(NSLocalizedString("Achievements", comment: ""))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#6C5CE7"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Show Onboarding button
                        Button(action: {
                            showOnboarding = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                Text(NSLocalizedString("Show Onboarding", comment: ""))
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#6C5CE7"), Color(hex: "#8B7AE8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Clear Data button
                        Button(action: {
                            clearData()
                        }) {
                            Text(NSLocalizedString("clear_data", comment: ""))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(achievementManager)
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: $selectedColor) { color in
                let uiColor = UIColor(color)
                customColors.append(AppColor(hex: uiColor.hexString))
                saveCustomColors()
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
                .environmentObject(settingsManager)
        }
        .onAppear {
            loadCustomColors()
            containerCount = settingsManager.settings.containerCount
        }
    }
    
    private func loadCustomColors() {
        if let data = UserDefaults.standard.data(forKey: "settingsCustomColors"),
           let decoded = try? JSONDecoder().decode([AppColor].self, from: data) {
            customColors = decoded
        }
    }
    
    private func saveCustomColors() {
        if let encoded = try? JSONEncoder().encode(customColors) {
            UserDefaults.standard.set(encoded, forKey: "settingsCustomColors")
        }
    }
    
    private func clearData() {
        // Clear user data
        UserDefaults.standard.removeObject(forKey: "savedPalettes")
        UserDefaults.standard.removeObject(forKey: "favoritePalettes")
        UserDefaults.standard.removeObject(forKey: "favoriteColors")
        customColors = []
        saveCustomColors()
    }
}

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#1E1E3F"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(AchievementManager())
}

