import SwiftUI

struct RoutineView: View {
    var selectedDate: Date
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    @State private var showCreateRoutine = false
    @State private var editingRoutine: Routine?
    @State private var editingRoutineIndex: Int?
    @State private var showingRoutineDetail: Routine?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    private var visibleRoutines: [(routine: Routine, index: Int)] {
        return routines.enumerated().compactMap { index, routine in
            if routine.shouldAppear(on: selectedDate) {
                return (routine: routine, index: index)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Routines")
                    .sectionHeaderStyle()
                Spacer()
                Button(action: {
                    showCreateRoutine = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 24) {
                    ForEach(visibleRoutines.indices, id: \.self) { idx in
                        let routineData = visibleRoutines[idx]
                        Button(action: {
                            showingRoutineDetail = routineData.routine
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 176, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routineData.routine.name)
                                                .font(.title3)
                                                .kerning(0.5)
                                                .foregroundColor(.primary)
                                            Text("Routine")
                                                .font(.caption2)
                                                .textCase(.uppercase)
                                                .foregroundColor(.primary.opacity(0.75))
                                        }
                                        Spacer()
                                        Image(systemName: routineData.routine.icon)
                                            .frame(width: 36, height: 36)
                                            .font(.largeTitle)
                                            .foregroundColor(Color(routineData.routine.color).opacity(0.75))
                                    }
                                    .padding(.horizontal, 8)
                                   
                                    ProgressView(value: routineData.routine.progress(for: selectedDate), total: 1.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color(routineData.routine.color)))
                                        .scaleEffect(y: 1.5)
                                        .padding(.top, 8)
                                        .animation(.easeInOut(duration: 0.3), value: routineData.routine.progress(for: selectedDate))
                                }
                                .frame(width: 144)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                       // .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .padding(.leading, idx == 0 ? 36 : 0)
                        .padding(.trailing, idx == visibleRoutines.count - 1 ? 16 : 0)
                    }
                }
            }
        }
        .sheet(item: $showingRoutineDetail) { routine in
            if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                NavigationView {
                    RoutineDetailBottomSheetView(
                        routine: $routines[index],
                        selectedDate: selectedDate
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                // Don't save any changes - just dismiss
                                showingRoutineDetail = nil
                            }
                        }
                    })
                }
            }
        }
        .sheet(isPresented: $showCreateRoutine) {
            CreateRoutineView()
        }
        .sheet(isPresented: Binding(
            get: { editingRoutine != nil },
            set: { isPresented in
                if !isPresented {
                    editingRoutine = nil
                    editingRoutineIndex = nil
                }
            }
        )) {
            if let routine = editingRoutine, let editIndex = editingRoutineIndex {
                CreateRoutineView(
                    editingRoutine: routine,
                    editingIndex: editIndex
                )
                .onDisappear {
                    editingRoutine = nil
                    editingRoutineIndex = nil
                }
            }
        }
        .onAppear {
            updateDefaultRoutinesStartDate()
            migrateRoutines()
        }
    }
    
    private func updateDefaultRoutinesStartDate() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        for index in routines.indices {
            if Calendar.current.isDate(routines[index].startDate, inSameDayAs: Date()) {
                routines[index].startDate = weekAgo
            }
        }
    }
    
    private func migrateRoutines() {
        var needsUpdate = false
        let defaultColors = ["Color1", "Color2", "Color3", "Color4", "Color5", "Color6", "Color7"]
        for index in routines.indices {
            if routines[index].routineItems.isEmpty && !routines[index].items.isEmpty {
                routines[index].routineItems = routines[index].items.map {
                    RoutineItem(name: $0, frequency: .everyDay)
                }
                needsUpdate = true
            }
            if routines[index].colorName.isEmpty {
                routines[index].colorName = defaultColors[index % defaultColors.count]
                needsUpdate = true
            }
        }
        if needsUpdate {
            print("Migrated routines from legacy format and assigned default colors")
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundPopup")
            .ignoresSafeArea()
        
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", routineItems: [
                    RoutineItem(name: "Wake up", frequency: .everyDay),
                    RoutineItem(name: "Brush teeth", frequency: .everyDay),
                    RoutineItem(name: "Exercise", frequency: .everyTwoWeeks)
                ]),
                Routine(name: "Evening", icon: "moon.stars.fill", routineItems: [
                    RoutineItem(name: "Read", frequency: .everyDay),
                    RoutineItem(name: "Meditate", frequency: .everyWeek),
                    RoutineItem(name: "Sleep", frequency: .everyDay)
                ])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
