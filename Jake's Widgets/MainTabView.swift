//
//  MainTabView.swift
//  Jake's Widgets
//
//  UPDATED: Enhanced WidgetsView with Premium Clock integration
//

import SwiftUI
import WidgetKit

struct MainTabView: View
{
    @State private var selectedTab = 0
    @StateObject private var viewManager = ViewManager()
    
    // Universal fullscreen preview states - now with persistence
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var currentViewIndex = 0
    @State private var isDarkMode = false
    
    private let persistenceManager = PersistenceManager.shared
    
    var body: some View
    {
        TabView(selection: $selectedTab)
        {
            HomeView(viewManager: viewManager)
                .tabItem
                {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // UPDATED: Enhanced WidgetsView with Premium Clock
            WidgetsView()
                .tabItem
                {
                    Image(systemName: selectedTab == 1 ? "apps.iphone" : "apps.iphone")
                    Text("Widgets")
                }
                .tag(1)
            
            PreviewView(
                viewManager: viewManager,
                currentViewIndex: $currentViewIndex,
                isDarkMode: $isDarkMode
            )
                .tabItem
                {
                    Image(systemName: selectedTab == 2 ? "iphone.landscape" : "iphone.landscape")
                    Text("Preview")
                }
                .tag(2)
            
            ProfileView(viewManager: viewManager)
                .tabItem
                {
                    Image(systemName: selectedTab == 3 ? "rectangle.stack.fill" : "rectangle.stack")
                    Text("Views")
                }
                .tag(3)
        }
        .accentColor(.primary)
        .environmentObject(viewManager)
        .fullScreenCover(isPresented: .constant(orientation.isLandscape && !viewManager.widgetViews.isEmpty))
        {
            FullScreenPreviewView(
                widgetViews: viewManager.widgetViews,
                initialIndex: currentViewIndex,
                isDarkMode: isDarkMode
            ) { newIndex in
                currentViewIndex = newIndex
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        .onAppear
        {
            orientation = UIDevice.current.orientation
            loadSettings()
        }
        .onChange(of: currentViewIndex) { _, newIndex in
            persistenceManager.saveCurrentViewIndex(newIndex)
        }
        .onChange(of: isDarkMode) { _, newMode in
            persistenceManager.saveDarkMode(newMode)
        }
    }
    
    private func loadSettings()
    {
        currentViewIndex = persistenceManager.loadCurrentViewIndex()
        isDarkMode = persistenceManager.loadDarkMode()
        
        if currentViewIndex >= viewManager.widgetViews.count
        {
            currentViewIndex = 0
            persistenceManager.saveCurrentViewIndex(0)
        }
        
        print("📱 Loaded settings: viewIndex=\(currentViewIndex), darkMode=\(isDarkMode)")
    }
}

// MARK: - Enhanced WidgetsView with Premium Clock Integration
struct WidgetsView: View
{
    @EnvironmentObject var viewManager: ViewManager
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showingFavoritesOnly = false
    @State private var showingPremiumOnly = false
    @State private var showingPremiumClockConfig = false
    
    let categories = ["All", "Time", "Weather", "Calendar", "Photos", "Fitness", "Lifestyle", "Finance", "Productivity", "Health", "Smart Home"]
    
    var filteredWidgets: [EnhancedWidget]
    {
        var widgets = viewManager.availableWidgets
        
        if !searchText.isEmpty
        {
            widgets = widgets.filter { widget in
                widget.name.localizedCaseInsensitiveContains(searchText) ||
                widget.description.localizedCaseInsensitiveContains(searchText) ||
                widget.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedCategory != "All"
        {
            widgets = widgets.filter { $0.category == selectedCategory }
        }
        
        if showingPremiumOnly
        {
            widgets = widgets.filter { $0.isPremium }
        }
        
        widgets = widgets.filter { viewManager.subscriptionManager.canAccessWidget($0) }
        
        return widgets
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 0)
            {
                // Search and Filter Header
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
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false)
                    {
                        HStack(spacing: 12)
                        {
                            ForEach(categories, id: \.self) { category in
                                CategoryFilterChip(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Quick Filters
                    HStack(spacing: 16)
                    {
                        QuickFilterToggle(title: "Premium Only", isOn: $showingPremiumOnly)
                        
                        Spacer()
                        
                        Text("\(filteredWidgets.count) widgets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Content
                ScrollView
                {
                    VStack(spacing: 20)
                    {
                        // NEW: Premium Clock Section (at the top)
                        VStack(spacing: 16)
                        {
                            HStack
                            {
                                Text("Premium Widgets")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                            }
                            .padding(.horizontal, 20)
                            
                            // Premium Clock Card
                            PremiumClockWidgetCard(subscriptionManager: viewManager.subscriptionManager)
                            {
                                showingPremiumClockConfig = true
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Divider
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // All Widgets Section
                        VStack(spacing: 16)
                        {
                            Text("All Widgets")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            // Widgets Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16)
                            {
                                ForEach(filteredWidgets) { widget in
                                    NavigationLink(destination: EnhancedWidgetDetailView(widget: widget))
                                    {
                                        WidgetsBrowserCard(widget: widget, subscriptionManager: viewManager.subscriptionManager)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Premium Upsell (if not premium user)
                        if !viewManager.subscriptionManager.isPremiumUser
                        {
                            WidgetsPremiumUpsell(subscriptionManager: viewManager.subscriptionManager)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100) // Tab bar padding
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Widgets")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPremiumClockConfig)
        {
            PremiumClockConfigurationView()
        }
    }
}

// MARK: - NEW: Premium Clock Widget Card
struct PremiumClockWidgetCard: View
{
    @ObservedObject var subscriptionManager: BasicSubscriptionManager
    let onTap: () -> Void
    
    var body: some View
    {
        Button(action: onTap)
        {
            HStack(spacing: 16)
            {
                // Clock Preview
                ZStack
                {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [.black, .gray.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 4)
                    {
                        // Live Clock Display
                        LiveClockText()
                        
                        // Premium Badge
                        Text("PRO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Widget Info
                VStack(alignment: .leading, spacing: 8)
                {
                    HStack
                    {
                        Text("Premium Clock")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    Text("50+ Customization Options")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8)
                    {
                        FeatureBadge(text: "Live Updates")
                        FeatureBadge(text: "StandBy Ready")
                        FeatureBadge(text: "Themes")
                    }
                    
                    Text(subscriptionManager.isPremiumUser ?
                         "Tap to configure your clock widget" :
                         "Upgrade to unlock full customization")
                        .font(.caption)
                        .foregroundColor(subscriptionManager.isPremiumUser ? .blue : .orange)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        subscriptionManager.isPremiumUser ? Color.blue : Color.yellow,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views for Premium Clock Card

struct LiveClockText: View
{
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View
    {
        Text(timeString)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .onReceive(timer) { time in
                currentTime = time
            }
    }
    
    private var timeString: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
}

struct FeatureBadge: View
{
    let text: String
    
    var body: some View
    {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .clipShape(Capsule())
    }
}

// MARK: - Existing Supporting Views (from your original code)

struct CategoryFilterChip: View
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

struct QuickFilterToggle: View
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

struct WidgetsBrowserCard: View
{
    let widget: EnhancedWidget
    let subscriptionManager: BasicSubscriptionManager
    
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

struct WidgetsPremiumUpsell: View
{
    @ObservedObject var subscriptionManager: BasicSubscriptionManager
    
    var body: some View
    {
        VStack(spacing: 16)
        {
            HStack(spacing: 12)
            {
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4)
                {
                    Text("Unlock Premium Widgets")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Get access to dynamic, live-updating widgets with premium features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button("Upgrade to Pro")
            {
                // For now, toggle for testing
                subscriptionManager.togglePremiumForTesting()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
