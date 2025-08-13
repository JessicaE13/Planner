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
    var frequency: Frequency = .everyDay
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
    
    func shouldAppear(on date: Date) -> Bool {
        // Use the Frequency enum's shouldTrigger method with a default start date
        let startDate = Date() // You could store this as a property if needed
        return frequency.shouldTrigger(on: date, from: startDate)
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
                ForEach(habits.indices, id: \.self) { index in
                    if habits[index].shouldAppear(on: selectedDate) {
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
                    
                        if index < habits.count - 1 && habits[(index + 1)...].contains(where: { $0.shouldAppear(on: selectedDate) }) {
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                        }
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

struct HabitDetailView: View {
    @Binding var habit: Habit
    var onDelete: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Habit Details")) {
                TextField("Habit Name", text: $habit.name)
                Picker("Frequency", selection: $habit.frequency) {
                    ForEach(Frequency.allCases) { frequency in
                        Text(frequency.displayName).tag(frequency)
                    }
                }
            }
            Section {
                Button("Delete Habit", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ManageHabitsView: View {
    @Binding var habits: [Habit]
    @Environment(\.dismiss) var dismiss
    @State private var newHabitName = ""
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !habits.isEmpty {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            VStack(spacing: 0) {
                                ForEach(habits.indices, id: \.self) { index in
                                    NavigationLink(destination: HabitDetailView(habit: $habits[index], onDelete: {
                                        habits.remove(at: index)
                                    })) {
                                        HStack {
                                            Text(habits[index].name)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .contentShape(Rectangle()) // Make the whole row tappable
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index < habits.count - 1 {
                                        Divider()
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .frame(height: 56)
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
                    .padding(.horizontal)
                }
                .padding(.all, 16)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Manage Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .background(Color(.systemGray6))
    }
}

struct EditableHabitRow: View {
    @Binding var habits: [Habit]
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            HStack {
        
                Picker("", selection: $habits[index].frequency) {
                    ForEach(Frequency.allCases) { frequency in
                        Text(frequency.displayName)
                            .tag(frequency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HabitView(selectedDate: Date())
}
