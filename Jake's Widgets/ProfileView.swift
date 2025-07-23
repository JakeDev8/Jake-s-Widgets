//
//  MyWidgets.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/22/25.
//

import SwiftUI

// Shared data model for managing widget views across the app
class ViewManager: ObservableObject
{
    @Published var widgetViews: [WidgetView] = []
    
    // Available widgets (same as in other files - could be moved to separate file)
    let availableWidgets = [
        Widget(name: "Minimal Clock", category: "Time", backgroundColor: .black, iconName: "clock.fill", description: "Clean time display", isNew: false),
        Widget(name: "Weather Now", category: "Weather", backgroundColor: .blue, iconName: "cloud.sun.fill", description: "Current conditions", isNew: false),
        Widget(name: "Next Event", category: "Calendar", backgroundColor: .purple, iconName: "calendar", description: "Upcoming events", isNew: true),
        Widget(name: "Photo Frame", category: "Photos", backgroundColor: .orange, iconName: "photo.fill", description: "Rotating photos", isNew: false),
        Widget(name: "Workout Timer", category: "Fitness", backgroundColor: .green, iconName: "figure.run", description: "Exercise tracking", isNew: false),
        Widget(name: "Daily Quote", category: "Lifestyle", backgroundColor: .pink, iconName: "quote.bubble.fill", description: "Inspiration daily", isNew: true),
        Widget(name: "Focus Mode", category: "Productivity", backgroundColor: .teal, iconName: "brain.head.profile", description: "Distraction-free", isNew: true),
        Widget(name: "Sleep Sounds", category: "Health", backgroundColor: .mint, iconName: "moon.zzz.fill", description: "Relaxing audio", isNew: false)
    ]
    
    init()
    {
        // Create default views if none exist
        if widgetViews.isEmpty
        {
            createDefaultViews()
        }
    }
    
    func createDefaultViews()
    {
        widgetViews = [
            WidgetView(
                name: "Bedtime",
                leftWidget: availableWidgets.first { $0.name == "Minimal Clock" },
                rightWidget: availableWidgets.first { $0.name == "Sleep Sounds" }
            ),
            WidgetView(
                name: "Morning",
                leftWidget: availableWidgets.first { $0.name == "Weather Now" },
                rightWidget: availableWidgets.first { $0.name == "Next Event" }
            ),
            WidgetView(
                name: "Work Focus",
                leftWidget: availableWidgets.first { $0.name == "Focus Mode" },
                rightWidget: availableWidgets.first { $0.name == "Next Event" }
            )
        ]
    }
    
    func addView(_ view: WidgetView)
    {
        widgetViews.append(view)
    }
    
    func deleteView(at index: Int)
    {
        guard index < widgetViews.count else { return }
        widgetViews.remove(at: index)
    }
    
    func renameView(at index: Int, newName: String)
    {
        guard index < widgetViews.count else { return }
        widgetViews[index].name = newName
    }
}

struct ProfileView: View
{
    @StateObject private var viewManager = ViewManager()
    @State private var showingEditView = false
    @State private var editingIndex: Int?
    @State private var newName = ""
    
    var body: some View
    {
        NavigationView
        {
            ScrollView(.vertical, showsIndicators: false)
            {
                VStack(alignment: .leading, spacing: 24)
                {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12)
                    {
                        HStack
                        {
                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text("My Views")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("\(viewManager.widgetViews.count) custom view\(viewManager.widgetViews.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: CreateNewViewPage(viewManager: viewManager))
                            {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Create and manage your custom StandBy layouts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Views Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16)
                    {
                        ForEach(Array(viewManager.widgetViews.enumerated()), id: \.element.id) { index, view in
                            ProfileViewCard(
                                view: view,
                                onEdit: {
                                    editingIndex = index
                                    newName = view.name
                                    showingEditView = true
                                },
                                onDelete: {
                                    viewManager.deleteView(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Usage Stats Section
                    VStack(alignment: .leading, spacing: 16)
                    {
                        Text("Usage")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12)
                        {
                            UsageStatRow(
                                icon: "eye.fill",
                                title: "Total Previews",
                                value: "47",
                                color: .blue
                            )
                            
                            UsageStatRow(
                                icon: "clock.fill",
                                title: "Time in Preview Mode",
                                value: "2h 15m",
                                color: .green
                            )
                            
                            UsageStatRow(
                                icon: "heart.fill",
                                title: "Favorite View",
                                value: viewManager.widgetViews.first?.name ?? "None",
                                color: .pink
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100) // Tab bar padding
                }
                .padding(.top, 10)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditView)
        {
            EditViewSheet(
                currentName: newName,
                onSave: { updatedName in
                    if let index = editingIndex
                    {
                        viewManager.renameView(at: index, newName: updatedName)
                    }
                }
            )
        }
    }
}

struct ProfileViewCard: View
{
    let view: WidgetView
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            // Preview Section
            HStack(spacing: 8)
            {
                // Left widget preview
                if let leftWidget = view.leftWidget
                {
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(leftWidget.backgroundColor)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: leftWidget.iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else
                {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray4))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        )
                }
                
                // Right widget preview
                if let rightWidget = view.rightWidget
                {
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(rightWidget.backgroundColor)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: rightWidget.iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else
                {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray4))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        )
                }
            }
            
            // View Info
            VStack(spacing: 4)
            {
                Text(view.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("\(getWidgetCount(for: view)) widget\(getWidgetCount(for: view) == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Action Button
            Button(action: {
                showingActionSheet = true
            })
            {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .confirmationDialog("Edit View", isPresented: $showingActionSheet, titleVisibility: .visible)
        {
            Button("Rename")
            {
                onEdit()
            }
            
            Button("Delete", role: .destructive)
            {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
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

struct UsageStatRow: View
{
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View
    {
        HStack(spacing: 16)
        {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2)
            {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EditViewSheet: View
{
    @State private var viewName: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(currentName: String, onSave: @escaping (String) -> Void)
    {
        self._viewName = State(initialValue: currentName)
        self.onSave = onSave
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 20)
            {
                TextField("View Name", text: $viewName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Rename View")
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
                
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Save")
                    {
                        onSave(viewName)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewName.isEmpty)
                }
            }
        }
    }
}

struct CreateNewViewPage: View
{
    @ObservedObject var viewManager: ViewManager
    @State private var newViewName = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        VStack(spacing: 24)
        {
            VStack(spacing: 16)
            {
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("Create New View")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Give your custom StandBy layout a name")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            TextField("View Name (e.g., Bedtime, Work, Weekend)", text: $newViewName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                let newView = WidgetView(name: newViewName.isEmpty ? "New View" : newViewName)
                viewManager.addView(newView)
                dismiss()
            })
            {
                Text("Create View")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle("New View")
        .navigationBarTitleDisplayMode(.inline)
    }
}
