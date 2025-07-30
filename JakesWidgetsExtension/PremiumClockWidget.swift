//
//  PremiumClockWidget.swift
//  JakesWidgetsExtension
//
//  Widget Extension Target
//

import WidgetKit
import SwiftUI

// MARK: - Copy Configuration Models (Same as main app)
struct ClockConfiguration: Codable {
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
        timeFont: .system,
        timeFontSize: .large,
        timeFontWeight: .medium,
        dateFont: .system,
        layout: .stacked,
        alignment: .center,
        spacing: .normal,
        shadowEnabled: true,
        glowEnabled: false,
        animationStyle: .none,
        timezone: TimeZone.current.identifier,
        showTimezone: false
    )
}

// Copy all the enums from your main app
enum DateDisplayFormat: String, Codable, CaseIterable {
    case monthDayYear = "MMM d, yyyy"
    case dayMonthYear = "d MMM yyyy"
    case shortDate = "M/d/yy"
    case dayOfWeek = "EEEE"
    case dayOfWeekShort = "EEE"
    case none = ""
}

enum BackgroundStyle: String, Codable, CaseIterable {
    case solid, gradient, blur
}

enum TimeFontStyle: String, Codable, CaseIterable {
    case system, rounded, monospaced, serif
}

enum FontSizeOption: String, Codable, CaseIterable {
    case small, medium, large, extraLarge
    var timeSize: CGFloat {
        switch self {
        case .small: return 28
        case .medium: return 36
        case .large: return 44
        case .extraLarge: return 52
        }
    }
    var dateSize: CGFloat { timeSize * 0.4 }
    var secondsSize: CGFloat { timeSize * 0.5 }
}

enum FontWeightOption: String, Codable, CaseIterable {
    case light, regular, medium, semibold, bold
    var fontWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}

enum DateFontStyle: String, Codable, CaseIterable {
    case system, rounded, serif
}

enum ClockLayout: String, Codable, CaseIterable {
    case stacked, sideBySide, timeOnly
}

enum TextAlignmentOption: String, Codable, CaseIterable {
    case leading, center, trailing
    var alignment: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
    var textAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum SpacingOption: String, Codable, CaseIterable {
    case tight, normal, loose
    var spacing: CGFloat {
        switch self {
        case .tight: return 4
        case .normal: return 8
        case .loose: return 16
        }
    }
}

enum AnimationStyle: String, Codable, CaseIterable {
    case none, fade, scale, bounce
}

// MARK: - Widget Data Manager
class ClockWidgetDataManager {
    static let shared = ClockWidgetDataManager()
    
    // IMPORTANT: Use the SAME App Group ID you created
    private let userDefaults = UserDefaults(suiteName: "group.com.jakedev.jakeswidgets")
    private let configKey = "premiumClockConfig"
    
    func loadConfiguration() -> ClockConfiguration {
        guard let data = userDefaults?.data(forKey: configKey),
              let config = try? JSONDecoder().decode(ClockConfiguration.self, from: data) else {
            print("📱 Using default clock config in widget")
            return .default
        }
        print("✅ Clock config loaded in widget")
        return config
    }
}

// MARK: - Widget Timeline Entry
struct ClockEntry: TimelineEntry {
    let date: Date
    let config: ClockConfiguration
}

// MARK: - Widget Timeline Provider
struct ClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(
            date: Date(),
            config: ClockWidgetDataManager.shared.loadConfiguration()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> ()) {
        let entry = ClockEntry(
            date: Date(),
            config: ClockWidgetDataManager.shared.loadConfiguration()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> ()) {
        let config = ClockWidgetDataManager.shared.loadConfiguration()
        var entries: [ClockEntry] = []
        
        // Update every second if showing seconds, otherwise every minute
        let updateInterval = config.showSeconds ? 1 : 60
        let currentDate = Date()
        
        // Generate 20 timeline entries
        for i in 0..<20 {
            let entryDate = Calendar.current.date(byAdding: .second, value: i * updateInterval, to: currentDate)!
            let entry = ClockEntry(date: entryDate, config: config)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget View
struct PremiumClockWidgetView: View {
    var entry: ClockProvider.Entry
    @State private var animationTrigger = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: entry.config.alignment.alignment)
        }
        .onAppear {
            if entry.config.animationStyle != .none {
                animationTrigger.toggle()
            }
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch entry.config.backgroundStyle {
        case .solid:
            Color(hex: entry.config.backgroundColor)
        case .gradient:
            LinearGradient(
                colors: entry.config.gradientColors.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blur:
            Color(hex: entry.config.backgroundColor)
                .blur(radius: 10)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch entry.config.layout {
        case .stacked:
            stackedLayout
        case .sideBySide:
            sideBySideLayout
        case .timeOnly:
            timeOnlyLayout
        }
    }
    
    private var stackedLayout: some View {
        VStack(spacing: entry.config.spacing.spacing) {
            timeDisplay
            if entry.config.showDate {
                dateDisplay
            }
            if entry.config.showTimezone {
                timezoneDisplay
            }
        }
        .multilineTextAlignment(entry.config.alignment.textAlignment)
    }
    
    private var sideBySideLayout: some View {
        HStack(spacing: entry.config.spacing.spacing * 2) {
            timeDisplay
            if entry.config.showDate {
                dateDisplay
            }
        }
    }
    
    private var timeOnlyLayout: some View {
        timeDisplay
    }
    
    private var timeDisplay: some View {
        VStack(spacing: entry.config.spacing.spacing / 2) {
            Text(timeString)
                .font(timeFont)
                .foregroundColor(Color(hex: entry.config.textColor))
                .shadow(
                    color: entry.config.shadowEnabled ? .black.opacity(0.3) : .clear,
                    radius: 2
                )
                .overlay(
                    Group {
                        if entry.config.glowEnabled {
                            Text(timeString)
                                .font(timeFont)
                                .foregroundColor(.clear)
                                .background(Color(hex: entry.config.accentColor))
                                .blur(radius: 10)
                                .mask(Text(timeString).font(timeFont))
                        }
                    }
                )
                .scaleEffect(animationScale)
            
            if entry.config.showSeconds {
                Text(secondsString)
                    .font(secondsFont)
                    .foregroundColor(Color(hex: entry.config.accentColor))
                    .opacity(0.8)
            }
        }
    }
    
    private var dateDisplay: some View {
        Text(dateString)
            .font(dateFont)
            .foregroundColor(Color(hex: entry.config.textColor).opacity(0.8))
            .shadow(
                color: entry.config.shadowEnabled ? .black.opacity(0.2) : .clear,
                radius: 1
            )
    }
    
    private var timezoneDisplay: some View {
        Text(timezoneString)
            .font(.caption2)
            .foregroundColor(Color(hex: entry.config.accentColor))
            .opacity(0.6)
    }
    
    // MARK: - Computed Properties
    private var timeString: String {
        let timezone = TimeZone(identifier: entry.config.timezone) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = entry.config.use24HourFormat ? "HH:mm" : "h:mm"
        return formatter.string(from: entry.date)
    }
    
    private var secondsString: String {
        let timezone = TimeZone(identifier: entry.config.timezone) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = "ss"
        return formatter.string(from: entry.date)
    }
    
    private var dateString: String {
        guard entry.config.dateFormat != .none else { return "" }
        let timezone = TimeZone(identifier: entry.config.timezone) ?? TimeZone.current
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = entry.config.dateFormat.rawValue
        return formatter.string(from: entry.date)
    }
    
    private var timezoneString: String {
        let timezone = TimeZone(identifier: entry.config.timezone) ?? TimeZone.current
        return timezone.abbreviation() ?? ""
    }
    
    private var timeFont: Font {
        let size = entry.config.timeFontSize.timeSize
        let weight = entry.config.timeFontWeight.fontWeight
        
        switch entry.config.timeFont {
        case .system:
            return .system(size: size, weight: weight)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        }
    }
    
    private var secondsFont: Font {
        let size = entry.config.timeFontSize.secondsSize
        return .system(size: size, weight: .regular, design: .rounded)
    }
    
    private var dateFont: Font {
        let size = entry.config.timeFontSize.dateSize
        
        switch entry.config.dateFont {
        case .system:
            return .system(size: size, weight: .medium)
        case .rounded:
            return .system(size: size, weight: .medium, design: .rounded)
        case .serif:
            return .system(size: size, weight: .medium, design: .serif)
        }
    }
    
    private var animationScale: CGFloat {
        switch entry.config.animationStyle {
        case .scale:
            return animationTrigger ? 1.02 : 1.0
        case .bounce:
            return animationTrigger ? 1.05 : 1.0
        default:
            return 1.0
        }
    }
}

// MARK: - Widget Definition
struct PremiumClockWidget: Widget {
    let kind: String = "PremiumClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockProvider()) { entry in
            PremiumClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Jake's Premium Clock")
        .description("Fully customizable clock widget for StandBy mode")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// MARK: - Widget Bundle (Replace the generated bundle)
@main
struct JakesWidgetBundle: WidgetBundle {
    var body: some Widget {
        PremiumClockWidget()
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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
}
