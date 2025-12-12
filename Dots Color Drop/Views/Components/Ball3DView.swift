//
//  Ball3DView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct Ball3DView: View {
    let color: AppColor
    let position: CGPoint
    
    var body: some View {
        ZStack {
            // Main sphere with gradient for 3D effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.color.opacity(1.0),
                            color.color.opacity(0.8),
                            color.color.opacity(0.6)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 2,
                        endRadius: 15
                    )
                )
                .frame(width: 24, height: 24)
            
            // Highlight/gloss effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: UnitPoint(x: 0.2, y: 0.2),
                        endPoint: UnitPoint(x: 0.8, y: 0.8)
                    )
                )
                .frame(width: 12, height: 12)
                .offset(x: -4, y: -4)
            
            // Shadow/rim for depth
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0.5),
                        endPoint: UnitPoint(x: 1.0, y: 1.0)
                    ),
                    lineWidth: 1
                )
                .frame(width: 24, height: 24)
        }
        .shadow(color: color.color.opacity(0.6), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        .position(position)
    }
}

#Preview {
    ZStack {
        Color.black
        Ball3DView(
            color: AppColor(hex: "#FF6B6B"),
            position: CGPoint(x: 100, y: 100)
        )
    }
}


