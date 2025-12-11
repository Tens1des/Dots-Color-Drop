//
//  ContainerView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct ContainerView: View {
    @Binding var container: Container
    var onLockToggle: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 4) {
            // Lock button
            Button(action: {
                container.isLocked.toggle()
                onLockToggle?()
            }) {
                Image(systemName: container.isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 14))
                    .foregroundColor(container.isLocked ? Color(hex: "#6C5CE7") : Color.white.opacity(0.5))
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(container.isLocked ? 0.2 : 0.1))
                    )
            }
            
            // Container shape
            ZStack(alignment: .bottom) {
                // Container outline
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        container.isLocked ? Color(hex: "#6C5CE7") : Color.white.opacity(0.3),
                        lineWidth: container.isLocked ? 3 : 2
                    )
                    .frame(height: 100)
                
                // Colors displayed as balls at the bottom of container
                HStack(spacing: 6) {
                    ForEach(container.colors.prefix(3)) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: color.color.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(height: 100)
        }
    }
}

#Preview {
    ContainerView(
        container: .constant(Container(
            colors: [
                AppColor(hex: "#FF6B6B"),
                AppColor(hex: "#4ECDC4"),
                AppColor(hex: "#45B7D1")
            ]
        ))
    )
}



