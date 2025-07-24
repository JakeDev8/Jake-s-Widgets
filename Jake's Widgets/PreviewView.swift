//
//  PreviewView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/22/25.
//

import SwiftUI

struct PreviewView: View
{
    @ObservedObject var viewManager: ViewManager
    @Binding var currentViewIndex: Int
    @Binding var isDarkMode: Bool
    
    @State private var distanceScale: Double = 1.0
    @State private var isSelectingLeft = true
    @State private var showingAddView = false
    @State private var newViewName = ""
    
    private let persistenceManager = PersistenceManager.shared
    
    var currentView: WidgetView?
    {
        guard !viewManager.widgetViews.isEmpty && currentViewIndex < viewManager.widgetViews.count else { return nil }
        return viewManager.widgetViews[currentViewIndex]
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 0)
            {
                // Control Panel
                VStack(spacing: 16)
                {
                    // View Management Section
                    VStack(spacing: 12)
                    {
                        HStack
                        {
                            Text("My Views")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: { showingAddView = true })
                            {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        
                        if !viewManager.widgetViews.isEmpty
                        {
                            // View Selection Carousel
                            ScrollView(.horizontal, showsIndicators: false)
                            {
                                HStack(spacing: 12)
                                {
                                    ForEach(Array(viewManager.widgetViews.enumerated()), id: \.element.id) { index, view in
                                        ViewCard(
                                            view: view,
                                            isSelected: index == currentViewIndex
                                        )
                                        {
                                            currentViewIndex = index
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Mode and Distance Controls
                    HStack(spacing: 20)
                    {
                        // Dark/Light Toggle
                        VStack(spacing: 4)
                        {
                            Text("Appearance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12)
                            {
                                Button(action: { isDarkMode = false })
                                {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(isDarkMode ? .secondary : .yellow)
                                        .font(.title3)
                                }
                                
                                Button(action: { isDarkMode = true })
                                {
                                    Image(systemName: "moon.fill")
                                        .foregroundColor(isDarkMode ? .blue : .secondary)
                                        .font(.title3)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Distance Slider
                        VStack(spacing: 4)
                        {
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack
                            {
                                Image(systemName: "bed.double.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Slider(value: $distanceScale, in: 0.7...1.3, step: 0.1)
                                    .frame(width: 100)
                                
                                Image(systemName: "sofa.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Widget Slot Selection (only show if we have a current view)
                    if currentView != nil
                    {
                        HStack(spacing: 16)
                        {
                            Button(action: { isSelectingLeft = true })
                            {
                                HStack
                                {
                                    Image(systemName: "arrow.left")
                                    Text("Left Widget")
                                }
                                .foregroundColor(isSelectingLeft ? .white : .blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isSelectingLeft ? Color.blue : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Button(action: { isSelectingLeft = false })
                            {
                                HStack
                                {
                                    Text("Right Widget")
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(!isSelectingLeft ? .white : .blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(!isSelectingLeft ? Color.blue : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                Spacer()
                
                // StandBy Mode Simulation
                if let currentView = currentView
                {
                    VStack(spacing: 16)
                    {
                        StandBySimulator(
                            leftWidget: currentView.leftWidget,
                            rightWidget: currentView.rightWidget,
                            isDarkMode: isDarkMode,
                            scale: distanceScale
                        )
                        
                        // Rotation Instruction
                        HStack(spacing: 8)
                        {
                            Image(systemName: "rotate.right")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            VStack(spacing: 2)
                            {
                                Text("Rotate for fullscreen preview")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Swipe left/right to change views")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else
                {
                    // Empty state
                    VStack(spacing: 16)
                    {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Create your first view")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Button("Add View")
                        {
                            showingAddView = true
                        }
                        .foregroundColor(.blue)
                        .font(.headline)
                    }
                }
                
                Spacer()
                
                // Widget Selection Carousel (only show if we have a current view)
                if currentView != nil
                {
                    VStack(spacing: 12)
                    {
                        Text("Select Widget for \(isSelectingLeft ? "Left" : "Right") Slot")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false)
                        {
                            HStack(spacing: 16)
                            {
                                // Empty/Clear option
                                Button(action: {
                                    viewManager.setWidget(nil, at: currentViewIndex, isLeftSlot: isSelectingLeft)
                                })
                                {
                                    VStack(spacing: 8)
                                    {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray4))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .font(.title2)
                                                    .foregroundColor(.secondary)
                                            )
                                        
                                        Text("Clear")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Available widgets
                                ForEach(viewManager.availableWidgets) { widget in
                                    Button(action: {
                                        viewManager.setWidget(widget, at: currentViewIndex, isLeftSlot: isSelectingLeft)
                                    })
                                    {
                                        PreviewWidgetCard(
                                            widget: widget,
                                            isSelected: isSelectingLeft ?
                                                currentView?.leftWidget?.id == widget.id :
                                                currentView?.rightWidget?.id == widget.id
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingAddView)
        {
            AddViewSheet(newViewName: $newViewName)
            {
                let newView = WidgetView(name: newViewName.isEmpty ? "View \(viewManager.widgetViews.count + 1)" : newViewName)
                viewManager.addView(newView)
                currentViewIndex = viewManager.widgetViews.count - 1
                newViewName = ""
            }
        }
        .onAppear
        {
            // Load distance scale preference
            distanceScale = persistenceManager.loadDistanceScale()
        }
        .onChange(of: distanceScale) { _, newScale in
            // Save distance scale preference
            persistenceManager.saveDistanceScale(newScale)
        }
    }
}

struct ViewCard: View
{
    let view: WidgetView
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View
    {
        Button(action: onTap)
        {
            VStack(spacing: 8)
            {
                // Mini preview of the view
                HStack(spacing: 4)
                {
                    // Left widget mini preview
                    if let leftWidget = view.leftWidget
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(leftWidget.backgroundColor.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: leftWidget.iconName)
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                            )
                    } else
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray4))
                            .frame(width: 24, height: 24)
                    }
                    
                    // Right widget mini preview
                    if let rightWidget = view.rightWidget
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(rightWidget.backgroundColor.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: rightWidget.iconName)
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                            )
                    } else
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray4))
                            .frame(width: 24, height: 24)
                    }
                }
                
                Text(view.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct AddViewSheet: View
{
    @Binding var newViewName: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 20)
            {
                TextField("View Name (e.g., Bedtime, Work, etc.)", text: $newViewName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Add New View")
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
                    Button("Add")
                    {
                        onAdd()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct FullScreenPreviewView: View
{
    let widgetViews: [WidgetView]
    let initialIndex: Int
    let isDarkMode: Bool
    let onIndexChange: (Int) -> Void
    
    @State private var currentIndex: Int
    
    init(widgetViews: [WidgetView], initialIndex: Int, isDarkMode: Bool, onIndexChange: @escaping (Int) -> Void)
    {
        self.widgetViews = widgetViews
        self.initialIndex = initialIndex
        self.isDarkMode = isDarkMode
        self.onIndexChange = onIndexChange
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View
    {
        ZStack
        {
            // Background (matches StandBy mode)
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            TabView(selection: $currentIndex)
            {
                ForEach(Array(widgetViews.enumerated()), id: \.element.id) { index, view in
                    FullScreenWidgetViewDisplay(view: view, isDarkMode: isDarkMode)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentIndex)
            { _, newIndex in
                onIndexChange(newIndex)
            }
            
            // View name and indicators overlay
            VStack
            {
                HStack
                {
                    Spacer()
                    
                    VStack(spacing: 8)
                    {
                        Text(widgetViews[currentIndex].name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        // Page indicators
                        HStack(spacing: 6)
                        {
                            ForEach(0..<widgetViews.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex ? Color.blue : Color(.systemGray4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground).opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                Text("Rotate to portrait to exit")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .statusBarHidden()
    }
}

struct FullScreenWidgetViewDisplay: View
{
    let view: WidgetView
    let isDarkMode: Bool
    
    var body: some View
    {
        HStack(spacing: 40)
        {
            // Left widget slot
            if let leftWidget = view.leftWidget
            {
                FullScreenWidgetDisplay(widget: leftWidget, isDarkMode: isDarkMode)
            } else
            {
                FullScreenEmptySlot(isDarkMode: isDarkMode)
            }
            
            // Right widget slot
            if let rightWidget = view.rightWidget
            {
                FullScreenWidgetDisplay(widget: rightWidget, isDarkMode: isDarkMode)
            } else
            {
                FullScreenEmptySlot(isDarkMode: isDarkMode)
            }
        }
    }
}

// Extension to check if device is in landscape
extension UIDeviceOrientation
{
    var isLandscape: Bool
    {
        return self == .landscapeLeft || self == .landscapeRight
    }
}

struct StandBySimulator: View
{
    let leftWidget: Widget?
    let rightWidget: Widget?
    let isDarkMode: Bool
    let scale: Double
    
    var body: some View
    {
        // iPhone frame in landscape
        ZStack
        {
            // iPhone outline
            RoundedRectangle(cornerRadius: 25)
                .fill(isDarkMode ? Color.black : Color.white)
                .frame(width: 350 * scale, height: 160 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.systemGray3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Widget display area
            HStack(spacing: 20 * scale)
            {
                // Left widget slot
                if let leftWidget = leftWidget
                {
                    StandByWidgetDisplay(widget: leftWidget, isDarkMode: isDarkMode)
                        .scaleEffect(scale)
                } else
                {
                    EmptyWidgetSlot(isDarkMode: isDarkMode)
                        .scaleEffect(scale)
                }
                
                // Right widget slot
                if let rightWidget = rightWidget
                {
                    StandByWidgetDisplay(widget: rightWidget, isDarkMode: isDarkMode)
                        .scaleEffect(scale)
                } else
                {
                    EmptyWidgetSlot(isDarkMode: isDarkMode)
                        .scaleEffect(scale)
                }
            }
        }
    }
}

struct StandByWidgetDisplay: View
{
    let widget: Widget
    let isDarkMode: Bool
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 12)
                .fill(widget.backgroundColor.color.opacity(isDarkMode ? 0.8 : 1.0))
                .frame(width: 120, height: 120)
            
            VStack(spacing: 6)
            {
                Image(systemName: widget.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                Text(widget.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
}

struct EmptyWidgetSlot: View
{
    let isDarkMode: Bool
    
    var body: some View
    {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5).opacity(isDarkMode ? 0.3 : 0.5))
            .frame(width: 120, height: 120)
            .overlay(
                VStack(spacing: 4)
                {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Empty")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            )
    }
}

struct FullScreenWidgetDisplay: View
{
    let widget: Widget
    let isDarkMode: Bool
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 24)
                .fill(widget.backgroundColor.color.opacity(isDarkMode ? 0.9 : 1.0))
                .frame(width: 200, height: 200)
            
            VStack(spacing: 12)
            {
                Image(systemName: widget.iconName)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                
                Text(widget.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .shadow(color: .black.opacity(isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
    }
}

struct FullScreenEmptySlot: View
{
    let isDarkMode: Bool
    
    var body: some View
    {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(.systemGray5).opacity(isDarkMode ? 0.2 : 0.3))
            .frame(width: 200, height: 200)
            .overlay(
                VStack(spacing: 8)
                {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("Empty")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            )
    }
}

struct PreviewWidgetCard: View
{
    let widget: Widget
    let isSelected: Bool
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            ZStack
            {
                RoundedRectangle(cornerRadius: 12)
                    .fill(widget.backgroundColor.color.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: widget.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                if isSelected
                {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 80, height: 80)
                }
            }
            
            Text(widget.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
    }
}
