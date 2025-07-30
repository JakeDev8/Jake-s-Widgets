//
//  PremiumClockConfigurationView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/24/25.
//

import SwiftUI
import WidgetKit

// MARK: - Premium Clock Configuration View
struct PremiumClockConfigurationView: View
{
    @State private var config = ClockWidgetDataManager.shared.loadConfiguration()
    @State private var previewDate = Date()
    @State private var showingSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View
    {
        NavigationView
        {
            ScrollView
            {
                VStack(spacing: 24)
                {
                    previewSection
                    timeFormatSection
                    visualStyleSection
                    typographySection
                    layoutSection
                    progressBarSection
                    effectsSection
                    saveButton
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Premium Clock")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Save") { saveConfiguration() }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .onReceive(timer) { _ in previewDate = Date() }
        .alert("Widget Updated!", isPresented: $showingSaveAlert)
        {
            Button("OK") { dismiss() }
        } message:
        {
            Text("Your clock widget has been updated. You can see the changes in StandBy mode.")
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View
    {
        VStack(spacing: 16)
        {
            HStack
            {
                Text("Live Preview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("Updates every second")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Widget Preview
            ZStack
            {
                // Background
                switch config.backgroundStyle
                {
                case .solid:
                    Color(hex: config.backgroundColor)
                case .gradient:
                    LinearGradient(
                        colors: config.gradientColors.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .blur:
                    Color(hex: config.backgroundColor).blur(radius: 5)
                }
                
                // Clock content with progress bar
                VStack(spacing: 0)
                {
                    // Top Progress Bar
                    if config.showProgressBar && config.progressBarPosition == .top
                    {
                        ProgressBarPreview(config: config, currentTime: previewDate)
                            .padding(.bottom, 8)
                    }
                    
                    Spacer()
                    
                    // Clock Content - Different layouts
                    if config.layout == .appleTimer
                    {
                        appleTimerPreviewContent
                    } else
                    {
                        clockPreviewContent
                            .frame(maxWidth: .infinity, alignment: config.alignment.alignment)
                    }
                    
                    // Middle Progress Bar
                    if config.showProgressBar && config.progressBarPosition == .middle
                    {
                        ProgressBarPreview(config: config, currentTime: previewDate)
                            .padding(.vertical, 8)
                    }
                    
                    Spacer()
                    
                    // Bottom Progress Bar
                    if config.showProgressBar && config.progressBarPosition == .bottom
                    {
                        ProgressBarPreview(config: config, currentTime: previewDate)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Text("This is how your widget will look in StandBy mode")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var clockPreviewContent: some View
    {
        VStack(spacing: config.spacing.spacing)
        {
            VStack(spacing: config.spacing.spacing / 2)
            {
                Text(formattedTime(previewDate))
                    .font(previewTimeFont)
                    .foregroundColor(Color(hex: config.textColor))
                    .shadow(color: config.shadowEnabled ? .black.opacity(0.3) : .clear, radius: 2)
                
                if config.showSeconds
                {
                    Text(formattedSeconds(previewDate))
                        .font(previewSecondsFont)
                        .foregroundColor(Color(hex: config.accentColor))
                        .opacity(0.8)
                }
            }
            
            if config.showDate && !formattedDate(previewDate).isEmpty
            {
                Text(formattedDate(previewDate))
                    .font(previewDateFont)
                    .foregroundColor(Color(hex: config.textColor).opacity(0.8))
            }
        }
        .multilineTextAlignment(config.alignment.textAlignment)
    }
    
    @ViewBuilder
    private var appleTimerPreviewContent: some View
    {
        // Apple Timer Style Layout - Full width
        VStack(spacing: 0)
        {
            Spacer()
            
            // Main time display - Apple Timer style
            VStack(spacing: 6)
            {
                HStack(spacing: 3)
                {
                    // Main time
                    Text(formattedTime(previewDate))
                        .font(.system(size: 32, weight: config.timeFontWeight.fontWeight, design: .rounded))
                        .foregroundColor(Color(hex: config.textColor))
                        .monospacedDigit()
                    
                    // Seconds (smaller, offset)
                    if config.showSeconds
                    {
                        VStack(spacing: 0)
                        {
                            Spacer()
                            Text(formattedSeconds(previewDate))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: config.accentColor))
                                .monospacedDigit()
                            Spacer()
                        }
                    }
                }
                
                // Date below (if enabled)
                if config.showDate && !formattedDate(previewDate).isEmpty
                {
                    Text(formattedDate(previewDate))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color(hex: config.textColor).opacity(0.7))
                }
            }
            
            Spacer()
            
            // Bottom progress indicator (Apple Timer style)
            VStack(spacing: 0)
            {
                GeometryReader { geometry in
                    ZStack(alignment: .leading)
                    {
                        Rectangle()
                            .fill(Color(hex: config.textColor).opacity(0.2))
                            .frame(height: 2)
                        
                        Rectangle()
                            .fill(Color(hex: config.textColor).opacity(0.6))
                            .frame(width: geometry.size.width * dayProgress, height: 2)
                    }
                }
                .frame(height: 2)
            }
            .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Helper functions for layout options
    private func layoutIcon(for layout: ClockLayout) -> String
    {
        switch layout
        {
        case .stacked: return "rectangle.stack"
        case .sideBySide: return "rectangle.split.2x1"
        case .timeOnly: return "clock"
        case .appleTimer: return "timer"
        }
    }
    
    private func layoutDescription(for layout: ClockLayout) -> String
    {
        switch layout
        {
        case .stacked: return "Time above date, centered"
        case .sideBySide: return "Time and date side by side"
        case .timeOnly: return "Just the time, no date"
        case .appleTimer: return "Full-width Apple Timer style"
        }
    }
    
    private var dayProgress: Double
    {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: previewDate)
        let minute = calendar.component(.minute, from: previewDate)
        let second = calendar.component(.second, from: previewDate)
        
        // Calculate total seconds since midnight
        let totalSecondsToday = (hour * 3600) + (minute * 60) + second
        let totalSecondsInDay = 24 * 60 * 60
        
        return Double(totalSecondsToday) / Double(totalSecondsInDay)
    }
    
    // MARK: - Configuration Sections
    private var timeFormatSection: some View
    {
        ConfigurationSection(title: "Time Format", icon: "clock")
        {
            VStack(spacing: 16)
            {
                Toggle("24 Hour Format", isOn: $config.use24HourFormat)
                Toggle("Show Seconds", isOn: $config.showSeconds)
                Toggle("Show Date", isOn: $config.showDate)
                
                if config.showDate
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Date Format").font(.subheadline).fontWeight(.medium)
                        Picker("Date Format", selection: $config.dateFormat)
                        {
                            ForEach(DateDisplayFormat.allCases, id: \.self) { format in
                                Text(format.displayName).tag(format)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
        }
    }
    
    private var visualStyleSection: some View
    {
        ConfigurationSection(title: "Visual Style", icon: "paintbrush")
        {
            VStack(spacing: 20)
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Background Style").font(.subheadline).fontWeight(.medium)
                    Picker("Background Style", selection: $config.backgroundStyle)
                    {
                        ForEach(BackgroundStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if config.backgroundStyle == .solid || config.backgroundStyle == .blur
                {
                    ColorPickerRow(
                        title: "Background Color",
                        color: Binding(
                            get: { Color(hex: config.backgroundColor) },
                            set: { config.backgroundColor = $0.toHex() }
                        )
                    )
                }
                
                ColorPickerRow(
                    title: "Text Color",
                    color: Binding(
                        get: { Color(hex: config.textColor) },
                        set: { config.textColor = $0.toHex() }
                    )
                )
                
                ColorPickerRow(
                    title: "Accent Color",
                    color: Binding(
                        get: { Color(hex: config.accentColor) },
                        set: { config.accentColor = $0.toHex() }
                    )
                )
            }
        }
    }
    
    private var typographySection: some View
    {
        ConfigurationSection(title: "Typography", icon: "textformat")
        {
            VStack(spacing: 16)
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Time Font Style").font(.subheadline).fontWeight(.medium)
                    Picker("Time Font", selection: $config.timeFont)
                    {
                        ForEach(TimeFontStyle.allCases, id: \.self) { font in
                            Text(font.displayName).tag(font)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Font Size").font(.subheadline).fontWeight(.medium)
                    Picker("Font Size", selection: $config.timeFontSize)
                    {
                        ForEach(FontSizeOption.allCases, id: \.self) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Font Weight").font(.subheadline).fontWeight(.medium)
                    Picker("Font Weight", selection: $config.timeFontWeight)
                    {
                        ForEach(FontWeightOption.allCases, id: \.self) { weight in
                            Text(weight.displayName).tag(weight)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
    
    private var layoutSection: some View
    {
        ConfigurationSection(title: "Layout Style", icon: "rectangle.3.group")
        {
            VStack(spacing: 16)
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Clock Layout").font(.subheadline).fontWeight(.medium)
                    
                    // Layout picker with descriptions
                    VStack(spacing: 8)
                    {
                        ForEach(ClockLayout.allCases, id: \.self) { layout in
                            Button(action: { config.layout = layout })
                            {
                                HStack
                                {
                                    // Layout preview icon
                                    Image(systemName: layoutIcon(for: layout))
                                        .font(.title2)
                                        .foregroundColor(config.layout == layout ? .blue : .secondary)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2)
                                    {
                                        Text(layout.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(config.layout == layout ? .blue : .primary)
                                        
                                        Text(layoutDescription(for: layout))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: config.layout == layout ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(config.layout == layout ? .blue : .secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(config.layout == layout ? Color.blue.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                if config.layout != .appleTimer
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Text Alignment").font(.subheadline).fontWeight(.medium)
                        Picker("Alignment", selection: $config.alignment)
                        {
                            ForEach(TextAlignmentOption.allCases, id: \.self) { alignment in
                                Text(alignment.displayName).tag(alignment)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Element Spacing").font(.subheadline).fontWeight(.medium)
                        Picker("Spacing", selection: $config.spacing)
                        {
                            ForEach(SpacingOption.allCases, id: \.self) { spacing in
                                Text(spacing.displayName).tag(spacing)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
        }
    }
    
    private var progressBarSection: some View
    {
        ConfigurationSection(title: "Progress Bar", icon: "chart.bar.horizontal")
        {
            VStack(spacing: 16)
            {
                if config.layout == .appleTimer
                {
                    VStack(spacing: 8)
                    {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Apple Timer Style")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("This layout includes a built-in progress bar that shows your progress through the entire day - from midnight to midnight.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                } else
                {
                    Toggle("Show Progress Bar", isOn: $config.showProgressBar)
                    
                    if config.showProgressBar
                    {
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Progress Bar Style").font(.subheadline).fontWeight(.medium)
                            Picker("Progress Bar Style", selection: $config.progressBarStyle)
                            {
                                ForEach(ProgressBarStyle.allCases, id: \.self) { style in
                                    Text(style.displayName).tag(style)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Height").font(.subheadline).fontWeight(.medium)
                            Picker("Height", selection: $config.progressBarHeight)
                            {
                                ForEach(ProgressBarHeight.allCases, id: \.self) { height in
                                    Text(height.displayName).tag(height)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Position").font(.subheadline).fontWeight(.medium)
                            Picker("Position", selection: $config.progressBarPosition)
                            {
                                ForEach(ProgressBarPosition.allCases, id: \.self) { position in
                                    Text(position.displayName).tag(position)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var effectsSection: some View
    {
        ConfigurationSection(title: "Effects", icon: "wand.and.stars")
        {
            VStack(spacing: 16)
            {
                Toggle("Drop Shadow", isOn: $config.shadowEnabled)
                Toggle("Glow Effect", isOn: $config.glowEnabled)
            }
        }
    }
    
    private var saveButton: some View
    {
        Button(action: saveConfiguration)
        {
            HStack
            {
                Image(systemName: "checkmark.circle.fill")
                Text("Save to Widget").fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    private func saveConfiguration()
    {
        ClockWidgetDataManager.shared.saveConfiguration(config)
        WidgetCenter.shared.reloadTimelines(ofKind: "JakesWidgets")
        showingSaveAlert = true
    }
    
    private func formattedTime(_ date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = config.use24HourFormat ? "HH:mm" : "h:mm"
        return formatter.string(from: date)
    }
    
    private func formattedSeconds(_ date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String
    {
        guard config.dateFormat != .none else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = config.dateFormat.rawValue
        return formatter.string(from: date)
    }
    
    private var previewTimeFont: Font
    {
        let size = max(config.timeFontSize.timeSize * 0.7, 16)
        let weight = config.timeFontWeight.fontWeight
        
        switch config.timeFont
        {
        case .system: return .system(size: size, weight: weight)
        case .rounded: return .system(size: size, weight: weight, design: .rounded)
        case .monospaced: return .system(size: size, weight: weight, design: .monospaced)
        case .serif: return .system(size: size, weight: weight, design: .serif)
        }
    }
    
    private var previewSecondsFont: Font
    {
        let size = max(config.timeFontSize.secondsSize * 0.7, 10)
        return .system(size: size, weight: .regular, design: .rounded)
    }
    
    private var previewDateFont: Font
    {
        let size = max(config.timeFontSize.dateSize * 0.7, 10)
        
        switch config.dateFont
        {
        case .system: return .system(size: size, weight: .medium)
        case .rounded: return .system(size: size, weight: .medium, design: .rounded)
        case .serif: return .system(size: size, weight: .medium, design: .serif)
        }
    }
}

// MARK: - Supporting Views
struct ConfigurationSection<Content: View>: View
{
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            HStack(spacing: 8)
            {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            content
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ColorPickerRow: View
{
    let title: String
    @Binding var color: Color
    
    var body: some View
    {
        HStack
        {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            ColorPicker("", selection: $color)
                .labelsHidden()
                .frame(width: 40, height: 30)
        }
    }
}

// MARK: - Progress Bar Preview Component
struct ProgressBarPreview: View
{
    let config: ClockConfiguration
    let currentTime: Date
    
    var body: some View
    {
        GeometryReader { geometry in
            ZStack(alignment: .leading)
            {
                // Background track
                RoundedRectangle(cornerRadius: config.progressBarHeight.height / 2)
                    .fill(Color(hex: config.textColor).opacity(0.2))
                    .frame(height: config.progressBarHeight.height)
                
                // Progress fill
                RoundedRectangle(cornerRadius: config.progressBarHeight.height / 2)
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * dayProgress, height: config.progressBarHeight.height)
                    .animation(.easeInOut(duration: 1.0), value: dayProgress)
            }
        }
        .frame(height: config.progressBarHeight.height)
    }
    
    // Calculate progress through the day (0.0 to 1.0)
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
    
    // Dynamic color based on time of day
    private var progressGradient: LinearGradient
    {
        let progress = dayProgress
        
        switch config.progressBarStyle
        {
        case .dayProgression:
            // Morning (0-0.25): Purple to Blue
            if progress < 0.25
            {
                return LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            // Morning to Noon (0.25-0.5): Blue to Yellow
            else if progress < 0.5
            {
                return LinearGradient(
                    colors: [Color.blue, Color.cyan, Color.yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            // Afternoon (0.5-0.75): Yellow to Orange
            else if progress < 0.75
            {
                return LinearGradient(
                    colors: [Color.yellow, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            // Evening to Night (0.75-1.0): Orange to Purple
            else
            {
                return LinearGradient(
                    colors: [Color.orange, Color.red, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            
        case .solid:
            return LinearGradient(
                colors: [Color(hex: config.accentColor)],
                startPoint: .leading,
                endPoint: .trailing
            )
            
        case .pulsing:
            return LinearGradient(
                colors: [Color(hex: config.accentColor), Color(hex: config.accentColor).opacity(0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}
