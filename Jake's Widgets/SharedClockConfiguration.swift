//
//  SharedClockConfiguration.swift
//  Jake's Widgets
//
//  Shared configuration models for both main app and widget extension
//

import SwiftUI
import Foundation

// MARK: - WidgetColor Enum (Shared)
enum WidgetColor: String, CaseIterable, Codable
{
    case black, blue, purple, orange, green, pink, indigo, mint, teal, brown, red, yellow, gray, cyan
    
    var color: Color
    {
        switch self
        {
        case .black: return .black
        case .blue: return .blue
        case .purple: return .purple
        case .orange: return .orange
        case .green: return .green
        case .pink: return .pink
        case .indigo: return .indigo
        case .mint: return .mint
        case .teal: return .teal
        case .brown: return .brown
        case .red: return .red
        case .yellow: return .yellow
        case .gray: return .gray
        case .cyan: return .cyan
        }
    }
}

// MARK: - Clock Configuration Model (Shared between main app and widget)
struct ClockConfiguration: Codable
{
    var use24HourFormat: Bool
    var showSeconds: Bool
    var showDate: Bool
    var dateFormat: DateDisplayFormat
    var backgroundStyle: BackgroundStyle
    var backgroundColor: String
    var gradientColors: [String]
    var textColor: String
    var accentColor: String
    var timeFont: TimeFontStyle
    var timeFontSize: FontSizeOption
    var timeFontWeight: FontWeightOption
    var dateFont: DateFontStyle
    var layout: ClockLayout
    var alignment: TextAlignmentOption
    var spacing: SpacingOption
    var shadowEnabled: Bool
    var glowEnabled: Bool
    var animationStyle: AnimationStyle
    var timezone: String
    var showTimezone: Bool
    var showProgressBar: Bool
    var progressBarHeight: ProgressBarHeight
    var progressBarPosition: ProgressBarPosition
    var progressBarStyle: ProgressBarStyle
    
    static let `default` = ClockConfiguration(
        use24HourFormat: false,
        showSeconds: true,
        showDate: true,
        dateFormat: .monthDayYear,
        backgroundStyle: .solid,
        backgroundColor: "#000000",
        gradientColors: ["#000000", "#1a1a1a"],
        textColor: "#FFFFFF",
        accentColor: "#007AFF",
        timeFont: .rounded,
        timeFontSize: .large,
        timeFontWeight: .medium,
        dateFont: .system,
        layout: .appleTimer,
        alignment: .center,
        spacing: .normal,
        shadowEnabled: true,
        glowEnabled: false,
        animationStyle: .none,
        timezone: TimeZone.current.identifier,
        showTimezone: false,
        showProgressBar: false,
        progressBarHeight: .medium,
        progressBarPosition: .bottom,
        progressBarStyle: .dayProgression
    )
}

// MARK: - Configuration Enums (Shared)
enum DateDisplayFormat: String, Codable, CaseIterable
{
    case monthDayYear = "MMM d, yyyy"
    case dayMonthYear = "d MMM yyyy"
    case shortDate = "M/d/yy"
    case dayOfWeek = "EEEE"
    case dayOfWeekShort = "EEE"
    case none = ""
    
    var displayName: String
    {
        switch self
        {
        case .monthDayYear: return "Jan 1, 2024"
        case .dayMonthYear: return "1 Jan 2024"
        case .shortDate: return "1/1/24"
        case .dayOfWeek: return "Monday"
        case .dayOfWeekShort: return "Mon"
        case .none: return "No Date"
        }
    }
}

enum BackgroundStyle: String, Codable, CaseIterable
{
    case solid, gradient, blur
    
    var displayName: String
    {
        switch self
        {
        case .solid: return "Solid Color"
        case .gradient: return "Gradient"
        case .blur: return "Blurred"
        }
    }
}

enum TimeFontStyle: String, Codable, CaseIterable
{
    case system, rounded, monospaced, serif
    
    var displayName: String { rawValue.capitalized }
}

enum FontSizeOption: String, Codable, CaseIterable
{
    case small, medium, large, extraLarge
    
    var displayName: String { rawValue.capitalized }
    
    var timeSize: CGFloat
    {
        switch self
        {
        case .small: return 24
        case .medium: return 32
        case .large: return 40
        case .extraLarge: return 48
        }
    }
    
    var dateSize: CGFloat { timeSize * 0.4 }
    var secondsSize: CGFloat { timeSize * 0.5 }
}

enum FontWeightOption: String, Codable, CaseIterable
{
    case light, regular, medium, semibold, bold
    
    var displayName: String { rawValue.capitalized }
    
    var fontWeight: Font.Weight
    {
        switch self
        {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}

enum DateFontStyle: String, Codable, CaseIterable
{
    case system, rounded, serif
    
    var displayName: String { rawValue.capitalized }
}

enum ClockLayout: String, Codable, CaseIterable
{
    case stacked, sideBySide, timeOnly, appleTimer
    
    var displayName: String
    {
        switch self
        {
        case .stacked: return "Stacked"
        case .sideBySide: return "Side by Side"
        case .timeOnly: return "Time Only"
        case .appleTimer: return "Apple Timer Style"
        }
    }
}

enum TextAlignmentOption: String, Codable, CaseIterable
{
    case leading, center, trailing
    
    var displayName: String
    {
        switch self
        {
        case .leading: return "Left"
        case .center: return "Center"
        case .trailing: return "Right"
        }
    }
    
    var alignment: Alignment
    {
        switch self
        {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
    
    var textAlignment: TextAlignment
    {
        switch self
        {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum SpacingOption: String, Codable, CaseIterable
{
    case tight, normal, loose
    
    var displayName: String { rawValue.capitalized }
    
    var spacing: CGFloat
    {
        switch self
        {
        case .tight: return 2
        case .normal: return 6
        case .loose: return 12
        }
    }
}

enum AnimationStyle: String, Codable, CaseIterable
{
    case none, fade, scale, bounce
    
    var displayName: String { rawValue.capitalized }
}

enum ProgressBarHeight: String, Codable, CaseIterable
{
    case thin, medium, thick
    
    var height: CGFloat
    {
        switch self
        {
        case .thin: return 2
        case .medium: return 4
        case .thick: return 6
        }
    }
    
    var displayName: String { rawValue.capitalized }
}

enum ProgressBarPosition: String, Codable, CaseIterable
{
    case top, bottom, middle
    
    var displayName: String { rawValue.capitalized }
}

enum ProgressBarStyle: String, Codable, CaseIterable
{
    case dayProgression, solid, pulsing
    
    var displayName: String
    {
        switch self
        {
        case .dayProgression: return "Day Progression"
        case .solid: return "Solid Color"
        case .pulsing: return "Pulsing"
        }
    }
}

// MARK: - Shared Data Manager
class ClockWidgetDataManager
{
    static let shared = ClockWidgetDataManager()
    
    // IMPORTANT: Change this to your actual App Group identifier
    private let userDefaults = UserDefaults(suiteName: "group.com.jakedev.jakeswidgets")
    private let configKey = "premiumClockConfig"
    
    func saveConfiguration(_ config: ClockConfiguration)
    {
        do
        {
            let data = try JSONEncoder().encode(config)
            userDefaults?.set(data, forKey: configKey)
            print("🕐 Clock config saved successfully")
        } catch
        {
            print("❌ Failed to save clock config: \(error)")
        }
    }
    
    func loadConfiguration() -> ClockConfiguration
    {
        guard let data = userDefaults?.data(forKey: configKey),
              let config = try? JSONDecoder().decode(ClockConfiguration.self, from: data) else
        {
            print("📱 Using default clock config")
            return .default
        }
        print("✅ Clock config loaded successfully")
        return config
    }
}

// MARK: - Color Extensions
extension Color
{
    init(hex: String)
    {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count
        {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String
    {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else
        {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
