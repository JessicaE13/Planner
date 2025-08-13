//
//  ContentView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    var body: some View {
        ZStack {
            
            BackgroundView()
            
            VStack (spacing: 0) {
                
                HeaderView(selectedDate: $selectedDate)
              
                ScrollView {
                    VStack {
                        
                        RoutineView(selectedDate: selectedDate)
                        
                        ScheduleView(selectedDate: selectedDate)
                        
                        HabitView(selectedDate: selectedDate)
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


struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .medium, design: .default))
            .kerning(1)
            .textCase(.uppercase)
            .foregroundColor(.primary)
           // .padding(.bottom, 16)
    }
}


extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}
