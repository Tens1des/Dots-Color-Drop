//
//  ContainerView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct ContainerView: View {
    @State var container: Container
    
    var body: some View {
        VStack(spacing: 4) {
            // Lock indicator
            if container.isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#6C5CE7"))
            }
            
            // Container shape
            ZStack {
                VStack(spacing: 2) {
                    ForEach(container.colors.prefix(3)) { color in
                        Circle()
                                            .fill(color.color)
                                            .frame(width: 30, height: 30)
                    }
                }
                
                // Container outline
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(height: 100)
            }
            .frame(height: 100)
        }
    }
}

#Preview {
    ContainerView(container: Container(
        colors: [
            AppColor(hex: "#FF6B6B"),
            AppColor(hex: "#4ECDC4"),
            AppColor(hex: "#45B7D1")
        ]
    ))
}

