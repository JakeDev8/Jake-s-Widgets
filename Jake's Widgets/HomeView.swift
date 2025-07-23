//
//  HomeView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/22/25.
//

import SwiftUI

// Mock Widget Data Structure
struct Widget: Identifiable
{
    let id = UUID()
    let name: String
    let category: String
    let backgroundColor: Color
    let iconName: String
    let description: String
    let isNew: Bool
}

struct HomeView: View
{
    @StateObject private var viewManager = ViewManager()
    
    // Mock Data
    let featuredWidgets = [
        Widget(name: "Minimal Clock", category: "Time", backgroundColor: .black, iconName: "clock.fill", description: "Clean time display", isNew: false),
        Widget(name: "Weather Now", category: "Weather", backgroundColor: .blue, iconName: "cloud.sun.fill", description: "Current conditions", isNew: false),
        Widget(name: "Next Event", category: "Calendar", backgroundColor: .purple, iconName: "calendar", description: "Upcoming events", isNew: true),
        Widget(name: "Photo Frame", category: "Photos", backgroundColor: .orange, iconName: "photo.fill", description: "Rotating photos", isNew: false)
    ]
    
    let forYouWidgets = [
        Widget(name: "Workout Timer", category: "Fitness", backgroundColor: .green, iconName: "figure.run", description: "Exercise tracking", isNew: false),
        Widget(name: "Daily Quote", category: "Lifestyle", backgroundColor: .pink, iconName: "quote.bubble.fill", description: "Inspiration daily", isNew: true),
        Widget(name: "Stock Ticker", category: "Finance", backgroundColor: .indigo, iconName: "chart.line.uptrend.xyaxis", description: "Market updates", isNew: false),
        Widget(name: "Sleep Sounds", category: "Health", backgroundColor: .mint, iconName: "moon.zzz.fill", description: "Relaxing audio", isNew: false)
    ]
    
    let recentWidgets = [
        Widget(name: "Focus Mode", category: "Productivity", backgroundColor: .teal, iconName: "brain.head.profile", description: "Distraction-free", isNew: true),
        Widget(name: "Pet Cam", category: "Smart Home", backgroundColor: .brown, iconName: "camera.fill", description: "Check on pets", isNew: true),
        Widget(name: "Habit Tracker", category: "Lifestyle", backgroundColor: .red, iconName: "checkmark.circle.fill", description: "Daily habits", isNew: true),
        Widget(name: "Crypto Watch", category: "Finance", backgroundColor: .yellow, iconName: "bitcoinsign.circle.fill", description: "Crypto prices", isNew: true)
    ]
    
    var body: some View
    {
        NavigationView
        {
            ScrollView(.vertical, showsIndicators: false)
            {
                VStack(alignment: .leading, spacing: 25)
                {
                    // Featured Section
                    WidgetCarouselSection(
                        title: "Featured",
                        widgets: featuredWidgets
                    )
                    
                    // My Views Section
                    MyViewsSection(viewManager: viewManager)
                    
                    // For You Section
                    WidgetCarouselSection(
                        title: "For You",
                        widgets: forYouWidgets
                    )
                    
                    // Recently Added Section
                    WidgetCarouselSection(
                        title: "Recently Added",
                        widgets: recentWidgets
                    )
                    
                    // Idea Submission Section
                    IdeaSubmissionCard()
                    
                    Spacer(minLength: 100) // Tab bar padding
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WidgetCarouselSection: View
{
    let title: String
    let widgets: [Widget]
    
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
                        WidgetCard(widget: widget)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct WidgetCard: View
{
    let widget: Widget
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            // Widget Preview
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.backgroundColor.gradient)
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                    
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
        .onTapGesture
        {
            // Handle widget selection
        }
    }
}

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
                
                NavigationLink(destination: Text("Preview View")) // This will link to PreviewView
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
                        ForEach(viewManager.widgetViews) { view in
                            HomeViewCard(view: view)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

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
                            .fill(leftWidget.backgroundColor)
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
                            .fill(rightWidget.backgroundColor)
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
        .onTapGesture
        {
            // Handle view selection - could navigate to PreviewView with this view selected
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
