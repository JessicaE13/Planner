//
//  RoutinesView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Routine: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var items: [String]
    // Changed from Set<String> to [String: Set<String>] to track completion per date
    var completedItemsByDate: [String: Set<String>] = [:]
    
    // Helper method to get date key
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Get completed items for a specific date
    func completedItems(for date: Date) -> Set<String> {
        let key = dateKey(for: date)
        return completedItemsByDate[key] ?? []
    }
    
    // Calculate progress for a specific date
    func progress(for date: Date) -> Double {
        guard !items.isEmpty else { return 0 }
        let completed = completedItems(for: date)
        return Double(completed.count) / Double(items.count)
    }
    
    // Toggle item completion for a specific date
    mutating func toggleItem(_ item: String, for date: Date) {
        let key = dateKey(for: date)
        var completedForDate = completedItemsByDate[key] ?? []
        
        if completedForDate.contains(item) {
            completedForDate.remove(item)
        } else {
            completedForDate.insert(item)
        }
        
        completedItemsByDate[key] = completedForDate
    }
    
    // Check if item is completed for a specific date
    func isItemCompleted(_ item: String, for date: Date) -> Bool {
        let completed = completedItems(for: date)
        return completed.contains(item)
    }
}

// MARK: - Create Routine View
struct CreateRoutineView: View {
    @Binding var routines: [Routine]
    @Environment(\.dismiss) private var dismiss
    
    @State private var routineName = ""
    @State private var selectedIcon = "sunrise"
    @State private var routineItems: [String] = [""]
    
    // Available icons for routines
    private let availableIcons = [
        "sunrise", "moon", "figure.walk", "figure.run", "figure.yoga",
        "heart.fill", "book.fill", "music.note", "gamecontroller.fill",
        "cup.and.saucer.fill", "fork.knife", "car.fill", "house.fill",
        "laptopcomputer", "phone.fill", "camera.fill", "paintbrush.fill"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").opacity(0.2)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Routine Details")) {
                        HStack {
                            Image(systemName: selectedIcon)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            TextField("Routine Name", text: $routineName)
                        }
                        
                        // Icon Picker
                        VStack(alignment: .leading) {
                            Text("Choose Icon")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                    }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                                            .frame(width: 40, height: 40)
                                            .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("Routine Items")) {
                        ForEach(routineItems.indices, id: \.self) { index in
                            HStack {
                                TextField("Item \(index + 1)", text: $routineItems[index])
                                
                                if routineItems.count > 1 {
                                    Button(action: {
                                        routineItems.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        Button(action: {
                            routineItems.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Add Item")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .disabled(routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveRoutine() {
        let trimmedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredItems = routineItems.compactMap { item in
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        
        guard !trimmedName.isEmpty, !filteredItems.isEmpty else { return }
        
        let newRoutine = Routine(
            name: trimmedName,
            icon: selectedIcon,
            items: filteredItems,
            completedItemsByDate: [:]
        )
        
        routines.append(newRoutine)
        dismiss()
    }
}

struct RoutineView: View {
    var selectedDate: Date
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    @State private var showCreateRoutine = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    // Computed binding for sheet presentation
    private var showSheet: Binding<Bool> {
        Binding(
            get: { selectedRoutineIndex != nil },
            set: { isPresented in
                if !isPresented {
                    selectedRoutineIndex = nil
                    showRoutineDetail = false
                }
            }
        )
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
            .padding(.bottom, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 16) {
                    ForEach(routines.indices, id: \.self) { index in
                        Button(action: {
                            selectedRoutineIndex = index
                            showRoutineDetail = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Background").opacity(0.75))
                                    .frame(width: 164, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routines[index].name)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .kerning(1)
                                                .foregroundColor(.primary)
                                               
                                            Text("Routine")
                                                .font(.system(size: 10, weight: .regular, design: .default))
                                                .kerning(1)
                                                .textCase(.uppercase)
                                                .foregroundColor(.primary.opacity(0.75))
                                             
                                        }
                                        Spacer()
                                        
                                        Image(systemName: routines[index].icon)
                                            .frame(width: 36, height: 36)
                                            .font(.largeTitle)
                                            .foregroundColor(Color(UIColor.lightGray).opacity(0.25))
                                
                                    }
                                    .padding(.horizontal, 8)
                                    
                                    // Updated to use progress for specific date
                                    ProgressView(value: routines[index].progress(for: selectedDate), total: 1.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                                        .scaleEffect(y: 1.5) // Makes the progress bar taller
                                        .padding(.top, 8)
                                        .animation(.easeInOut(duration: 0.3), value: routines[index].progress(for: selectedDate))
                                }
                                .frame(width: 136)
                            }
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
        .sheet(isPresented: showSheet) {
            if let index = selectedRoutineIndex {
                RoutineDetailBottomSheetView(
                    routine: $routines[index],
                    selectedDate: selectedDate
                )
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
        }
        .sheet(isPresented: $showCreateRoutine) {
            CreateRoutineView(routines: $routines)
        }
    }
}

// Updated Bottom Sheet View for Routine Details with date support
struct RoutineDetailBottomSheetView: View {
    @Binding var routine: Routine
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").opacity(0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: routine.icon)
                            .font(.system(size: 48))
                            .foregroundColor(.primary)
                        
                        Text(routine.name + " Routine")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Progress view with animation for selected date
                        ProgressView(value: routine.progress(for: selectedDate), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                            .scaleEffect(y: 1.5) // Makes the progress bar taller
                            .frame(maxWidth: 200)
                            .animation(.easeInOut(duration: 0.3), value: routine.progress(for: selectedDate))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)

                    // Routine Items List
                    if !routine.items.isEmpty {
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                
                                VStack(spacing: 0) {
                                    ForEach(routine.items.indices, id: \.self) { index in
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                routine.toggleItem(routine.items[index], for: selectedDate)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: routine.isItemCompleted(routine.items[index], for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(routine.isItemCompleted(routine.items[index], for: selectedDate) ? .primary : .gray)
                                                    .animation(.easeInOut(duration: 0.3), value: routine.isItemCompleted(routine.items[index], for: selectedDate))
                                                
                                                Text(routine.items[index])
                                                    .strikethrough(routine.isItemCompleted(routine.items[index], for: selectedDate))
                                                    .foregroundColor(routine.isItemCompleted(routine.items[index], for: selectedDate) ? .secondary : .primary)
                                                    .animation(.easeInOut(duration: 0.3), value: routine.isItemCompleted(routine.items[index], for: selectedDate))
                                                
                                                Spacer()
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if index < routine.items.count - 1 {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Spacer()
                    
                    // Done Button
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color("Color1").opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Keep the old RoutineDetailView for reference/backup
struct RoutineDetailView: View {
    @Binding var routine: Routine
    let selectedDate: Date
    var dismissAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
  
            ZStack {
                VStack (spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismissAction?() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(12)
                    }
                    .padding()
                }
                
                VStack(spacing: 16) {
                    Image(systemName: routine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.primary)
                    
                    Text(routine.name + " Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Updated to use progress for specific date
                    ProgressView(value: routine.progress(for: selectedDate), total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                        .scaleEffect(y: 1.5) // Makes the progress bar taller
                        .frame(maxWidth: 200)
                        .animation(.easeInOut(duration: 0.3), value: routine.progress(for: selectedDate))
                }
            }
            }
            .padding(.top, 24)
            .padding(.bottom, 32)

            if !routine.items.isEmpty {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("Background"))
                        
                        VStack(spacing: 0) {
                            ForEach(routine.items.indices, id: \.self) { index in
                                Button(action: {
                                    // Use withAnimation to synchronize all visual changes
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        routine.toggleItem(routine.items[index], for: selectedDate)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: routine.isItemCompleted(routine.items[index], for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(routine.isItemCompleted(routine.items[index], for: selectedDate) ? .primary : .gray)
                                            .animation(.easeInOut(duration: 0.3), value: routine.isItemCompleted(routine.items[index], for: selectedDate))
                                        
                                        Text(routine.items[index])
                                            .strikethrough(routine.isItemCompleted(routine.items[index], for: selectedDate))
                                            .foregroundColor(routine.isItemCompleted(routine.items[index], for: selectedDate) ? .secondary : .primary)
                                            .animation(.easeInOut(duration: 0.3), value: routine.isItemCompleted(routine.items[index], for: selectedDate))
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if index < routine.items.count {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            Button("Done") {
                dismissAction?()
            }
            .font(.headline)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color("Color1").opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    ZStack {
       // BackgroundView()
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", items: ["Wake up", "Brush teeth", "Exercise"]),
                Routine(name: "Evening", icon: "moon.stars.fill", items: ["Read", "Meditate", "Sleep"]),
                Routine(name: "Afternoon", icon: "cloud.sun_fill", items: ["Lunch", "Walk", "Check email"]),
                Routine(name: "Workout", icon: "figure.walk", items: ["Warm up", "Run", "Stretch"])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
