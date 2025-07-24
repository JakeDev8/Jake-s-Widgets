//
//  SearchView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/23/25.
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
    
    // Expanded widget library for search
    let allWidgets = [
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
    
    var filteredWidgets: [Widget]
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
                            NavigationLink(destination: WidgetDetailView(widget: widget))
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
    let widget: Widget
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            // Widget Preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.backgroundColor.gradient)
                    .frame(height: 120)
                
                VStack(spacing: 6)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
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

struct WidgetDetailView: View
{
    let widget: Widget
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading, spacing: 24)
            {
                // Hero Section
                VStack(spacing: 16)
                {
                    // Large widget preview
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(widget.backgroundColor.gradient)
                            .frame(width: 200, height: 200)
                        
                        VStack(spacing: 12)
                        {
                            Image(systemName: widget.iconName)
                                .font(.system(size: 64, weight: .medium))
                                .foregroundColor(.white)
                            
                            if widget.isNew
                            {
                                Text("NEW")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.3))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 8)
                    {
                        Text(widget.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(widget.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                // Description Section
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("About")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(widget.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                
                // Features Section
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8)
                    {
                        FeatureRow(icon: "iphone.landscape", title: "StandBy Compatible", description: "Optimized for iPhone StandBy mode")
                        FeatureRow(icon: "house.fill", title: "Home Screen", description: "Works beautifully on your home screen")
                        FeatureRow(icon: "lock.fill", title: "Lock Screen", description: "Perfect for lock screen widgets")
                        FeatureRow(icon: "paintbrush.fill", title: "Customizable", description: "Multiple themes and options")
                    }
                }
                
                // Mock Ratings Section
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("Ratings & Reviews")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12)
                    {
                        HStack
                        {
                            HStack(spacing: 4)
                            {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < 4 ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                }
                            }
                            
                            Text("4.8")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("(2,847 reviews)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Mock review
                        VStack(alignment: .leading, spacing: 8)
                        {
                            HStack
                            {
                                Text("Sarah M.")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                HStack(spacing: 2)
                                {
                                    ForEach(0..<5) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                            }
                            
                            Text("Perfect for my bedside table! The \(widget.name.lowercased()) is exactly what I needed for StandBy mode.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 120) // Extra space for floating button
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .overlay(alignment: .bottom)
        {
            // Floating Add Button
            AddToViewButton(widget: widget)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
}

struct FeatureRow: View
{
    let icon: String
    let title: String
    let description: String
    
    var body: some View
    {
        HStack(spacing: 16)
        {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2)
            {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct AddToViewButton: View
{
    let widget: Widget
    @State private var showingViewSelector = false
    
    var body: some View
    {
        Button(action: {
            showingViewSelector = true
        })
        {
            HStack
            {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Add to View")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .sheet(isPresented: $showingViewSelector)
        {
            ViewSelectorSheet(widget: widget)
        }
    }
}

struct ViewSelectorSheet: View
{
    let widget: Widget
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewManager: ViewManager
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    @State private var showingReplaceAlert = false
    @State private var replaceAlertConfig: ReplaceAlertConfig?
    @State private var showingCreateView = false
    @State private var newViewName = ""
    
    struct ReplaceAlertConfig
    {
        let viewIndex: Int
        let isLeftSlot: Bool
        let existingWidget: Widget
    }
    
    var body: some View
    {
        NavigationView
        {
            ScrollView
            {
                VStack(spacing: 24)
                {
                    // Header Section
                    VStack(spacing: 16)
                    {
                        ZStack
                        {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(widget.backgroundColor)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: widget.iconName)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4)
                        {
                            Text("Add \(widget.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Choose a view and slot to add this widget")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Add New View Button
                    Button(action: {
                        showingCreateView = true
                    })
                    {
                        HStack(spacing: 12)
                        {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2)
                            {
                                Text("Create New View")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Make a custom layout for this widget")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    
                    // Views List
                    if viewManager.widgetViews.isEmpty
                    {
                        // Empty state
                        VStack(spacing: 16)
                        {
                            Image(systemName: "rectangle.stack.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No Views Created")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("Create your first custom view using the button above")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 40)
                    } else
                    {
                        VStack(spacing: 16)
                        {
                            ForEach(Array(viewManager.widgetViews.enumerated()), id: \.element.id) { index, view in
                                ViewSlotSelector(
                                    view: view,
                                    widget: widget,
                                    onSelectSlot: { isLeftSlot in
                                        addWidgetToView(viewIndex: index, isLeftSlot: isLeftSlot)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Add Widget")
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
        .sheet(isPresented: $showingCreateView)
        {
            CreateViewSheet(
                widget: widget,
                newViewName: $newViewName,
                onCreateAndAdd: { viewName, isLeftSlot in
                    createViewAndAddWidget(viewName: viewName, isLeftSlot: isLeftSlot)
                }
            )
        }
        .alert("Widget Added!", isPresented: $showingSuccessAlert)
        {
            Button("OK") { dismiss() }
        } message:
        {
            Text(successMessage)
        }
        .alert("Replace Widget?", isPresented: $showingReplaceAlert)
        {
            Button("Cancel", role: .cancel) { }
            Button("Replace", role: .destructive)
            {
                if let config = replaceAlertConfig
                {
                    performWidgetReplacement(config: config)
                }
            }
        } message:
        {
            if let config = replaceAlertConfig
            {
                Text("This will replace \(config.existingWidget.name) with \(widget.name) in the \(config.isLeftSlot ? "left" : "right") slot.")
            }
        }
    }
    
    private func addWidgetToView(viewIndex: Int, isLeftSlot: Bool)
    {
        let existingWidget = isLeftSlot ? viewManager.widgetViews[viewIndex].leftWidget : viewManager.widgetViews[viewIndex].rightWidget
        
        if let existing = existingWidget
        {
            // Slot is occupied, ask user if they want to replace
            replaceAlertConfig = ReplaceAlertConfig(
                viewIndex: viewIndex,
                isLeftSlot: isLeftSlot,
                existingWidget: existing
            )
            showingReplaceAlert = true
        } else
        {
            // Slot is empty, add directly
            if isLeftSlot
            {
                viewManager.widgetViews[viewIndex].leftWidget = widget
            } else
            {
                viewManager.widgetViews[viewIndex].rightWidget = widget
            }
            
            let viewName = viewManager.widgetViews[viewIndex].name
            let slotName = isLeftSlot ? "left" : "right"
            successMessage = "\(widget.name) added to \(viewName) (\(slotName) slot)"
            showingSuccessAlert = true
        }
    }
    
    private func performWidgetReplacement(config: ReplaceAlertConfig)
    {
        if config.isLeftSlot
        {
            viewManager.widgetViews[config.viewIndex].leftWidget = widget
        } else
        {
            viewManager.widgetViews[config.viewIndex].rightWidget = widget
        }
        
        let viewName = viewManager.widgetViews[config.viewIndex].name
        let slotName = config.isLeftSlot ? "left" : "right"
        successMessage = "\(widget.name) replaced \(config.existingWidget.name) in \(viewName) (\(slotName) slot)"
        showingSuccessAlert = true
    }
    
    private func createViewAndAddWidget(viewName: String, isLeftSlot: Bool)
    {
        // Create new view
        let newView = WidgetView(name: viewName.isEmpty ? "New View" : viewName)
        viewManager.addView(newView)
        
        // Add widget to the specified slot
        let newIndex = viewManager.widgetViews.count - 1
        if isLeftSlot
        {
            viewManager.widgetViews[newIndex].leftWidget = widget
        } else
        {
            viewManager.widgetViews[newIndex].rightWidget = widget
        }
        
        let slotName = isLeftSlot ? "left" : "right"
        successMessage = "Created \"\(viewName)\" and added \(widget.name) to \(slotName) slot"
        showingSuccessAlert = true
    }
}

struct ViewSlotSelector: View
{
    let view: WidgetView
    let widget: Widget
    let onSelectSlot: (Bool) -> Void
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            // View Header
            HStack
            {
                Text(view.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(getWidgetCount()) / 2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            
            // Slot Selection
            HStack(spacing: 16)
            {
                // Left Slot
                SlotButton(
                    title: "Left",
                    widget: view.leftWidget,
                    isOccupied: view.leftWidget != nil
                ) {
                    onSelectSlot(true)
                }
                
                // Right Slot
                SlotButton(
                    title: "Right",
                    widget: view.rightWidget,
                    isOccupied: view.rightWidget != nil
                ) {
                    onSelectSlot(false)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func getWidgetCount() -> Int
    {
        var count = 0
        if view.leftWidget != nil { count += 1 }
        if view.rightWidget != nil { count += 1 }
        return count
    }
}

struct SlotButton: View
{
    let title: String
    let widget: Widget?
    let isOccupied: Bool
    let onTap: () -> Void
    
    var body: some View
    {
        Button(action: onTap)
        {
            VStack(spacing: 8)
            {
                // Slot Preview
                ZStack
                {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(widget?.backgroundColor ?? Color(.systemGray4))
                        .frame(height: 80)
                    
                    if let widget = widget
                    {
                        VStack(spacing: 4)
                        {
                            Image(systemName: widget.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(widget.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                    } else
                    {
                        VStack(spacing: 2)
                        {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Empty")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Slot Label
                Text("\(title) Slot")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Status Indicator
                Text(isOccupied ? "Replace" : "Add")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isOccupied ? .orange : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background((isOccupied ? Color.orange : Color.blue).opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CreateViewSheet: View
{
    let widget: Widget
    @Binding var newViewName: String
    let onCreateAndAdd: (String, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSlot: String = "Left"
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 24)
            {
                // Header
                VStack(spacing: 16)
                {
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(widget.backgroundColor)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: widget.iconName)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4)
                    {
                        Text("Create View for \(widget.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Set up a new custom layout")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20)
                {
                    // View Name Input
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("View Name")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        TextField("e.g. Bedtime, Work, Weekend", text: $newViewName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Slot Selection
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text("Widget Position")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 16)
                        {
                            // Left Slot Option
                            Button(action: { selectedSlot = "Left" })
                            {
                                VStack(spacing: 8)
                                {
                                    ZStack
                                    {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSlot == "Left" ? widget.backgroundColor : Color(.systemGray4))
                                            .frame(width: 80, height: 60)
                                        
                                        if selectedSlot == "Left"
                                        {
                                            Image(systemName: widget.iconName)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                        } else
                                        {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text("Left Slot")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedSlot == "Left" ? .blue : .secondary)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedSlot == "Left" ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            
                            // Right Slot Option
                            Button(action: { selectedSlot = "Right" })
                            {
                                VStack(spacing: 8)
                                {
                                    ZStack
                                    {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSlot == "Right" ? widget.backgroundColor : Color(.systemGray4))
                                            .frame(width: 80, height: 60)
                                        
                                        if selectedSlot == "Right"
                                        {
                                            Image(systemName: widget.iconName)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                        } else
                                        {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text("Right Slot")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedSlot == "Right" ? .blue : .secondary)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedSlot == "Right" ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                
                // Create Button
                Button(action: {
                    onCreateAndAdd(newViewName, selectedSlot == "Left")
                    dismiss()
                })
                {
                    HStack
                    {
                        Image(systemName: "plus.circle.fill")
                        Text("Create View & Add Widget")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("New View")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }
            }
        }
    }
}
