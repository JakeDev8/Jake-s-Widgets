//
//  HomeView.swift
//  Jake's Widgets
//
//  COMPLETE VERSION: Integrated search functionality + all missing components
//

import SwiftUI

struct HomeView: View
{
    @ObservedObject var viewManager: ViewManager
    
    // NEW: Search state
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    
    // Mock Data using EnhancedWidget (keeping your existing structure)
    let featuredWidgets = [
        EnhancedWidget(name: "Minimal Clock", category: "Time", backgroundColor: .black, iconName: "clock.fill", description: "Clean time display perfect for StandBy mode", isNew: false),
        EnhancedWidget(name: "Weather Now", category: "Weather", backgroundColor: .blue, iconName: "cloud.sun.fill", description: "Current weather conditions and temperature", isNew: false),
        EnhancedWidget(name: "Live Weather Radar", category: "Weather", backgroundColor: .cyan, iconName: "cloud.rain.fill", description: "Real-time animated weather radar", isNew: true, isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Photo Frame", category: "Photos", backgroundColor: .orange, iconName: "photo.fill", description: "Rotating photos from your library", isNew: false)
    ]
    
    let forYouWidgets = [
        EnhancedWidget(name: "Workout Timer", category: "Fitness", backgroundColor: .green, iconName: "figure.run", description: "Track your exercise sessions", isNew: false),
        EnhancedWidget(name: "Daily Quote", category: "Lifestyle", backgroundColor: .pink, iconName: "quote.bubble.fill", description: "Inspirational quotes to start your day", isNew: true),
        EnhancedWidget(name: "Dynamic Crypto Ticker", category: "Finance", backgroundColor: .orange, iconName: "bitcoinsign.circle.fill", description: "Live crypto prices with trend indicators", isNew: true, isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Sleep Sounds", category: "Health", backgroundColor: .mint, iconName: "moon.zzz.fill", description: "Relaxing audio for better sleep", isNew: false)
    ]
    
    let recentWidgets = [
        EnhancedWidget(name: "Focus Mode", category: "Productivity", backgroundColor: .teal, iconName: "brain.head.profile", description: "Distraction-free work environment", isNew: true),
        EnhancedWidget(name: "Smart Home Dashboard", category: "Smart Home", backgroundColor: .teal, iconName: "house.fill", description: "Control lights, temperature, and more", isPremium: true, dynamicContent: true),
        EnhancedWidget(name: "Habit Tracker", category: "Lifestyle", backgroundColor: .red, iconName: "checkmark.circle.fill", description: "Track your daily habits", isNew: true),
        EnhancedWidget(name: "Crypto Watch", category: "Finance", backgroundColor: .yellow, iconName: "bitcoinsign.circle.fill", description: "Monitor cryptocurrency prices", isNew: true)
    ]
    
    // NEW: Combined widget list for searching
    var allWidgets: [EnhancedWidget]
    {
        return featuredWidgets + forYouWidgets + recentWidgets + viewManager.availableWidgets
    }
    
    // NEW: Filtered search results
    var searchResults: [EnhancedWidget]
    {
        if searchText.isEmpty
        {
            return []
        }
        
        return allWidgets.filter { widget in
            widget.name.localizedCaseInsensitiveContains(searchText) ||
            widget.description.localizedCaseInsensitiveContains(searchText) ||
            widget.category.localizedCaseInsensitiveContains(searchText)
        }
        .removingDuplicates() // Remove duplicates based on ID
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 0)
            {
                // NEW: Integrated Search Bar
                SearchBarHeader(
                    searchText: $searchText,
                    isSearching: $isSearching,
                    isSearchFocused: $isSearchFocused
                )
                
                // Content based on search state
                if isSearching && !searchText.isEmpty
                {
                    // Search Results View
                    SearchResultsView(
                        searchResults: searchResults,
                        searchText: searchText,
                        subscriptionManager: viewManager.subscriptionManager
                    )
                } else
                {
                    // Regular Home Content
                    ScrollView(.vertical, showsIndicators: false)
                    {
                        VStack(alignment: .leading, spacing: 25)
                        {
                            // Premium Banner (if not premium)
                            if !viewManager.subscriptionManager.isPremiumUser
                            {
                                SimplePremiumBanner(subscriptionManager: viewManager.subscriptionManager)
                            }
                            
                            // Featured Section
                            EnhancedWidgetCarouselSection(
                                title: "Featured",
                                widgets: featuredWidgets,
                                subscriptionManager: viewManager.subscriptionManager
                            )
                            
                            // My Views Section
                            MyViewsSection(viewManager: viewManager)
                            
                            // For You Section
                            EnhancedWidgetCarouselSection(
                                title: "For You",
                                widgets: forYouWidgets,
                                subscriptionManager: viewManager.subscriptionManager
                            )
                            
                            // Recently Added Section
                            EnhancedWidgetCarouselSection(
                                title: "Recently Added",
                                widgets: recentWidgets,
                                subscriptionManager: viewManager.subscriptionManager
                            )
                            
                            // Idea Submission Section
                            IdeaSubmissionCard()
                            
                            // Debug Premium Toggle (remove in production)
                            #if DEBUG
                            DebugPremiumToggle(subscriptionManager: viewManager.subscriptionManager)
                            #endif
                            
                            Spacer(minLength: 100) // Tab bar padding
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle(isSearching ? "" : "Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(isSearching)
        }
        .onChange(of: searchText) { _, newValue in
            isSearching = !newValue.isEmpty || isSearchFocused
        }
        .onChange(of: isSearchFocused) { _, focused in
            if !focused && searchText.isEmpty
            {
                isSearching = false
            } else if focused
            {
                isSearching = true
            }
        }
    }
}

// MARK: - Search Components

// NEW: Search Bar Header Component
struct SearchBarHeader: View
{
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View
    {
        HStack(spacing: 12)
        {
            // Search Field
            HStack
            {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search widgets...", text: $searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty
                {
                    Button(action: {
                        searchText = ""
                        isSearchFocused = false
                    })
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
            
            // Cancel Button (only show when searching)
            if isSearching
            {
                Button("Cancel")
                {
                    searchText = ""
                    isSearchFocused = false
                    isSearching = false
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }
}

// NEW: Search Results View Component
struct SearchResultsView: View
{
    let searchResults: [EnhancedWidget]
    let searchText: String
    let subscriptionManager: BasicSubscriptionManager
    
    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading, spacing: 16)
            {
                // Results Header
                HStack
                {
                    Text("Results for \"\(searchText)\"")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(searchResults.count) found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                if searchResults.isEmpty
                {
                    // Empty State
                    VStack(spacing: 16)
                    {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No widgets found")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for different keywords like 'weather', 'clock', or 'fitness'")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else
                {
                    // Results Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16)
                    {
                        ForEach(searchResults) { widget in
                            NavigationLink(destination: EnhancedWidgetDetailView(widget: widget))
                            {
                                if subscriptionManager.canAccessWidget(widget)
                                {
                                    EnhancedWidgetCard(widget: widget)
                                } else
                                {
                                    LockedPremiumWidgetCard(widget: widget)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100) // Tab bar padding
            }
        }
    }
}

// NEW: Extension to remove duplicates
extension Array where Element: Identifiable
{
    func removingDuplicates() -> [Element]
    {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}

// MARK: - All Missing Components (from your original HomeView.swift)

// Enhanced Widget Carousel Section
struct EnhancedWidgetCarouselSection: View
{
    let title: String
    let widgets: [EnhancedWidget]
    let subscriptionManager: BasicSubscriptionManager
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            HStack
            {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("See More")
                {
                    // Navigate to full category view
                }
                .foregroundColor(.blue)
                .font(.subheadline)
            }
            
            ScrollView(.horizontal, showsIndicators: false)
            {
                HStack(spacing: 16)
                {
                    ForEach(widgets) { widget in
                        NavigationLink(destination: EnhancedWidgetDetailView(widget: widget))
                        {
                            if subscriptionManager.canAccessWidget(widget)
                            {
                                // User can access this widget
                                EnhancedWidgetCard(widget: widget)
                            } else
                            {
                                // Show locked premium widget
                                LockedPremiumWidgetCard(widget: widget)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// Locked Premium Widget Card
struct LockedPremiumWidgetCard: View
{
    let widget: EnhancedWidget
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            // Widget Preview (locked state)
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray4))
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4)
                {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.secondary)
                    
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
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 120, height: 120)
            )
            
            // Widget Name
            Text(widget.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}

// Simple Premium Banner
struct SimplePremiumBanner: View
{
    @ObservedObject var subscriptionManager: BasicSubscriptionManager
    
    var body: some View
    {
        HStack(spacing: 12)
        {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4)
            {
                Text("Unlock Premium Widgets")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Get access to live updates and dynamic content!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Try Pro")
            {
                // For now, just toggle for testing
                subscriptionManager.togglePremiumForTesting()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Debug Premium Toggle (for testing)
#if DEBUG
struct DebugPremiumToggle: View
{
    @ObservedObject var subscriptionManager: BasicSubscriptionManager
    
    var body: some View
    {
        HStack
        {
            Text("DEBUG: Premium Status")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(subscriptionManager.isPremiumUser ? "Disable Premium" : "Enable Premium")
            {
                subscriptionManager.togglePremiumForTesting()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
#endif

// Enhanced Widget Detail View
struct EnhancedWidgetDetailView: View
{
    let widget: EnhancedWidget
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        VStack(spacing: 20)
        {
            // Large widget preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 24)
                    .fill(widget.themedBackgroundColor.gradient)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 12)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 64, weight: .medium))
                        .foregroundColor(.white)
                    
                    if widget.isPremium
                    {
                        Text("PRO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
            }
            
            VStack(spacing: 8)
            {
                Text(widget.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(widget.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Idea Submission Card
struct IdeaSubmissionCard: View
{
    var body: some View
    {
        VStack(spacing: 16)
        {
            HStack
            {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4)
                {
                    Text("Got an idea?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Send your widget ideas to the developer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                // Open idea submission form/Google Form
                if let url = URL(string: "https://forms.google.com/your-form-id")
                {
                    UIApplication.shared.open(url)
                }
            })
            {
                HStack
                {
                    Image(systemName: "paperplane.fill")
                    Text("Submit Idea")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// My Views Section
struct MyViewsSection: View
{
    @ObservedObject var viewManager: ViewManager
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            HStack
            {
                Text("My Views")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: Text("Preview View - Coming Soon!")) // TODO: Link to PreviewView with proper navigation
                {
                    Text("See More")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            
            if viewManager.widgetViews.isEmpty
            {
                // Empty state
                VStack(spacing: 12)
                {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No custom views yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Create your first StandBy layout in Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else
            {
                ScrollView(.horizontal, showsIndicators: false)
                {
                    HStack(spacing: 16)
                    {
                        ForEach(Array(viewManager.widgetViews.enumerated()), id: \.element.id) { index, view in
                            NavigationLink(destination: UserViewCreator(viewManager: viewManager, viewIndex: index))
                            {
                                HomeViewCard(view: view)
                            }
                            .buttonStyle(PlainButtonStyle()) // Prevents default button styling
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

// Home View Card
struct HomeViewCard: View
{
    let view: WidgetView
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            // Mini StandBy Preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 80)
                
                HStack(spacing: 6)
                {
                    // Left widget mini preview
                    if let leftWidget = view.leftWidget
                    {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(leftWidget.themedBackgroundColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: leftWidget.iconName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    } else
                    {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray4))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    // Right widget mini preview
                    if let rightWidget = view.rightWidget
                    {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(rightWidget.themedBackgroundColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: rightWidget.iconName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    } else
                    {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray4))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            )
                    }
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            // View Name
            VStack(spacing: 2)
            {
                Text(view.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text("\(getWidgetCount(for: view)) widget\(getWidgetCount(for: view) == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120)
        }
    }
    
    private func getWidgetCount(for view: WidgetView) -> Int
    {
        var count = 0
        if view.leftWidget != nil { count += 1 }
        if view.rightWidget != nil { count += 1 }
        return count
    }
}
