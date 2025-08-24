import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showRoutineDetail = false
    @State private var selectedRoutineIndex: Int? = nil
    @State private var routines: [Routine] = []
    
    private let routinesKey = "savedRoutines"
    
    init() {
        // Load routines from UserDefaults if available
        if let data = UserDefaults.standard.data(forKey: routinesKey) {
            do {
                let decoded = try JSONDecoder().decode([Routine].self, from: data)
                _routines = State(initialValue: decoded)
                print("Successfully loaded \(decoded.count) routines from UserDefaults")
            } catch {
                print("Failed to decode routines: \(error)")
                // Fall back to default routines if decoding fails
                let defaults = [
                    Routine(
                        name: "Morning",
                        icon: "sunrise",
                        routineItems: [
                            RoutineItem(name: "Brush teeth", frequency: .everyDay),
                            RoutineItem(name: "Shower", frequency: .everyDay),
                            RoutineItem(name: "Make bed", frequency: .everyDay),
                            RoutineItem(name: "Breakfast", frequency: .everyDay)
                        ],
                        items: [],
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
                        items: [],
                        colorName: "Color2",
                        startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                    )
                ]
                _routines = State(initialValue: defaults)
            }
        } else {
            print("No saved routines found, creating defaults")
            // Use default routines only if nothing is saved
            let defaults = [
                Routine(
                    name: "Morning",
                    icon: "sunrise",
                    routineItems: [
                        RoutineItem(name: "Brush teeth", frequency: .everyDay),
                        RoutineItem(name: "Shower", frequency: .everyDay),
                        RoutineItem(name: "Make bed", frequency: .everyDay),
                        RoutineItem(name: "Breakfast", frequency: .everyDay)
                    ],
                    items: [],
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
                    items: [],
                    colorName: "Color2",
                    startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                )
            ]
            _routines = State(initialValue: defaults)
        }
    }
    
    private func saveRoutines() {
        do {
            let data = try JSONEncoder().encode(routines)
            UserDefaults.standard.set(data, forKey: routinesKey)
            print("Successfully saved \(routines.count) routines to UserDefaults")
        } catch {
            print("Failed to encode routines: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            VStack (spacing: 0) {
                HeaderView(selectedDate: $selectedDate)
                ScrollView {
                    VStack(spacing: 0) {
                        RoutineView(
                            selectedDate: selectedDate,
                            routines: $routines,
                            showRoutineDetail: $showRoutineDetail,
                            selectedRoutineIndex: $selectedRoutineIndex
                        )
                        
                        ScheduleView(selectedDate: selectedDate)
                        
                        HabitView(selectedDate: selectedDate)
                    }
                }
            }
        }
        .onChange(of: routines) { _, _ in
            saveRoutines()
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
            .font(.headline)
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
