//
//  ViewManager.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/23/25.
//

import SwiftUI
import Foundation

// MARK: - WidgetColor Enum
enum WidgetColor: String, CaseIterable
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

// MARK: - Manual Codable for WidgetColor
extension WidgetColor: Codable
{
    init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = WidgetColor(rawValue: rawValue) ?? .blue
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// MARK: - Widget Struct
struct Widget: Identifiable
{
    let id: UUID
    let name: String
    let category: String
    let backgroundColor: WidgetColor
    let iconName: String
    let description: String
    let isNew: Bool
    
    init(name: String, category: String, backgroundColor: WidgetColor, iconName: String, description: String, isNew: Bool = false)
    {
        self.id = UUID()
        self.name = name
        self.category = category
        self.backgroundColor = backgroundColor
        self.iconName = iconName
        self.description = description
        self.isNew = isNew
    }
}

// MARK: - Manual Codable for Widget
extension Widget: Codable
{
    enum CodingKeys: String, CodingKey
    {
        case id, name, category, backgroundColor, iconName, description, isNew
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        backgroundColor = try container.decode(WidgetColor.self, forKey: .backgroundColor)
        iconName = try container.decode(String.self, forKey: .iconName)
        description = try container.decode(String.self, forKey: .description)
        isNew = try container.decode(Bool.self, forKey: .isNew)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(description, forKey: .description)
        try container.encode(isNew, forKey: .isNew)
    }
}

// MARK: - WidgetView Model
struct WidgetView: Identifiable
{
    let id: UUID
    var name: String
    var leftWidget: Widget?
    var rightWidget: Widget?
    
    init(name: String, leftWidget: Widget? = nil, rightWidget: Widget? = nil)
    {
        self.id = UUID()
        self.name = name
        self.leftWidget = leftWidget
        self.rightWidget = rightWidget
    }
}

// MARK: - Manual Codable for WidgetView
extension WidgetView: Codable
{
    enum CodingKeys: String, CodingKey
    {
        case id, name, leftWidget, rightWidget
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        leftWidget = try container.decodeIfPresent(Widget.self, forKey: .leftWidget)
        rightWidget = try container.decodeIfPresent(Widget.self, forKey: .rightWidget)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(leftWidget, forKey: .leftWidget)
        try container.encodeIfPresent(rightWidget, forKey: .rightWidget)
    }
}

// MARK: - ViewManager Class
class ViewManager: ObservableObject
{
    @Published var widgetViews: [WidgetView] = []
    
    private let persistenceManager = PersistenceManager.shared
    
    // Available widgets for selection
    let availableWidgets: [Widget] = [
        Widget(name: "Minimal Clock", category: "Time", backgroundColor: .black, iconName: "clock.fill", description: "Clean time display perfect for StandBy mode", isNew: false),
        Widget(name: "Weather Now", category: "Weather", backgroundColor: .blue, iconName: "cloud.sun.fill", description: "Current weather conditions and temperature", isNew: false),
        Widget(name: "Next Event", category: "Calendar", backgroundColor: .purple, iconName: "calendar", description: "Shows your upcoming calendar events", isNew: true),
        Widget(name: "Photo Frame", category: "Photos", backgroundColor: .orange, iconName: "photo.fill", description: "Rotating photos from your library", isNew: false),
        Widget(name: "Workout Timer", category: "Fitness", backgroundColor: .green, iconName: "figure.run", description: "Track your exercise sessions", isNew: false),
        Widget(name: "Daily Quote", category: "Lifestyle", backgroundColor: .pink, iconName: "quote.bubble.fill", description: "Inspirational quotes to start your day", isNew: true),
        Widget(name: "Stock Ticker", category: "Finance", backgroundColor: .indigo, iconName: "chart.line.uptrend.xyaxis", description: "Live stock market updates", isNew: false),
        Widget(name: "Sleep Sounds", category: "Health", backgroundColor: .mint, iconName: "moon.zzz.fill", description: "Relaxing audio for better sleep", isNew: false),
        Widget(name: "Focus Mode", category: "Productivity", backgroundColor: .teal, iconName: "brain.head.profile", description: "Distraction-free work environment", isNew: true),
        Widget(name: "Pet Cam", category: "Smart Home", backgroundColor: .brown, iconName: "camera.fill", description: "Keep an eye on your pets", isNew: true),
        Widget(name: "Habit Tracker", category: "Lifestyle", backgroundColor: .red, iconName: "checkmark.circle.fill", description: "Track your daily habits", isNew: true),
        Widget(name: "Crypto Watch", category: "Finance", backgroundColor: .yellow, iconName: "bitcoinsign.circle.fill", description: "Monitor cryptocurrency prices", isNew: true),
        Widget(name: "World Clock", category: "Time", backgroundColor: .gray, iconName: "globe", description: "Multiple time zones at a glance", isNew: false),
        Widget(name: "Rain Radar", category: "Weather", backgroundColor: .cyan, iconName: "cloud.rain.fill", description: "Precipitation forecasting", isNew: false),
        Widget(name: "Heart Rate", category: "Health", backgroundColor: .red, iconName: "heart.fill", description: "Monitor your heart rate", isNew: false),
        Widget(name: "Smart Lights", category: "Smart Home", backgroundColor: .yellow, iconName: "lightbulb.fill", description: "Control your home lighting", isNew: false)
    ]
    
    init()
    {
        loadWidgetViews()
    }
    
    // MARK: - View Management
    func addView(_ view: WidgetView)
    {
        widgetViews.append(view)
        saveWidgetViews()
    }
    
    func deleteView(at index: Int)
    {
        guard index < widgetViews.count else { return }
        widgetViews.remove(at: index)
        saveWidgetViews()
    }
    
    func renameView(at index: Int, newName: String)
    {
        guard index < widgetViews.count else { return }
        widgetViews[index].name = newName
        saveWidgetViews()
    }
    
    func setWidget(_ widget: Widget?, at viewIndex: Int, isLeftSlot: Bool)
    {
        guard viewIndex < widgetViews.count else { return }
        
        if isLeftSlot
        {
            widgetViews[viewIndex].leftWidget = widget
        } else
        {
            widgetViews[viewIndex].rightWidget = widget
        }
        
        saveWidgetViews()
    }
    
    // MARK: - Persistence
    private func loadWidgetViews()
    {
        widgetViews = persistenceManager.loadWidgetViews()
    }
    
    private func saveWidgetViews()
    {
        persistenceManager.saveWidgetViews(widgetViews)
    }
    
    // MARK: - Utility Methods
    func getWidget(by id: UUID) -> Widget?
    {
        return availableWidgets.first { $0.id == id }
    }
    
    func getWidgetsByCategory(_ category: String) -> [Widget]
    {
        if category == "All"
        {
            return availableWidgets
        }
        return availableWidgets.filter { $0.category == category }
    }
}
