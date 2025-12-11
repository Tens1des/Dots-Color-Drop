//
//  UserProfileView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct UserProfileView: View {
    let userName: String
    let avatar: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
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
                
                if !avatar.isEmpty {
                    Text(avatar)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: Color(hex: "#6C5CE7").opacity(0.3), radius: 8, x: 0, y: 4)
            
            // User name
            VStack(alignment: .leading, spacing: 2) {
                Text(!userName.isEmpty ? userName : "Guest")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Welcome back!")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

#Preview {
    UserProfileView(userName: "John", avatar: "👤")
        .padding()
        .background(Color.black)
}


