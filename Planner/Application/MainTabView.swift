//
//  MainTabView.swift
//  Planner
//
//  Created by Assistant on 8/15/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Planner View
            ContentView()
                .tabItem {
                    Image(systemName: "text.rectangle.page")
                    Text("Planner")
                }
                .tag(0)
            
            // To Do View
            ToDoView()
                .tabItem {
                    Image(systemName: "checklist.unchecked")
                    Text("To Do")
                }
                .tag(1)
            
            // Settings View
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(Color("AccentColor"))
    }
}
