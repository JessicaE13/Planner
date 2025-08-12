//
//  ContentView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            
            BackgroundView()
            
            VStack (spacing: 0) {
                
                TopRowView()
                HeaderView()
                Divider()
                    .background(Color.gray.opacity(0.5))
              
                ScrollView {
                    VStack {
                        
                        RoutineView()
                        
                        ScheduleView()
                        
                        HabitView()
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
