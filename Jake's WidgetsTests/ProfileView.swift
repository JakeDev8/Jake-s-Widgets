//
//  ProfileView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/22/25.
//

import SwiftUI

struct ProfileView: View
{
    @ObservedObject var viewManager: ViewManager
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var showingDeleteAlert = false
    
    private let persistenceManager = PersistenceManager.shared
    
    var body: some View
    {
        NavigationView
        {
            ScrollView(.vertical, showsIndicators: false)
            {
                VStack(spacing: 24)
                {
                    // Profile Header
                    VStack(spacing: 16)
                    {
                        // App Icon/Avatar
                        ZStack
                        {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 4)
                        {
                            Text("Jake's Widgets")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("StandBy Widget Creator")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats Section
                    VStack(spacing: 16)
                    {
                        Text("Your Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16)
                        {
                            StatCard(
                                title: "Views Created",
                                value: "\(viewManager.widgetViews.count)",
                                icon: "rectangle.stack.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Widgets Used",
                                value: "\(getTotalWidgetsUsed())",
                                icon: "apps.iphone",
                                color: .green
                            )
                        }
                        
                        HStack(spacing: 16)
                        {
                            StatCard(
                                title: "Favorite Category",
                                value: getMostUsedCategory(),
                                icon: "heart.fill",
                                color: .pink
                            )
                            
                            StatCard(
                                title: "Days Active",
                                value: "1", // Could be calculated from first launch
                                icon: "calendar.circle.fill",
                                color: .orange
                            )
                        }
                    }
                    
                    // Quick Actions
                    VStack(spacing: 16)
                    {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12)
                        {
                            ActionRow(
                                icon: "gear.circle.fill",
                                title: "Settings",
                                subtitle: "Customize app preferences",
                                color: .gray
                            ) {
                                showingSettings = true
                            }
                            
                            ActionRow(
                                icon: "info.circle.fill",
                                title: "About",
                                subtitle: "Learn more about the app",
                                color: .blue
                            ) {
                                showingAbout = true
                            }
                            
                            ActionRow(
                                icon: "envelope.circle.fill",
                                title: "Send Feedback",
                                subtitle: "Help improve the app",
                                color: .green
                            ) {
                                sendFeedback()
                            }
                            
                            ActionRow(
                                icon: "star.circle.fill",
                                title: "Rate App",
                                subtitle: "Share your experience",
                                color: .yellow
                            ) {
                                rateApp()
                            }
                        }
                    }
                    
                    // Danger Zone
                    VStack(spacing: 16)
                    {
                        Text("Data Management")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ActionRow(
                            icon: "trash.circle.fill",
                            title: "Clear All Data",
                            subtitle: "Delete all views and reset app",
                            color: .red
                        ) {
                            showingDeleteAlert = true
                        }
                    }
                    
                    // Version Info
                    VStack(spacing: 8)
                    {
                        Text("Jake's Widgets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0.0 (1)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Built with ❤️ for StandBy mode")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100) // Tab bar padding
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings)
        {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout)
        {
            AboutView()
        }
        .alert("Clear All Data", isPresented: $showingDeleteAlert)
        {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive)
            {
                clearAllData()
            }
        } message:
        {
            Text("This will permanently delete all your custom views and reset the app. This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    private func getTotalWidgetsUsed() -> Int
    {
        var count = 0
        for view in viewManager.widgetViews
        {
            if view.leftWidget != nil { count += 1 }
            if view.rightWidget != nil { count += 1 }
        }
        return count
    }
    
    private func getMostUsedCategory() -> String
    {
        var categoryCount: [String: Int] = [:]
        
        for view in viewManager.widgetViews
        {
            if let leftWidget = view.leftWidget
            {
                categoryCount[leftWidget.category, default: 0] += 1
            }
            if let rightWidget = view.rightWidget
            {
                categoryCount[rightWidget.category, default: 0] += 1
            }
        }
        
        return categoryCount.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    private func sendFeedback()
    {
        if let url = URL(string: "mailto:feedback@jakeswidgets.com?subject=Jake's%20Widgets%20Feedback")
        {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp()
    {
        // In a real app, this would open the App Store review page
        if let url = URL(string: "https://apps.apple.com/app/your-app-id")
        {
            UIApplication.shared.open(url)
        }
    }
    
    private func clearAllData()
    {
        viewManager.widgetViews.removeAll()
        persistenceManager.clearAllData()
    }
}

struct StatCard: View
{
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: 4)
            {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ActionRow: View
{
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View
    {
        Button(action: action)
        {
            HStack(spacing: 16)
            {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2)
                {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SettingsView: View
{
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var hapticFeedback = true
    @State private var autoSave = true
    
    var body: some View
    {
        NavigationView
        {
            List
            {
                Section("Preferences")
                {
                    HStack
                    {
                        Image(systemName: "bell.circle.fill")
                            .foregroundColor(.blue)
                        
                        Toggle("Notifications", isOn: $notificationsEnabled)
                    }
                    
                    HStack
                    {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.orange)
                        
                        Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    }
                    
                    HStack
                    {
                        Image(systemName: "square.and.arrow.down.fill")
                            .foregroundColor(.green)
                        
                        Toggle("Auto Save", isOn: $autoSave)
                    }
                }
                
                Section("Support")
                {
                    Link(destination: URL(string: "https://jakeswidgets.com/privacy")!)
                    {
                        HStack
                        {
                            Image(systemName: "hand.raised.circle.fill")
                                .foregroundColor(.purple)
                            Text("Privacy Policy")
                        }
                    }
                    
                    Link(destination: URL(string: "https://jakeswidgets.com/terms")!)
                    {
                        HStack
                        {
                            Image(systemName: "doc.text.circle.fill")
                                .foregroundColor(.blue)
                            Text("Terms of Service")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Done")
                    {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AboutView: View
{
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        NavigationView
        {
            ScrollView
            {
                VStack(spacing: 24)
                {
                    // App Icon
                    ZStack
                    {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 8)
                    {
                        Text("Jake's Widgets")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16)
                    {
                        Text("About")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Jake's Widgets is designed to enhance your iPhone's StandBy mode experience. Create custom widget layouts, preview them in real-time, and enjoy a more personalized bedside display.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12)
                    {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8)
                        {
                            AboutFeatureRow(icon: "iphone.landscape", text: "StandBy Mode Optimization")
                            AboutFeatureRow(icon: "eye.fill", text: "Real-time Preview")
                            AboutFeatureRow(icon: "rectangle.stack.fill", text: "Custom Widget Layouts")
                            AboutFeatureRow(icon: "paintbrush.fill", text: "Personalization Options")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Text("Built with ❤️ by Jake Huebner")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Done")
                    {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AboutFeatureRow: View
{
    let icon: String
    let text: String
    
    var body: some View
    {
        HStack(spacing: 12)
        {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}
