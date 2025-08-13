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
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 16) {
                    ForEach(routines.indices, id: \.self) { index in
                        Button(action: {
                            selectedRoutineIndex = index
                            withAnimation {
                                showRoutineDetail = true
                            }
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
        }
        .padding()
    }
}

struct RoutineDetailView: View {
    @Binding var routine: Routine
    var dismissAction: (() -> Void)? = nil
    
    var body: some View {
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

            if !routine.items.isEmpty {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("Background"))
                        
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
        BackgroundView()
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", items: ["Wake up", "Brush teeth", "Exercise"]),
                Routine(name: "Evening", icon: "moon.stars.fill", items: ["Read", "Meditate", "Sleep"]),
                Routine(name: "Afternoon", icon: "cloud.sun.fill", items: ["Lunch", "Walk", "Check email"]),
                Routine(name: "Workout", icon: "figure.walk", items: ["Warm up", "Run", "Stretch"])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
