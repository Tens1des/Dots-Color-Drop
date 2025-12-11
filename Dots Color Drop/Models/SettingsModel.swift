//
//  SettingsModel.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI
import Combine

class AppSettings: ObservableObject, Codable {
    @Published var language: AppLanguage = .english
    @Published var textSize: TextSize = .default
    @Published var containerCount: Int = 6
    @Published var gravityStyle: GravityStyle = .smooth
    @Published var userName: String = ""
    @Published var selectedAvatar: String = ""
    @Published var hasSeenOnboarding: Bool = false
    @Published var physicsEnabled: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case language, textSize, containerCount, gravityStyle, userName, selectedAvatar, hasSeenOnboarding, physicsEnabled
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        language = try container.decode(AppLanguage.self, forKey: .language)
        textSize = try container.decode(TextSize.self, forKey: .textSize)
        containerCount = try container.decode(Int.self, forKey: .containerCount)
        gravityStyle = try container.decode(GravityStyle.self, forKey: .gravityStyle)
        userName = try container.decode(String.self, forKey: .userName)
        selectedAvatar = try container.decode(String.self, forKey: .selectedAvatar)
        hasSeenOnboarding = try container.decode(Bool.self, forKey: .hasSeenOnboarding)
        physicsEnabled = (try? container.decode(Bool.self, forKey: .physicsEnabled)) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(language, forKey: .language)
        try container.encode(textSize, forKey: .textSize)
        try container.encode(containerCount, forKey: .containerCount)
        try container.encode(gravityStyle, forKey: .gravityStyle)
        try container.encode(userName, forKey: .userName)
        try container.encode(selectedAvatar, forKey: .selectedAvatar)
        try container.encode(hasSeenOnboarding, forKey: .hasSeenOnboarding)
        try container.encode(physicsEnabled, forKey: .physicsEnabled)
    }
}

enum AppLanguage: String, Codable, CaseIterable {
    case english = "en"
    case russian = "ru"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
}

enum TextSize: String, Codable, CaseIterable {
    case small = "Small"
    case `default` = "Default"
    case large = "Large"
    
    var localizedName: String {
        switch self {
        case .small: return NSLocalizedString("small", comment: "")
        case .default: return NSLocalizedString("default", comment: "")
        case .large: return NSLocalizedString("large", comment: "")
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .default: return 16
        case .large: return 18
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var localizedTitle: String {
        NSLocalizedString("achievement_\(id)_title", comment: "")
    }
    
    var localizedDescription: String {
        NSLocalizedString("achievement_\(id)_description", comment: "")
    }
}

