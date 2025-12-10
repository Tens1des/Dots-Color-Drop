//
//  PlinkoBoardView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct PlinkoBoardView: View {
    @Binding var containers: [Container]
    @Binding var isDropping: Bool
    var gravityStyle: GravityStyle
    var ballColors: [AppColor] = []
    
    @State private var ballPositions: [CGPoint] = []
    @State private var balls: [Ball] = []
    
    private let pinSpacing: CGFloat = 35
    private let pinRadius: CGFloat = 3
    private let rows = 6
    private let pinsPerRow = 8
    
    var body: some View {
        ZStack {
            // Board background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1E1E3F"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                )
            
            // Pins grid - dark purple dots
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<(row % 2 == 0 ? pinsPerRow : pinsPerRow - 1), id: \.self) { col in
                            Circle()
                                .fill(Color(hex: "#6C5CE7").opacity(0.4))
                                .frame(width: pinRadius * 2, height: pinRadius * 2)
                                .padding(.horizontal, pinSpacing / 2)
                                .padding(.vertical, pinSpacing / 2)
                        }
                    }
                    .offset(x: row % 2 == 0 ? 0 : pinSpacing / 2)
                }
            }
            .padding(.top, 20)
            
            // Dropping balls
            ForEach(balls) { ball in
                Circle()
                    .fill(ball.color.color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: ball.color.color.opacity(0.5), radius: 5)
                    .position(ball.position)
            }
        }
        .onChange(of: isDropping) { newValue in
            if newValue {
                startDropping()
            }
        }
    }
    
    private func startDropping() {
        // Create balls based on container count or ball colors
        let ballCount = ballColors.isEmpty ? containers.count : ballColors.count
        
        // Create balls at top with colors
        balls = (0..<ballCount).map { index in
            let color: AppColor
            if index < ballColors.count {
                color = ballColors[index]
            } else {
                // Fallback colors if not enough provided
                let fallbackColors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#6C5CE7", "#FD79A8", "#FDCB6E", "#55E6C1"]
                color = AppColor(hex: fallbackColors[index % fallbackColors.count])
            }
            
            // Spread balls across the top
            let startX = CGFloat(50 + (index * 50)).truncatingRemainder(dividingBy: 250)
            return Ball(
                color: color,
                position: CGPoint(x: max(50, min(startX, 250)), y: 20)
            )
        }
        
        // Animate balls falling
        let duration = gravityStyle == .fast ? 1.5 : gravityStyle == .bouncy ? 2.5 : 2.0
        
        withAnimation(.easeIn(duration: duration)) {
            for index in balls.indices {
                // Distribute end positions across the width
                let containerWidth = 250.0 / CGFloat(containers.count)
                let endX = CGFloat(50) + (CGFloat(index % containers.count) * containerWidth) + (containerWidth / 2)
                balls[index].position = CGPoint(x: max(50, min(endX, 250)), y: 280)
            }
        }
        
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            balls = []
        }
    }
}

#Preview {
    PlinkoBoardView(
        containers: .constant([]),
        isDropping: .constant(false),
        gravityStyle: .smooth,
        ballColors: []
    )
}

