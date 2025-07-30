//
//  PersistenceManager.swift
//  Jake's Widgets
//
//  UPDATED to use EnhancedWidget instead of Widget
//

import Foundation
import SwiftUI

// MARK: - Persistence Manager
class PersistenceManager: ObservableObject
{
    static let shared = PersistenceManager()
    
    private let userDefaults = UserDefaults.standard
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: - File URLs
    private var widgetViewsURL: URL
    {
        documentsDirectory.appendingPathComponent("widgetViews.json")
    }
    
    // MARK: - UserDefaults Keys
    private enum Keys
    {
        static let isDarkMode = "isDarkMode"
        static let distanceScale = "distanceScale"
        static let currentViewIndex = "currentViewIndex"
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let favoriteWidgets = "favoriteWidgets"
        static let recentlyUsedWidgets = "recentlyUsedWidgets"
    }
    
    private init() {}
    
    // MARK: - Widget Views Persistence
    func saveWidgetViews(_ views: [WidgetView])
    {
        do
        {
            let data = try JSONEncoder().encode(views)
            try data.write(to: widgetViewsURL)
            print("✅ Widget views saved successfully")
        } catch
        {
            print("❌ Failed to save widget views: \(error)")
        }
    }
    
    func loadWidgetViews() -> [WidgetView]
    {
        do
        {
            let data = try Data(contentsOf: widgetViewsURL)
            let views = try JSONDecoder().decode([WidgetView].self, from: data)
            print("✅ Widget views loaded successfully")
            return views
        } catch
        {
            print("ℹ️ No saved widget views found, using defaults")
            return []
        }
    }
    
    // MARK: - App Settings Persistence
    func saveDarkMode(_ isDarkMode: Bool)
    {
        userDefaults.set(isDarkMode, forKey: Keys.isDarkMode)
    }
    
    func loadDarkMode() -> Bool
    {
        return userDefaults.bool(forKey: Keys.isDarkMode)
    }
    
    func saveDistanceScale(_ scale: Double)
    {
        userDefaults.set(scale, forKey: Keys.distanceScale)
    }
    
    func loadDistanceScale() -> Double
    {
        let saved = userDefaults.double(forKey: Keys.distanceScale)
        return saved == 0 ? 1.0 : saved // Default to 1.0 if not set
    }
    
    func saveCurrentViewIndex(_ index: Int)
    {
        userDefaults.set(index, forKey: Keys.currentViewIndex)
    }
    
    func loadCurrentViewIndex() -> Int
    {
        return userDefaults.integer(forKey: Keys.currentViewIndex)
    }
    
    // MARK: - First Launch Detection
    func isFirstLaunch() -> Bool
    {
        let hasLaunched = userDefaults.bool(forKey: Keys.hasLaunchedBefore)
        if !hasLaunched
        {
            userDefaults.set(true, forKey: Keys.hasLaunchedBefore)
            return true
        }
        return false
    }
    
    // MARK: - Widget Usage Tracking (UPDATED for EnhancedWidget)
    func addToRecentlyUsed(_ widget: EnhancedWidget) // CHANGED: Widget -> EnhancedWidget
    {
        var recent = loadRecentlyUsedWidgets()
        
        // Remove if already exists to avoid duplicates
        recent.removeAll { $0.id == widget.id }
        
        // Add to beginning
        recent.insert(widget, at: 0)
        
        // Keep only last 10
        if recent.count > 10
        {
            recent = Array(recent.prefix(10))
        }
        
        saveRecentlyUsedWidgets(recent)
    }
    
    private func saveRecentlyUsedWidgets(_ widgets: [EnhancedWidget]) // CHANGED: Widget -> EnhancedWidget
    {
        do
        {
            let data = try JSONEncoder().encode(widgets)
            userDefaults.set(data, forKey: Keys.recentlyUsedWidgets)
        } catch
        {
            print("❌ Failed to save recently used widgets: \(error)")
        }
    }
    
    func loadRecentlyUsedWidgets() -> [EnhancedWidget] // CHANGED: Widget -> EnhancedWidget
    {
        guard let data = userDefaults.data(forKey: Keys.recentlyUsedWidgets) else { return [] }
        
        do
        {
            return try JSONDecoder().decode([EnhancedWidget].self, from: data) // CHANGED: Widget -> EnhancedWidget
        } catch
        {
            print("❌ Failed to load recently used widgets: \(error)")
            return []
        }
    }
    
    // MARK: - Favorites (UPDATED for EnhancedWidget)
    func toggleFavorite(_ widget: EnhancedWidget) // CHANGED: Widget -> EnhancedWidget
    {
        var favorites = loadFavoriteWidgets()
        
        if favorites.contains(where: { $0.id == widget.id })
        {
            favorites.removeAll { $0.id == widget.id }
        } else
        {
            favorites.append(widget)
        }
        
        saveFavoriteWidgets(favorites)
    }
    
    func isFavorite(_ widget: EnhancedWidget) -> Bool // CHANGED: Widget -> EnhancedWidget
    {
        return loadFavoriteWidgets().contains { $0.id == widget.id }
    }
    
    private func saveFavoriteWidgets(_ widgets: [EnhancedWidget]) // CHANGED: Widget -> EnhancedWidget
    {
        do
        {
            let data = try JSONEncoder().encode(widgets)
            userDefaults.set(data, forKey: Keys.favoriteWidgets)
        } catch
        {
            print("❌ Failed to save favorite widgets: \(error)")
        }
    }
    
    func loadFavoriteWidgets() -> [EnhancedWidget] // CHANGED: Widget -> EnhancedWidget
    {
        guard let data = userDefaults.data(forKey: Keys.favoriteWidgets) else { return [] }
        
        do
        {
            return try JSONDecoder().decode([EnhancedWidget].self, from: data) // CHANGED: Widget -> EnhancedWidget
        } catch
        {
            print("❌ Failed to load favorite widgets: \(error)")
            return []
        }
    }
    
    // MARK: - Debug Helpers
    func clearAllData()
    {
        // Remove saved files
        try? FileManager.default.removeItem(at: widgetViewsURL)
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: Keys.isDarkMode)
        userDefaults.removeObject(forKey: Keys.distanceScale)
        userDefaults.removeObject(forKey: Keys.currentViewIndex)
        userDefaults.removeObject(forKey: Keys.hasLaunchedBefore)
        userDefaults.removeObject(forKey: Keys.favoriteWidgets)
        userDefaults.removeObject(forKey: Keys.recentlyUsedWidgets)
        
        print("🗑️ All persistent data cleared")
    }
}
