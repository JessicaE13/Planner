//
//  SettingsView.swift
//  Planner
//
//  Created by Jessica Estes on 8/12/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        
        VStack {
            
            Text("Settings")
                .font(.title)
            
            List {
                Text("Account")
                Text("Notifications")
            }
        }
    }
}

#Preview {
    SettingsView()
}
