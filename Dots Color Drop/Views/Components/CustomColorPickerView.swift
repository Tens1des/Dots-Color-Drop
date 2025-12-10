//
//  CustomColorPickerView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct CustomColorPickerView: View {
    @Binding var customColors: [AppColor]
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedColor: Color = .blue
    @State private var showColorPicker = false
    
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
                
                VStack(spacing: 20) {
                    Text("Pick 1-7 colors")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Selected colors preview
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(customColors) { color in
                                VStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(color.color)
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                    
                                    Button(action: {
                                        customColors.removeAll(where: { $0.id == color.id })
                                    }) {
                                        Text(NSLocalizedString("remove", comment: ""))
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            if customColors.count < 7 {
                                Button(action: {
                                    showColorPicker = true
                                }) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .font(.title)
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text(NSLocalizedString("add_color", comment: ""))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#6C5CE7"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle(NSLocalizedString("custom_colors", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerSheet(selectedColor: $selectedColor) { color in
                    let uiColor = UIColor(color)
                    customColors.append(AppColor(hex: uiColor.hexString))
                }
            }
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    let onSelect: (Color) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Select Color", selection: $selectedColor)
                    .padding()
                
                Button(action: {
                    onSelect(selectedColor)
                    dismiss()
                }) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#6C5CE7"))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Pick Color")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CustomColorPickerView(customColors: .constant([]))
        .environmentObject(SettingsManager())
}

