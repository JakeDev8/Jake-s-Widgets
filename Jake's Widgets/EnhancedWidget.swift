//
//  EnhancedWidget.swift
//  Jake's Widgets
//
//  Enhanced widget system with premium features
//

import SwiftUI
import Foundation

// MARK: - Widget Themes (NEW)
enum WidgetTheme: String, CaseIterable, Codable
{
    case automatic, light, dark, colorful, minimal
    
    var displayName: String
    {
        switch self
        {
        case .automatic: return "Automatic"
        case .light: return "Light"
        case .dark: return "Dark"
        case .colorful: return "Colorful"
        case .minimal: return "Minimal"
        }
    }
    
    func backgroundColor(for baseColor: WidgetColor) -> Color
    {
        switch self
        {
        case .automatic, .colorful:
            return baseColor.color
        case .light:
            return baseColor.color.opacity(0.8)
        case .dark:
            return baseColor.color.opacity(0.9)
        case .minimal:
            return Color(.systemGray5)
        }
    }
}

// MARK: - Enhanced Widget (REPLACES your current Widget struct)
struct EnhancedWidget: Identifiable, Codable
{
    let id: UUID
    let name: String
    let category: String
    let backgroundColor: WidgetColor  // Using your existing WidgetColor enum
    let iconName: String
    let description: String
    let isNew: Bool
    
    // NEW: Premium features
    let isPremium: Bool
    let supportsDynamicContent: Bool
    var theme: WidgetTheme
    var refreshInterval: TimeInterval
    
    // COMPATIBILITY: Keep your existing Widget initializer working
    init(name: String, category: String, backgroundColor: WidgetColor, iconName: String, description: String, isNew: Bool = false)
    {
        self.id = UUID()
        self.name = name
        self.category = category
        self.backgroundColor = backgroundColor
        self.iconName = iconName
        self.description = description
        self.isNew = isNew
        
        // Default values for new properties
        self.isPremium = false
        self.supportsDynamicContent = false
        self.theme = .automatic
        self.refreshInterval = 300 // 5 minutes for free widgets
    }
    
    // NEW: Premium widget initializer
    init(name: String, category: String, backgroundColor: WidgetColor, iconName: String, description: String, isNew: Bool = false, isPremium: Bool, dynamicContent: Bool = false)
    {
        self.id = UUID()
        self.name = name
        self.category = category
        self.backgroundColor = backgroundColor
        self.iconName = iconName
        self.description = description
        self.isNew = isNew
        self.isPremium = isPremium
        self.supportsDynamicContent = dynamicContent
        self.theme = .automatic
        self.refreshInterval = isPremium ? 30 : 300 // Premium widgets update every 30 seconds
    }
    
    // COMPUTED: Get themed background color
    var themedBackgroundColor: Color
    {
        return theme.backgroundColor(for: backgroundColor)
    }
}

// MARK: - Enhanced Widget View (NEW)
struct EnhancedWidgetCard: View
{
    let widget: EnhancedWidget
    let showPremiumBadge: Bool
    
    init(widget: EnhancedWidget, showPremiumBadge: Bool = true)
    {
        self.widget = widget
        self.showPremiumBadge = showPremiumBadge
    }
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            // Widget Preview with theme support
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.themedBackgroundColor.gradient)
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4)
                    {
                        if widget.isNew
                        {
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.3))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        if widget.isPremium && showPremiumBadge
                        {
                            Text("PRO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.8))
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Widget Name
            Text(widget.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}

// MARK: - Basic Subscription Manager (SIMPLE VERSION)
class BasicSubscriptionManager: ObservableObject
{
    @Published var isPremiumUser: Bool = false
    
    init()
    {
        // For now, just load from UserDefaults
        self.isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
    }
    
    func canAccessWidget(_ widget: EnhancedWidget) -> Bool
    {
        // Free users can access non-premium widgets
        if !widget.isPremium { return true }
        
        // Premium users can access everything
        return isPremiumUser
    }
    
    func setPremiumStatus(_ isPremium: Bool)
    {
        isPremiumUser = isPremium
        UserDefaults.standard.set(isPremium, forKey: "isPremiumUser")
    }
    
    // For testing - you can remove this later
    func togglePremiumForTesting()
    {
        setPremiumStatus(!isPremiumUser)
    }
}
