//
//  ColorGenerator.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI

class ColorGenerator {
    static let shared = ColorGenerator()
    
    private init() {}
    
    func generateColors(mode: GenerationMode, count: Int) -> [AppColor] {
        switch mode {
        case .random:
            return generateRandomColors(count: count)
        case .pastel:
            return generatePastelColors(count: count)
        case .vivid:
            return generateVividColors(count: count)
        case .custom:
            return []
        }
    }
    
    private func generateRandomColors(count: Int) -> [AppColor] {
        (0..<count).map { _ in
            let hue = Double.random(in: 0...1)
            let saturation = Double.random(in: 0.3...1.0)
            let brightness = Double.random(in: 0.4...1.0)
            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            return AppColor(hex: color.hexString)
        }
    }
    
    private func generatePastelColors(count: Int) -> [AppColor] {
        (0..<count).map { _ in
            let hue = Double.random(in: 0...1)
            let saturation = Double.random(in: 0.2...0.5)
            let brightness = Double.random(in: 0.7...1.0)
            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            return AppColor(hex: color.hexString)
        }
    }
    
    private func generateVividColors(count: Int) -> [AppColor] {
        (0..<count).map { _ in
            let hue = Double.random(in: 0...1)
            let saturation = Double.random(in: 0.7...1.0)
            let brightness = Double.random(in: 0.6...1.0)
            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            return AppColor(hex: color.hexString)
        }
    }
    
    func generateOneTapInspiration() -> (name: String, colors: [AppColor]) {
        let inspirations = [
            ("Summer Vibes", ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#6C5CE7"]),
            ("Warm Earth", ["#D4A574", "#C9A57A", "#B8926A", "#A67C52", "#8B6F47", "#6B5233"]),
            ("Dream Mix", ["#6C5CE7", "#FD79A8", "#FDCB6E", "#55E6C1", "#00B894", "#A29BFE"])
        ]
        
        let selected = inspirations.randomElement()!
        return (
            name: selected.0,
            colors: selected.1.map { AppColor(hex: $0) }
        )
    }
    
    func shuffleColors(_ colors: [AppColor]) -> [AppColor] {
        colors.shuffled()
    }
    
    func sortLightToDark(_ colors: [AppColor]) -> [AppColor] {
        colors.sorted { c1, c2 in
            let brightness1 = c1.uiColor.brightness
            let brightness2 = c2.uiColor.brightness
            return brightness1 < brightness2
        }
    }
    
    func sortDarkToLight(_ colors: [AppColor]) -> [AppColor] {
        colors.sorted { c1, c2 in
            let brightness1 = c1.uiColor.brightness
            let brightness2 = c2.uiColor.brightness
            return brightness1 > brightness2
        }
    }
    
    func applyTemperatureShift(_ colors: [AppColor], shift: CGFloat) -> [AppColor] {
        colors.map { color in
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            hue += shift
            if hue > 1.0 { hue -= 1.0 }
            if hue < 0.0 { hue += 1.0 }
            
            let newColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            return AppColor(hex: newColor.hexString)
        }
    }
}

extension UIColor {
    var brightness: CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r * 0.299 + g * 0.587 + b * 0.114)
    }
}

