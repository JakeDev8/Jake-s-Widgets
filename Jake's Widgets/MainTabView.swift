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
    
    var body: some View
    {
        TabView(selection: $selectedTab)
        {
            HomeView()
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
            
            PreviewView()
                .tabItem
                {
                    Image(systemName: selectedTab == 3 ? "iphone.landscape" : "iphone.landscape")
                    Text("Preview")
                }
                .tag(3)
            
            ProfileView()
                .tabItem
                {
                    Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.primary)
    }
}

// You'll need to create these individual views
//struct HomeView: View
//{
//    var body: some View
//    {
//        NavigationView
//        {
//            Text("Home")
//                .navigationTitle("Home")
//        }
//    }
//}

struct SearchView: View
{
    var body: some View
    {
        NavigationView
        {
            Text("Search")
                .navigationTitle("Search")
        }
    }
}

struct CreateView: View
{
    var body: some View
    {
        NavigationView
        {
            Text ("Create View")
                .navigationTitle("Create")
        }
    }
}

//struct PreviewView: View
//{
//    var body: some View
//    {
//        NavigationView
//        {
//            Text ("Preview Mode")
//                .navigationTitle("Activity")
//        }
//    }
//}

//struct ProfileView: View
//{
//    var body: some View
//    {
//        NavigationView
//        {
//            Text ("My Widgets")
//                .navigationTitle("Profile")
//        }
//    }
//}
