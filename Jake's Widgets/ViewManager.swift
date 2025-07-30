//
//  ViewManager.swift
//  Jake's Widgets
//
//  Updated to use shared configuration and EnhancedWidget
//

import SwiftUI
import Foundation

// MARK: - WidgetView Model (UPDATED to use EnhancedWidget)
struct WidgetView: Identifiable
{
    let id: UUID
    var name: String
    var leftWidget: EnhancedWidget?  // CHANGED: Widget -> EnhancedWidget
    var rightWidget: EnhancedWidget? // CHANGED: Widget -> EnhancedWidget
    
    init(name: String, leftWidget: EnhancedWidget? = nil, rightWidget: EnhancedWidget? = nil)
    {
        self.id = UUID()
        self.name = name
        self.leftWidget = leftWidget
        self.rightWidget = rightWidget
    }
}

// MARK: - Manual Codable for WidgetView (UPDATED for EnhancedWidget)
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
        leftWidget = try container.decodeIfPresent(EnhancedWidget.self, forKey: .leftWidget)  // CHANGED
        rightWidget = try container.decodeIfPresent(EnhancedWidget.self, forKey: .rightWidget) // CHANGED
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

// MARK: - ViewManager Class (ENHANCED)
class ViewManager: ObservableObject
{
    @Published var widgetViews: [WidgetView] = []
    @Published var subscriptionManager = BasicSubscriptionManager() // NEW
    
    private let persistenceManager = PersistenceManager.shared
    
    // ENHANCED: Available widgets with premium options
    let availableWidgets: [EnhancedWidget] = [
        // FREE WIDGETS (converted from your existing ones)
        EnhancedWidget(name: "Minimal Clock", category: "Time", backgroundColor: .black, iconName: "clock.fill", description: "Clean time display perfect for StandBy mode", isNew: false),
        EnhancedWidget(name: "Weather Now", category: "Weather", backgroundColor: .blue, iconName: "cloud.sun.fill", description: "Current weather conditions and temperature", isNew: false),
        EnhancedWidget(name: "Next Event", category: "Calendar", backgroundColor: .purple, iconName: "calendar", description: "Shows your upcoming calendar events", isNew: true),
        EnhancedWidget(name: "Photo Frame", category: "Photos", backgroundColor: .orange, iconName: "photo.fill", description: "Rotating photos from your library", isNew: false),
        EnhancedWidget(name: "Workout Timer", category: "Fitness", backgroundColor: .green, iconName: "figure.run", description: "Track your exercise sessions", isNew: false),
        EnhancedWidget(name: "Daily Quote", category: "Lifestyle", backgroundColor: .pink, iconName: "quote.bubble.fill", description: "Inspirational quotes to start your day", isNew: true),
        EnhancedWidget(name: "Stock Ticker", category: "Finance", backgroundColor: .indigo, iconName: "chart.line.uptrend.xyaxis", description: "Live stock market updates", isNew: false),
        EnhancedWidget(name: "Sleep Sounds", category: "Health", backgroundColor: .mint, iconName: "moon.zzz.fill", description: "Relaxing audio for better sleep", isNew: false),
        EnhancedWidget(name: "Focus Mode", category: "Productivity", backgroundColor: .teal, iconName: "brain.head.profile", description: "Distraction-free work environment", isNew: true),
        EnhancedWidget(name: "Pet Cam", category: "Smart Home", backgroundColor: .brown, iconName: "camera.fill", description: "Keep an eye on your pets", isNew: true),
        EnhancedWidget(name: "Habit Tracker", category: "Lifestyle", backgroundColor: .red, iconName: "checkmark.circle.fill", description: "Track your daily habits", isNew: true),
        EnhancedWidget(name: "Crypto Watch", category: "Finance", backgroundColor: .yellow, iconName: "bitcoinsign.circle.fill", description: "Monitor cryptocurrency prices", isNew: true),
        EnhancedWidget(name: "World Clock", category: "Time", backgroundColor: .gray, iconName: "globe", description: "Multiple time zones at a glance", isNew: false),
        EnhancedWidget(name: "Rain Radar", category: "Weather", backgroundColor: .cyan, iconName: "cloud.rain.fill", description: "Precipitation forecasting", isNew: false),
        EnhancedWidget(name: "Heart Rate", category: "Health", backgroundColor: .red, iconName: "heart.fill", description: "Monitor your heart rate", isNew: false),
        EnhancedWidget(name: "Smart Lights", category: "Smart Home", backgroundColor: .yellow, iconName: "lightbulb.fill", description: "Control your home lighting", isNew: false),
        
        // NEW: PREMIUM WIDGETS
        EnhancedWidget(name: "Live Weather Radar", category: "Weather", backgroundColor: .cyan, iconName: "cloud.rain.fill", description: "Real-time animated weather radar", isNew: true, isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Dynamic Crypto Ticker", category: "Finance", backgroundColor: .orange, iconName: "bitcoinsign.circle.fill", description: "Live crypto prices with trend indicators", isNew: true, isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Smart Calendar Pro", category: "Calendar", backgroundColor: .purple, iconName: "calendar.badge.clock", description: "Next 3 events with travel time", isNew: true, isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Animated Photo Slideshow", category: "Photos", backgroundColor: .pink, iconName: "photo.stack.fill", description: "Auto-changing photos from your albums", isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Smart Home Dashboard", category: "Smart Home", backgroundColor: .teal, iconName: "house.fill", description: "Control lights, temperature, and more", isPremium: true, dynamicContent: true)
    ]
    
    // NEW: Filtered widget lists
    var freeWidgets: [EnhancedWidget]
    {
        return availableWidgets.filter { !$0.isPremium }
    }
    
    var premiumWidgets: [EnhancedWidget]
    {
        return availableWidgets.filter { $0.isPremium }
    }
    
    var accessibleWidgets: [EnhancedWidget]
    {
        return availableWidgets.filter { subscriptionManager.canAccessWidget($0) }
    }
    
    init()
    {
        loadWidgetViews()
    }
    
    // MARK: - View Management (UNCHANGED)
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
    
    func setWidget(_ widget: EnhancedWidget?, at viewIndex: Int, isLeftSlot: Bool) // CHANGED: Widget -> EnhancedWidget
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
    
    // NEW: Premium access checking
    func canUserAccessWidget(_ widget: EnhancedWidget) -> Bool
    {
        return subscriptionManager.canAccessWidget(widget)
    }
    
    // MARK: - Persistence (UNCHANGED)
    private func loadWidgetViews()
    {
        widgetViews = persistenceManager.loadWidgetViews()
    }
    
    private func saveWidgetViews()
    {
        persistenceManager.saveWidgetViews(widgetViews)
    }
    
    // MARK: - Utility Methods (UPDATED)
    func getWidget(by id: UUID) -> EnhancedWidget? // CHANGED: Widget -> EnhancedWidget
    {
        return availableWidgets.first { $0.id == id }
    }
    
    func getWidgetsByCategory(_ category: String) -> [EnhancedWidget] // CHANGED: Widget -> EnhancedWidget
    {
        if category == "All"
        {
            return accessibleWidgets // NEW: Only show accessible widgets
        }
        return accessibleWidgets.filter { $0.category == category }
    }
}
