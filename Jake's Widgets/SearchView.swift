//
//  SearchView.swift
//  Jake's Widgets
//
//  UPDATED to use EnhancedWidget instead of Widget
//

import SwiftUI

struct SearchView: View
{
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showStandByOnly = false
    @State private var showNewOnly = false
    @State private var showPopularOnly = false
    
    let categories = ["All", "Time", "Weather", "Calendar", "Photos", "Fitness", "Lifestyle", "Finance", "Productivity", "Health", "Smart Home"]
    
    // UPDATED: Expanded widget library for search - using EnhancedWidget instead of Widget
    let allWidgets = [
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
        EnhancedWidget(name: "Smart Lights", category: "Smart Home", backgroundColor: .yellow, iconName: "lightbulb.fill", description: "Control your home lighting", isNew: false)
    ]
    
    var filteredWidgets: [EnhancedWidget] // CHANGED: Widget -> EnhancedWidget
    {
        var widgets = allWidgets
        
        // Filter by search text
        if !searchText.isEmpty
        {
            widgets = widgets.filter { widget in
                widget.name.localizedCaseInsensitiveContains(searchText) ||
                widget.description.localizedCaseInsensitiveContains(searchText) ||
                widget.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "All"
        {
            widgets = widgets.filter { $0.category == selectedCategory }
        }
        
        // Filter by new
        if showNewOnly
        {
            widgets = widgets.filter { $0.isNew }
        }
        
        // Mock filtering for StandBy and Popular
        // In a real app, these would be actual properties
        
        return widgets
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 0)
            {
                // Search Header
                VStack(spacing: 16)
                {
                    // Search Bar
                    HStack
                    {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search widgets...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty
                        {
                            Button(action: { searchText = "" })
                            {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Category Chips
                    ScrollView(.horizontal, showsIndicators: false)
                    {
                        HStack(spacing: 12)
                        {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Filter Toggles
                    HStack(spacing: 16)
                    {
                        FilterToggle(title: "StandBy", isOn: $showStandByOnly)
                        FilterToggle(title: "New", isOn: $showNewOnly)
                        FilterToggle(title: "Popular", isOn: $showPopularOnly)
                        
                        Spacer()
                        
                        Text("\(filteredWidgets.count) widgets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Results Grid
                ScrollView
                {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16)
                    {
                        ForEach(filteredWidgets) { widget in
                            NavigationLink(destination: EnhancedWidgetDetailView(widget: widget)) // CHANGED: WidgetDetailView -> EnhancedWidgetDetailView
                            {
                                SearchWidgetCard(widget: widget)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Universal rotation instruction
                    HStack(spacing: 8)
                    {
                        Image(systemName: "rotate.right")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text("Rotate for fullscreen preview")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100) // Tab bar padding
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CategoryChip: View
{
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View
    {
        Button(action: onTap)
        {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
}

struct FilterToggle: View
{
    let title: String
    @Binding var isOn: Bool
    
    var body: some View
    {
        Button(action: { isOn.toggle() })
        {
            HStack(spacing: 6)
            {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isOn ? .blue : .secondary)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isOn ? .blue : .secondary)
            }
        }
    }
}

struct SearchWidgetCard: View
{
    let widget: EnhancedWidget // CHANGED: Widget -> EnhancedWidget
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            // Widget Preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.themedBackgroundColor.gradient) // CHANGED: backgroundColor.color -> themedBackgroundColor
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
                        
                        if widget.isPremium // NEW: Show premium badge
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
