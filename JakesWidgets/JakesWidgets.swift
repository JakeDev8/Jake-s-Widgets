//
//  JakesWidgets.swift
//  JakesWidgetsExtension
//
//  Widget Extension - Complete Fixed Version
//

import WidgetKit
import SwiftUI

// MARK: - Widget Timeline Entry
struct ClockEntry: TimelineEntry
{
    let date: Date
    let config: ClockConfiguration
}

// MARK: - Widget Timeline Provider
struct ClockProvider: TimelineProvider
{
    func placeholder(in context: Context) -> ClockEntry
    {
        ClockEntry(
            date: Date(),
            config: ClockWidgetDataManager.shared.loadConfiguration()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> ())
    {
        let entry = ClockEntry(
            date: Date(),
            config: ClockWidgetDataManager.shared.loadConfiguration()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> ())
    {
        let config = ClockWidgetDataManager.shared.loadConfiguration()
        var entries: [ClockEntry] = []
        
        let updateInterval = config.showSeconds ? 1 : 60
        let currentDate = Date()
        
        for i in 0..<20
        {
            let entryDate = Calendar.current.date(byAdding: .second, value: i * updateInterval, to: currentDate)!
            let entry = ClockEntry(date: entryDate, config: config)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget View
struct PremiumClockWidgetView: View
{
    var entry: ClockProvider.Entry
    
    var body: some View
    {
        ZStack
        {
            // Background
            backgroundView
            
            // Main Content
            VStack(spacing: 0)
            {
                // Top Progress Bar (only for non-Apple Timer layouts)
                if entry.config.showProgressBar && entry.config.progressBarPosition == .top && entry.config.layout != .appleTimer
                {
                    ProgressBarView(config: entry.config, currentTime: entry.date)
                        .padding(.bottom, 8)
                }
                
                Spacer()
                
                // Clock Content
                contentView
                    .frame(maxWidth: .infinity, alignment: entry.config.layout == .appleTimer ? .center : entry.config.alignment.alignment)
                
                // Middle Progress Bar (only for non-Apple Timer layouts)
                if entry.config.showProgressBar && entry.config.progressBarPosition == .middle && entry.config.layout != .appleTimer
                {
                    ProgressBarView(config: entry.config, currentTime: entry.date)
                        .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Bottom Progress Bar (only for non-Apple Timer layouts)
                if entry.config.showProgressBar && entry.config.progressBarPosition == .bottom && entry.config.layout != .appleTimer
                {
                    ProgressBarView(config: entry.config, currentTime: entry.date)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, entry.config.layout == .appleTimer ? 20 : 16)
            .padding(.vertical, 12)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View
    {
        switch entry.config.backgroundStyle
        {
        case .solid:
            Color(hex: entry.config.backgroundColor)
        case .gradient:
            LinearGradient(
                colors: entry.config.gradientColors.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blur:
            Color(hex: entry.config.backgroundColor).blur(radius: 5)
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View
    {
        switch entry.config.layout
        {
        case .stacked:
            stackedLayout
        case .sideBySide:
            sideBySideLayout
        case .timeOnly:
            timeOnlyLayout
        case .appleTimer:
            appleTimerLayout
        }
    }
    
    // MARK: - Layout Views
    private var stackedLayout: some View
    {
        VStack(spacing: entry.config.spacing.spacing)
        {
            VStack(spacing: entry.config.spacing.spacing / 2)
            {
                Text(timeString)
                    .font(timeFont)
                    .foregroundColor(Color(hex: entry.config.textColor))
                    .shadow(color: entry.config.shadowEnabled ? .black.opacity(0.3) : .clear, radius: 2)
                
                if entry.config.showSeconds
                {
                    Text(secondsString)
                        .font(secondsFont)
                        .foregroundColor(Color(hex: entry.config.accentColor))
                        .opacity(0.8)
                }
            }
            
            if entry.config.showDate && !dateString.isEmpty
            {
                Text(dateString)
                    .font(dateFont)
                    .foregroundColor(Color(hex: entry.config.textColor).opacity(0.8))
            }
        }
        .multilineTextAlignment(entry.config.alignment.textAlignment)
    }
    
    private var sideBySideLayout: some View
    {
        HStack(spacing: entry.config.spacing.spacing * 2)
        {
            VStack(spacing: entry.config.spacing.spacing / 2)
            {
                Text(timeString)
                    .font(timeFont)
                    .foregroundColor(Color(hex: entry.config.textColor))
                    .shadow(color: entry.config.shadowEnabled ? .black.opacity(0.3) : .clear, radius: 2)
                
                if entry.config.showSeconds
                {
                    Text(secondsString)
                        .font(secondsFont)
                        .foregroundColor(Color(hex: entry.config.accentColor))
                        .opacity(0.8)
                }
            }
            
            if entry.config.showDate && !dateString.isEmpty
            {
                Text(dateString)
                    .font(dateFont)
                    .foregroundColor(Color(hex: entry.config.textColor).opacity(0.8))
            }
        }
    }
    
    private var timeOnlyLayout: some View
    {
        VStack(spacing: entry.config.spacing.spacing / 2)
        {
            Text(timeString)
                .font(timeFont)
                .foregroundColor(Color(hex: entry.config.textColor))
                .shadow(color: entry.config.shadowEnabled ? .black.opacity(0.3) : .clear, radius: 2)
            
            if entry.config.showSeconds
            {
                Text(secondsString)
                    .font(secondsFont)
                    .foregroundColor(Color(hex: entry.config.accentColor))
                    .opacity(0.8)
            }
        }
    }
    
    private var appleTimerLayout: some View
    {
        VStack(spacing: 0)
        {
            Spacer()
            
            // Main time display
            VStack(spacing: 8)
            {
                HStack(spacing: 4)
                {
                    // Main time
                    Text(timeString)
                        .font(.system(size: 72, weight: entry.config.timeFontWeight.fontWeight, design: .rounded))
                        .foregroundColor(Color(hex: entry.config.textColor))
                        .monospacedDigit()
                        .shadow(color: entry.config.shadowEnabled ? .black.opacity(0.3) : .clear, radius: 2)
                    
                    // Seconds
                    if entry.config.showSeconds
                    {
                        VStack(spacing: 0)
                        {
                            Spacer()
                            Text(secondsString)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: entry.config.accentColor))
                                .monospacedDigit()
                                .opacity(0.8)
                            Spacer()
                        }
                    }
                }
                
                // Date
                if entry.config.showDate && !dateString.isEmpty
                {
                    Text(dateString)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: entry.config.textColor).opacity(0.7))
                }
            }
            
            Spacer()
            
            // Day Progress Bar
            VStack(spacing: 0)
            {
                GeometryReader { geometry in
                    ZStack(alignment: .leading)
                    {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: entry.config.textColor).opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: entry.config.textColor).opacity(0.6))
                            .frame(width: geometry.size.width * dayProgress, height: 4)
                            .animation(.linear(duration: 1), value: dayProgress)
                    }
                }
                .frame(height: 4)
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Computed Properties
    private var timeString: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = entry.config.use24HourFormat ? "HH:mm" : "h:mm"
        return formatter.string(from: entry.date)
    }
    
    private var secondsString: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: entry.date)
    }
    
    private var dateString: String
    {
        guard entry.config.dateFormat != .none else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = entry.config.dateFormat.rawValue
        return formatter.string(from: entry.date)
    }
    
    private var timeFont: Font
    {
        let size = entry.config.timeFontSize.timeSize
        let weight = entry.config.timeFontWeight.fontWeight
        
        switch entry.config.timeFont
        {
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
    
    private var secondsFont: Font
    {
        let size = entry.config.timeFontSize.secondsSize
        return .system(size: size, weight: .regular, design: .rounded)
    }
    
    private var dateFont: Font
    {
        let size = entry.config.timeFontSize.dateSize
        
        switch entry.config.dateFont
        {
        case .system:
            return .system(size: size, weight: .medium)
        case .rounded:
            return .system(size: size, weight: .medium, design: .rounded)
        case .serif:
            return .system(size: size, weight: .medium, design: .serif)
        }
    }
    
    // Day Progress Calculation
    private var dayProgress: Double
    {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: entry.date)
        let minute = calendar.component(.minute, from: entry.date)
        let second = calendar.component(.second, from: entry.date)
        
        let totalSecondsToday = (hour * 3600) + (minute * 60) + second
        let totalSecondsInDay = 24 * 60 * 60
        
        return Double(totalSecondsToday) / Double(totalSecondsInDay)
    }
}

// MARK: - Progress Bar View Component
struct ProgressBarView: View
{
    let config: ClockConfiguration
    let currentTime: Date
    
    var body: some View
    {
        GeometryReader { geometry in
            ZStack(alignment: .leading)
            {
                RoundedRectangle(cornerRadius: config.progressBarHeight.height / 2)
                    .fill(Color(hex: config.textColor).opacity(0.2))
                    .frame(height: config.progressBarHeight.height)
                
                RoundedRectangle(cornerRadius: config.progressBarHeight.height / 2)
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * dayProgress, height: config.progressBarHeight.height)
                    .animation(.easeInOut(duration: 1.0), value: dayProgress)
            }
        }
        .frame(height: config.progressBarHeight.height)
    }
    
    private var dayProgress: Double
    {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let second = calendar.component(.second, from: currentTime)
        
        let totalSeconds = (hour * 3600) + (minute * 60) + second
        let totalSecondsInDay = 24 * 60 * 60
        
        return Double(totalSeconds) / Double(totalSecondsInDay)
    }
    
    private var progressGradient: LinearGradient
    {
        let progress = dayProgress
        
        switch config.progressBarStyle
        {
        case .dayProgression:
            if progress < 0.25
            {
                return LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing)
            }
            else if progress < 0.5
            {
                return LinearGradient(colors: [Color.blue, Color.cyan, Color.yellow], startPoint: .leading, endPoint: .trailing)
            }
            else if progress < 0.75
            {
                return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing)
            }
            else
            {
                return LinearGradient(colors: [Color.orange, Color.red, Color.purple], startPoint: .leading, endPoint: .trailing)
            }
            
        case .solid:
            return LinearGradient(colors: [Color(hex: config.accentColor)], startPoint: .leading, endPoint: .trailing)
            
        case .pulsing:
            return LinearGradient(colors: [Color(hex: config.accentColor), Color(hex: config.accentColor).opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// MARK: - Widget Definition
struct JakesWidgets: Widget
{
    let kind: String = "JakesWidgets"

    var body: some WidgetConfiguration
    {
        StaticConfiguration(kind: kind, provider: ClockProvider()) { entry in
            PremiumClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Jake's Premium Clock")
        .description("Fully customizable clock widget for StandBy mode")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
