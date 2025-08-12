//
//  HabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var completion: [String: Bool] // date string (yyyy-MM-dd) to completion status
    
    func isCompleted(for date: Date) -> Bool {
        let key = Habit.dateKey(for: date)
        return completion[key] ?? false
    }
    
    mutating func toggle(for date: Date) {
        let key = Habit.dateKey(for: date)
        completion[key] = !(completion[key] ?? false)
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct HabitView: View {
    @State private var habits = [
        Habit(name: "Habit 1", completion: [:]),
        Habit(name: "Habit 2", completion: [:]),
        Habit(name: "Habit 3", completion: [:]),
        Habit(name: "Habit 4", completion: [:]),
        Habit(name: "Habit 5", completion: [:])
    ]
    var selectedDate: Date
    @State private var showManageHabits = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Habits")
                    .sectionHeaderStyle()
                Spacer()
                Button(action: {
                    showManageHabits = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 24)
            
            VStack(spacing: 0) {
                ForEach(habits.indices, id: \ .self) { index in
                    Button(action: {
                        habits[index].toggle(for: selectedDate)
                    }) {
                        HStack {
                            Image(systemName: habits[index].isCompleted(for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habits[index].isCompleted(for: selectedDate) ? .primary : .gray)
                            Text(habits[index].name)
                                .strikethrough(habits[index].isCompleted(for: selectedDate))
                                .foregroundColor(habits[index].isCompleted(for: selectedDate) ? .secondary : .primary)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                
                    if index < habits.count {
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.leading, 16)
        
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showManageHabits) {
            ManageHabitsView(habits: $habits)
        }
    }
}

struct ManageHabitsView: View {
    @Binding var habits: [Habit]
    @Environment(\.dismiss) var dismiss
    @State private var newHabitName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(habits.indices, id: \.self) { index in
                        EditableHabitRow(habits: $habits, index: index)
                    }
                }
                
                HStack {
                    TextField("New Habit", text: $newHabitName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !newHabitName.isEmpty {
                            habits.append(Habit(name: newHabitName, completion: [:]))
                            newHabitName = ""
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Manage Habits")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct EditableHabitRow: View {
    @Binding var habits: [Habit]
    let index: Int
    
    var body: some View {
        HStack {
            TextField("Habit Name", text: $habits[index].name)
            Spacer()
            Button(action: {
                habits.remove(at: index)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    HabitView(selectedDate: Date())
}
