//
//  MainTabView.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/20/25.
//

import SwiftUI

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
            
            SearchView()
                .tabItem
                {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            CreateView()
                .tabItem
                {
                    Image(systemName: selectedTab == 2 ? "plus.square.fill" : "plus.square")
                    Text("Create")
                }
                .tag(2)
            
            PreviewView(
                viewManager: viewManager,
                currentViewIndex: $currentViewIndex,
                isDarkMode: $isDarkMode
            )
                .tabItem
                {
                    Image(systemName: selectedTab == 3 ? "iphone.landscape" : "iphone.landscape")
                    Text("Preview")
                }
                .tag(3)
            
            ProfileView(viewManager: viewManager)
                .tabItem
                {
                    Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.primary)
        .environmentObject(viewManager) // Provide ViewManager to all child views
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
            // Initialize orientation and load saved settings
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
        
        // Ensure currentViewIndex is within bounds
        if currentViewIndex >= viewManager.widgetViews.count
        {
            currentViewIndex = 0
            persistenceManager.saveCurrentViewIndex(0)
        }
        
        print("📱 Loaded settings: viewIndex=\(currentViewIndex), darkMode=\(isDarkMode)")
    }
}

// Updated placeholder views
struct CreateView: View
{
    var body: some View
    {
        NavigationView
        {
            Text("Create View")
                .navigationTitle("Create")
        }
    }
}
