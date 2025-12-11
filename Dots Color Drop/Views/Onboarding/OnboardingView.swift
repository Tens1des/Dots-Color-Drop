//
//  OnboardingView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            icon: "paintpalette.fill",
            title: "Create Palettes Through Play",
            description: "Plinko Color Sorter works fully offline and lets you create color palettes through a simple action - you drop color balls, and they form unique combinations. No registration, no extra steps - it's a fast and creative tool that turns color matching into a light game with chaos and order."
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Drop, Catch, Shape Your Colors",
            description: "Each drop creates a new visual story. Balls pass through the Plinko board, land in containers, and form a palette. You can lock containers, choose colors manually, adjust gravity, view harmonies, shuffle order, and adjust temperature. Saved palettes are stored in history and favorites."
        ),
        OnboardingPage(
            icon: "square.and.arrow.down.fill",
            title: "Export & Collect Your Creations",
            description: "Created palettes can be exported as PNG, HEX list, or stylish card. The app helps you collect your own collection of color ideas, return to them, and refine if desired. Mini animations, soft transitions, and the atmosphere of 'controlled chaos' make the palette creation process pleasant and inspiring."
        )
    ]
    
    var body: some View {
        ZStack {
            // Improved gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#0F0C29"),
                    Color(hex: "#1A1A2E"),
                    Color(hex: "#16213E"),
                    Color(hex: "#0F3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with logo
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#6C5CE7"), Color(hex: "#FD79A8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                // Progress indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color(hex: "#6C5CE7") : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30)
                
                // Continue button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        // Mark onboarding as completed
                        settingsManager.settings.hasSeenOnboarding = true
                        settingsManager.saveSettings()
                        
                        // Trigger UI update
                        DispatchQueue.main.async {
                            // Try to dismiss if shown as modal
                            dismiss()
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
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
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon/Illustration with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#6C5CE7").opacity(0.2),
                                Color(hex: "#FD79A8").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#6C5CE7"), Color(hex: "#FD79A8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 40)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            // Description
            Text(page.description)
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SettingsManager())
}

