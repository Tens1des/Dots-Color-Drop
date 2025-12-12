//
//  ColorHarmonyView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct ColorHarmonyView: View {
    let palette: [AppColor]
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedHarmony: HarmonyMode = .complementary
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    VStack(spacing: 24) {
                        // Title
                        HStack {
                            Text(NSLocalizedString("color_harmonies", comment: ""))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        // Color swatches
                        HStack(spacing: 8) {
                            ForEach(palette) { color in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color.color)
                                    .frame(height: 60)
                            }
                        }
                        
                        // Harmony options
                        VStack(spacing: 12) {
                            ForEach(HarmonyMode.allCases, id: \.self) { harmony in
                                Button(action: {
                                    selectedHarmony = harmony
                                }) {
                                    HStack {
                                        Text(harmony.localizedName)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(
                                        selectedHarmony == harmony ?
                                        Color(hex: "#6C5CE7") :
                                        Color(hex: "#1E1E3F")
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Why this works section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("why_this_works", comment: ""))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(NSLocalizedString("opposite_hues_create_contrast", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#1E1E3F"))
                        )
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Done", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    ColorHarmonyView(palette: [
        AppColor(hex: "#FF6B6B"),
        AppColor(hex: "#4ECDC4"),
        AppColor(hex: "#45B7D1"),
        AppColor(hex: "#6C5CE7")
    ])
    .environmentObject(SettingsManager())
}





