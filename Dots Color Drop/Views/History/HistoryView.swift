//
//  HistoryView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var paletteManager: PaletteManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedFilter: FilterType = .all
    @State private var showPaletteDetail: ColorPalette?
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case random = "Random"
        case pastel = "Pastel"
        case vivid = "Vivid"
        case custom = "Custom"
        
        var localizedName: String {
            switch self {
            case .all: return NSLocalizedString("all", comment: "")
            case .random: return NSLocalizedString("random", comment: "")
            case .pastel: return NSLocalizedString("pastel", comment: "")
            case .vivid: return NSLocalizedString("vivid", comment: "")
            case .custom: return NSLocalizedString("custom", comment: "")
            }
        }
    }
    
    var filteredPalettes: [ColorPalette] {
        if selectedFilter == .all {
            return paletteManager.history
        }
        return paletteManager.history.filter { $0.mode.rawValue == selectedFilter.rawValue }
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
                    Text(NSLocalizedString("history", comment: ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.black.opacity(0.3))
                
                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.localizedName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedFilter == filter ? .white : .white.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedFilter == filter ?
                                        Color(hex: "#6C5CE7") :
                                        Color(hex: "#1E1E3F")
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                
                // Palettes list
                if filteredPalettes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No palettes yet")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Create your first palette")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPalettes) { palette in
                                PaletteCardView(palette: palette, onTap: {
                                    showPaletteDetail = palette
                                })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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

struct PaletteCardView: View {
    let palette: ColorPalette
    let onTap: () -> Void
    @State private var showCopiedToast = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(palette.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(palette.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Colors
            HStack(spacing: 4) {
                ForEach(palette.colors) { color in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.color)
                        .frame(height: 40)
                }
            }
            
            // Tags and actions
            HStack {
                if !palette.tags.isEmpty {
                    ForEach(palette.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#6C5CE7"))
                            .cornerRadius(8)
                    }
                }
                Spacer()
                Button(action: {
                    copyPalette()
                }) {
                    Text(showCopiedToast ? "Copied!" : NSLocalizedString("copy", comment: ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1E1E3F"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
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

#Preview {
    HistoryView()
        .environmentObject(PaletteManager())
        .environmentObject(SettingsManager())
}

