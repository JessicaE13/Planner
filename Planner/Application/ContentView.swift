import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showRoutineDetail = false
    @State private var selectedRoutineIndex: Int? = nil
    @StateObject private var plannerDataManager = PlannerDataManager.shared
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var healthAuthorizationRequested = false
    
    var body: some View {
        ZStack {
//            Color("BackgroundPopup")
//                .ignoresSafeArea()
            
            VStack (spacing: 0) {
                HeaderView(selectedDate: $selectedDate)
                VStack(spacing: 4) {
                    Text("Steps today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(healthKitManager.todayStepCount.formatted())")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 8)
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

                // Request HealthKit authorization once and fetch today's steps
                if !healthAuthorizationRequested {
                    do {
                        try await healthKitManager.requestAuthorization()
                        try await healthKitManager.fetchTodaySteps()
                        healthAuthorizationRequested = true
                    } catch {
                        print("HealthKit auth/fetch failed: \(error)")
                    }
                } else {
                    // Refresh steps on subsequent appears
                    do {
                        try await healthKitManager.fetchTodaySteps()
                    } catch {
                        print("Fetching steps failed: \(error)")
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
            .font(.title)
            .fontWeight(.semibold)
            //.kerning(2)
            //.textCase(.uppercase)
            .foregroundColor(.primary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}

