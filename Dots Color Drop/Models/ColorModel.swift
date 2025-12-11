//
//  ColorModel.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

struct ColorPalette: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var colors: [AppColor]
    var date: Date
    var mode: GenerationMode
    var tags: [String]
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, colors: [AppColor], date: Date = Date(), mode: GenerationMode = .random, tags: [String] = [], isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.colors = colors
        self.date = date
        self.mode = mode
        self.tags = tags
        self.isFavorite = isFavorite
    }
}

struct AppColor: Identifiable, Codable, Hashable {
    let id: UUID
    var hex: String
    var uiColor: UIColor {
        UIColor(hex: hex) ?? .gray
    }
    
    var color: Color {
        Color(uiColor)
    }
    
    init(id: UUID = UUID(), hex: String) {
        self.id = id
        self.hex = hex
    }
}

enum GenerationMode: String, Codable, CaseIterable {
    case random = "Random"
    case pastel = "Pastel"
    case vivid = "Vivid"
    case custom = "Custom"
    
    var localizedName: String {
        switch self {
        case .random: return NSLocalizedString("random", comment: "")
        case .pastel: return NSLocalizedString("pastel", comment: "")
        case .vivid: return NSLocalizedString("vivid", comment: "")
        case .custom: return NSLocalizedString("custom", comment: "")
        }
    }
}

enum GravityStyle: String, Codable, CaseIterable {
    case smooth = "Smooth"
    case bouncy = "Bouncy"
    case fast = "Fast"
    
    var localizedName: String {
        switch self {
        case .smooth: return NSLocalizedString("smooth", comment: "")
        case .bouncy: return NSLocalizedString("bouncy", comment: "")
        case .fast: return NSLocalizedString("fast", comment: "")
        }
    }
}

enum ShuffleMode: String, CaseIterable {
    case random = "Random"
    case lightToDark = "Light → Dark"
    case darkToLight = "Dark → Light"
    
    var localizedName: String {
        switch self {
        case .random: return NSLocalizedString("random", comment: "")
        case .lightToDark: return "Light → Dark"
        case .darkToLight: return "Dark → Light"
        }
    }
}

enum HarmonyMode: String, Codable, CaseIterable {
    case complementary = "Complementary"
    case analogous = "Analogous"
    case triadic = "Triadic"
    case split = "Split"
    case monochrome = "Monochrome"
    
    var localizedName: String {
        switch self {
        case .complementary: return NSLocalizedString("complementary", comment: "")
        case .analogous: return NSLocalizedString("analogous", comment: "")
        case .triadic: return NSLocalizedString("triadic", comment: "")
        case .split: return NSLocalizedString("split", comment: "")
        case .monochrome: return NSLocalizedString("monochrome", comment: "")
        }
    }
}

enum ContainerWeight: String, Codable {
    case weak = "Weak"
    case normal = "Normal"
    case strong = "Strong"
    
    var multiplier: CGFloat {
        switch self {
        case .weak: return 0.8
        case .normal: return 1.0
        case .strong: return 1.2
        }
    }
    
    var localizedName: String {
        switch self {
        case .weak: return NSLocalizedString("weak", comment: "")
        case .normal: return NSLocalizedString("normal", comment: "")
        case .strong: return NSLocalizedString("strong", comment: "")
        }
    }
}

struct Container: Identifiable {
    let id: UUID
    var colors: [AppColor]
    var isLocked: Bool
    var weight: ContainerWeight
    
    init(id: UUID = UUID(), colors: [AppColor] = [], isLocked: Bool = false, weight: ContainerWeight = .normal) {
        self.id = id
        self.colors = colors
        self.isLocked = isLocked
        self.weight = weight
    }
}

struct Ball: Identifiable {
    let id: UUID
    var color: AppColor
    var position: CGPoint
    var velocity: CGVector
    
    init(id: UUID = UUID(), color: AppColor, position: CGPoint, velocity: CGVector = .zero) {
        self.id = id
        self.color = color
        self.position = position
        self.velocity = velocity
    }
}

struct MixSpark: Identifiable {
    let id: UUID
    let mixedColor: AppColor
    var position: CGPoint
    var opacity: Double
    var age: TimeInterval
    
    init(id: UUID = UUID(), mixedColor: AppColor, position: CGPoint, opacity: Double = 1.0, age: TimeInterval = 0.0) {
        self.id = id
        self.mixedColor = mixedColor
        self.position = position
        self.opacity = opacity
        self.age = age
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb).uppercased()
    }
    
    func toHex() -> String {
        return hexString
    }
}



