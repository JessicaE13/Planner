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
                    Image(systemName: "calendar")
                    Text("Planner")
                }
                .tag(0)
            
            // Brain Dump View
            BrainDumpView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Brain Dump")
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
