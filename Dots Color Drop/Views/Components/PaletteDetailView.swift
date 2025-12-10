//
//  PaletteDetailView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct PaletteDetailView: View {
    let palette: ColorPalette
    @EnvironmentObject var paletteManager: PaletteManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Environment(\.dismiss) var dismiss
    @State private var showFindSimilar = false
    @State private var showCopiedToast = false
    
    var body: some View {
        NavigationView {
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
                    VStack(spacing: 24) {
                        // Palette title
                        Text(palette.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Color strip
                        HStack(spacing: 0) {
                            ForEach(palette.colors) { color in
                                color.color
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(16)
                        
                        // Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mode: \(palette.mode.localizedName)")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Date: \(palette.date.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                showFindSimilar = true
                            }) {
                                Text(NSLocalizedString("find_similar", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#45B7D1"))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                copyPalette()
                            }) {
                                Text(showCopiedToast ? "Copied!" : NSLocalizedString("copy_hex", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#6C5CE7"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showFindSimilar) {
                SimilarPalettesView(palette: palette)
                    .environmentObject(paletteManager)
        }
    }
    
    private func copyPalette() {
        let hexString = palette.colors.map { $0.hex }.joined(separator: ", ")
        UIPasteboard.general.string = hexString
        
        // Show feedback
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedToast = false
        }
    }
}

struct SimilarPalettesView: View {
    let palette: ColorPalette
    @EnvironmentObject var paletteManager: PaletteManager
    @Environment(\.dismiss) var dismiss
    
    var similarPalettes: [ColorPalette] {
        paletteManager.findSimilarPalettes(to: palette)
    }
    
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
                    LazyVStack(spacing: 16) {
                        ForEach(similarPalettes) { similar in
                            PaletteCardView(palette: similar, onTap: {})
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Similar Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    PaletteDetailView(palette: ColorPalette(
        name: "Test Palette",
        colors: [
            AppColor(hex: "#FF6B6B"),
            AppColor(hex: "#4ECDC4"),
            AppColor(hex: "#45B7D1")
        ]
    ))
    .environmentObject(PaletteManager())
    .environmentObject(SettingsManager())
}

