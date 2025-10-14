import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showRoutineDetail = false
    @State private var selectedRoutineIndex: Int? = nil
    @StateObject private var plannerDataManager = PlannerDataManager.shared
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HeaderView(selectedDate: $selectedDate)
                ScrollView {
                    VStack(spacing: 0) {
                        RoutineView(
                            selectedDate: selectedDate,
                            routines: $plannerDataManager.routines,
                            showRoutineDetail: $showRoutineDetail,
                            selectedRoutineIndex: $selectedRoutineIndex
                        )
               
                        
                        ScheduleView(selectedDate: selectedDate)
                        
                        HabitView(selectedDate: selectedDate)
                    }
                }
            }
        }
        .onAppear {
            Task {
                // Check iCloud status and perform initial sync
                await cloudKitManager.checkiCloudStatus()
                if cloudKitManager.isSignedInToiCloud {
                    do {
                        try await plannerDataManager.performInitialSync()
                    } catch {
                        print("Initial sync failed: \(error)")
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
            .font(.headline)
            .kerning(2)
            .textCase(.uppercase)
            .foregroundColor(.primary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}
