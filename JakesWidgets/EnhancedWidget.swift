//
//  EnhancedWidget.swift
//  Jake's Widgets
//
//  Enhanced widget model with premium features and subscription management
//

import SwiftUI
import Foundation

// MARK: - Enhanced Widget Model
struct EnhancedWidget: Identifiable, Codable
{
    let id: UUID
    let name: String
    let category: String
    let backgroundColor: WidgetColor
    let iconName: String
    let description: String
    let isNew: Bool
    let isPremium: Bool
    let dynamicContent: Bool
    
    init(name: String, category: String, backgroundColor: WidgetColor, iconName: String, description: String, isNew: Bool = false, isPremium: Bool = false, dynamicContent: Bool = false)
    {
        self.id = UUID()
        self.name = name
        self.category = category
        self.backgroundColor = backgroundColor
        self.iconName = iconName
        self.description = description
        self.isNew = isNew
        self.isPremium = isPremium
        self.dynamicContent = dynamicContent
    }
    
    // Computed property for themed background color
    var themedBackgroundColor: Color
    {
        return backgroundColor.color
    }
}

// MARK: - Manual Codable Implementation for EnhancedWidget
extension EnhancedWidget
{
    enum CodingKeys: String, CodingKey
    {
        case id, name, category, backgroundColor, iconName, description, isNew, isPremium, dynamicContent
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
        isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        dynamicContent = try container.decodeIfPresent(Bool.self, forKey: .dynamicContent) ?? false
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
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(dynamicContent, forKey: .dynamicContent)
    }
}

// MARK: - Basic Subscription Manager
class BasicSubscriptionManager: ObservableObject
{
    @Published var isPremiumUser: Bool = false
    @Published var hasFreeTrial: Bool = true
    @Published var freeTrialDaysRemaining: Int = 7
    
    private let userDefaults = UserDefaults.standard
    private let premiumStatusKey = "isPremiumUser"
    private let freeTrialKey = "hasUsedFreeTrial"
    
    init()
    {
        loadSubscriptionStatus()
    }
    
    // MARK: - Subscription Status Methods
    func canAccessWidget(_ widget: EnhancedWidget) -> Bool
    {
        // Free widgets are always accessible
        if !widget.isPremium
        {
            return true
        }
        
        // Premium widgets require subscription or free trial
        return isPremiumUser || hasFreeTrial
    }
    
    func canAccessPremiumFeatures() -> Bool
    {
        return isPremiumUser || hasFreeTrial
    }
    
    // MARK: - Subscription Actions
    func startFreeTrial()
    {
        hasFreeTrial = true
        freeTrialDaysRemaining = 7
        saveSubscriptionStatus()
        objectWillChange.send()
    }
    
    func purchasePremium()
    {
        isPremiumUser = true
        hasFreeTrial = false
        saveSubscriptionStatus()
        objectWillChange.send()
        
        // Here you would integrate with StoreKit for actual purchases
        print("🟢 Premium subscription activated!")
    }
    
    func restorePurchases()
    {
        // Here you would integrate with StoreKit to restore purchases
        print("🔄 Restoring purchases...")
        
        // Mock restoration for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            self.isPremiumUser = true
            self.saveSubscriptionStatus()
            self.objectWillChange.send()
            print("✅ Purchases restored!")
        }
    }
    
    func cancelSubscription()
    {
        isPremiumUser = false
        hasFreeTrial = false
        saveSubscriptionStatus()
        objectWillChange.send()
        print("❌ Subscription cancelled")
    }
    
    // MARK: - Debug/Testing Methods
    func togglePremiumForTesting()
    {
        isPremiumUser.toggle()
        saveSubscriptionStatus()
        objectWillChange.send()
        print("🧪 Debug: Premium status toggled to \(isPremiumUser)")
    }
    
    func resetFreeTrial()
    {
        hasFreeTrial = true
        freeTrialDaysRemaining = 7
        userDefaults.removeObject(forKey: freeTrialKey)
        saveSubscriptionStatus()
        objectWillChange.send()
        print("🧪 Debug: Free trial reset")
    }
    
    // MARK: - Persistence
    private func loadSubscriptionStatus()
    {
        isPremiumUser = userDefaults.bool(forKey: premiumStatusKey)
        hasFreeTrial = !userDefaults.bool(forKey: freeTrialKey)
        
        print("📱 Loaded subscription status: Premium=\(isPremiumUser), FreeTrial=\(hasFreeTrial)")
    }
    
    private func saveSubscriptionStatus()
    {
        userDefaults.set(isPremiumUser, forKey: premiumStatusKey)
        userDefaults.set(!hasFreeTrial, forKey: freeTrialKey)
        
        print("💾 Saved subscription status: Premium=\(isPremiumUser), FreeTrial=\(hasFreeTrial)")
    }
    
    // MARK: - Premium Widget Features
    func getPremiumWidgetCount() -> Int
    {
        // This would normally be fetched from your backend or calculated
        return isPremiumUser ? 50 : (hasFreeTrial ? 50 : 0)
    }
    
    func getRemainingFreeWidgets() -> Int
    {
        return hasFreeTrial ? 10 : 0
    }
    
    // MARK: - Subscription Info
    var subscriptionStatusText: String
    {
        if isPremiumUser
        {
            return "Premium Active"
        } else if hasFreeTrial
        {
            return "Free Trial (\(freeTrialDaysRemaining) days)"
        } else
        {
            return "Free Version"
        }
    }
    
    var premiumBenefits: [String]
    {
        return [
            "50+ Premium Widgets",
            "Live Dynamic Content",
            "Custom Animations",
            "Advanced Themes",
            "Priority Support",
            "No Ads"
        ]
    }
}

// MARK: - Enhanced Widget Card View
struct EnhancedWidgetCard: View
{
    let widget: EnhancedWidget
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            // Widget Preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.themedBackgroundColor.gradient)
                    .frame(height: 120)
                
                VStack(spacing: 6)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4)
                    {
                        if widget.isNew
                        {
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.3))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        if widget.isPremium
                        {
                            Text("PRO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.8))
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                        
                        if widget.dynamicContent
                        {
                            Image(systemName: "waveform")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Widget Info
            VStack(spacing: 4)
            {
                Text(widget.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(widget.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(widget.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
