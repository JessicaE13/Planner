
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
            items: ["Brush teeth", "Shower", "Make bed", "Breakfast"],
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        ),
        Routine(
            name: "Evening",
            icon: "moon",
            items: ["Dinner", "Read book", "Skincare", "Set alarm"],
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
