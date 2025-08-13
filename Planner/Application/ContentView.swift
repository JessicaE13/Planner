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
        Routine(name: "Morning", icon: "sunrise", items: ["Brush teeth", "Shower", "Make bed", "Breakfast"]),
        Routine(name: "Evening", icon: "moon", items: ["Dinner", "Read book", "Skincare", "Set alarm"])
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
           
            if showRoutineDetail, let index = selectedRoutineIndex {
                Group {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showRoutineDetail = false
                            }
                        }
                    VStack {
                        RoutineDetailView(routine: $routines[index], dismissAction: {
                            withAnimation {
                                showRoutineDetail = false
                            }
                        })
                    }
                    .frame(maxWidth: 350)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 20)
                    )
                    .padding(.horizontal, 32)
                    .transition(.blurReplace)
                }
                .zIndex(1)
            }
        }
        .animation(nil, value: showRoutineDetail)
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
    }
}


extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}
