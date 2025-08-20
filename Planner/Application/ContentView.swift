//
//  ContentView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showRoutineDetail = false
    @State private var selectedRoutineIndex: Int? = nil
    @State private var routines = [
        // Initialize with start dates from a week ago so they show in past days
        Routine(
            name: "Morning",
            icon: "sunrise",
            routineItems: [
                RoutineItem(name: "Brush teeth", frequency: .everyDay),
                RoutineItem(name: "Shower", frequency: .everyDay),
                RoutineItem(name: "Make bed", frequency: .everyDay),
                RoutineItem(name: "Breakfast", frequency: .everyDay)
            ],
            items: [], // Keep empty for new format
            colorName: "Color1",
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        ),
        Routine(
            name: "Evening",
            icon: "moon",
            routineItems: [
                RoutineItem(name: "Dinner", frequency: .everyDay),
                RoutineItem(name: "Read book", frequency: .everyDay),
                RoutineItem(name: "Skincare", frequency: .everyDay),
                RoutineItem(name: "Set alarm", frequency: .everyDay)
            ],
            items: [], // Keep empty for new format
            colorName: "Color2",
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        )
    ]
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack (spacing: 0) {
                HeaderView(selectedDate: $selectedDate)
              
                ScrollView {
                    VStack {
                        RoutineView(
                            selectedDate: selectedDate,
                            routines: $routines,
                            showRoutineDetail: $showRoutineDetail,
                            selectedRoutineIndex: $selectedRoutineIndex
                        )
                        
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
    MainTabView()
}

#Preview {
    ContentView()
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .regular, design: .default))
            .kerning(1)
            .textCase(.uppercase)
            .foregroundColor(.primary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}
