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
    
    var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "paintpalette.fill",
                title: NSLocalizedString("onboarding_page1_title", comment: ""),
                description: NSLocalizedString("onboarding_page1_description", comment: "")
            ),
            OnboardingPage(
                icon: "sparkles",
                title: NSLocalizedString("onboarding_page2_title", comment: ""),
                description: NSLocalizedString("onboarding_page2_description", comment: "")
            ),
            OnboardingPage(
                icon: "square.and.arrow.down.fill",
                title: NSLocalizedString("onboarding_page3_title", comment: ""),
                description: NSLocalizedString("onboarding_page3_description", comment: "")
            )
        ]
    }
    
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
                    Text(currentPage < pages.count - 1 ? NSLocalizedString("Next", comment: "") : NSLocalizedString("Get Started", comment: ""))
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
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 20)
                
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
                .padding(.top, 20)
                
                // Title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Description
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SettingsManager())
}

