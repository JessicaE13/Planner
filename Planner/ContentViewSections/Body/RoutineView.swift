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
    var completedItems: Set<String> = []
    
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedItems.count) / Double(items.count)
    }
    
    mutating func toggleItem(_ item: String) {
        if completedItems.contains(item) {
            completedItems.remove(item)
        } else {
            completedItems.insert(item)
        }
    }
}

struct RoutineView: View {
    var selectedDate: Date
    @State private var showRoutineDetail = false
    @State private var selectedRoutine: Routine? = nil
    @State private var routines = [
        Routine(name: "Morning", icon: "sunrise", items: ["Brush teeth", "Shower", "Make bed", "Breakfast"]),
        Routine(name: "Evening", icon: "moon", items: ["Dinner", "Read book", "Skincare", "Set alarm"])
    ]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Routines")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 16)
            
            HStack (spacing: 16) {
                ForEach(routines.indices, id: \.self) { index in
                    Button(action: {
                        selectedRoutine = routines[index]
                        showRoutineDetail = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 150, height: 100)
                            VStack {
                                HStack {
                                    Image(systemName: routines[index].icon)
                                        .font(.largeTitle)
                                        
                                    VStack(alignment: .leading) {
                                        Text(routines[index].name)
                                            .font(.body)
                                        Text("Routine")
                                            .font(.caption)
                                    }
                                }
                                ProgressView(value: routines[index].progress, total: 1.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                                    .frame(width: 124)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(isPresented: $showRoutineDetail) {
            if let routine = selectedRoutine,
               let index = routines.firstIndex(where: { $0.id == routine.id }) {
                RoutineDetailView(routine: $routines[index])
            }
        }
    }
    
    private func progressForDate(_ date: Date) -> Double {
        // Example: Different progress based on day of week
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        return Double(dayOfWeek) / 7.0
    }
}

struct RoutineDetailView: View {
    @Binding var routine: Routine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with icon and name
                VStack(spacing: 16) {
                    Image(systemName: routine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.primary)
                    
                    Text(routine.name + " Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ProgressView(value: routine.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                        .frame(maxWidth: 200)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Routine items list
                if !routine.items.isEmpty {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            VStack(spacing: 0) {
                                ForEach(routine.items.indices, id: \.self) { index in
                                    Button(action: {
                                        routine.toggleItem(routine.items[index])
                                    }) {
                                        HStack {
                                            Image(systemName: routine.completedItems.contains(routine.items[index]) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(routine.completedItems.contains(routine.items[index]) ? .primary : .gray)
                                            
                                            Text(routine.items[index])
                                                .strikethrough(routine.completedItems.contains(routine.items[index]))
                                                .foregroundColor(routine.completedItems.contains(routine.items[index]) ? .secondary : .primary)
                                            
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
            }
            .background(Color("Background"))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        RoutineView(selectedDate: Date())
    }
}
