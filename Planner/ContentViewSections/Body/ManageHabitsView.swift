//
//  ManageHabitsView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ManageHabitsView: View {
    @ObservedObject var habitManager: HabitDataManager
    @Environment(\.dismiss) var dismiss
    @State private var newHabitName = ""
    @State private var newHabitStartDate = Date()
    @State private var newHabitFrequency: Frequency = .everyDay
    @State private var newHabitEndRepeatOption: EndRepeatOption = .never
    @State private var newHabitEndRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !habitManager.habits.isEmpty {
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            VStack(spacing: 0) {
                                ForEach(habitManager.habits.indices, id: \.self) { index in
                                    NavigationLink(destination: HabitDetailView(
                                        habit: .constant(habitManager.habits[index]),
                                        habitManager: habitManager,
                                        onDelete: {
                                            habitManager.deleteHabit(at: index)
                                        }
                                    )) {
                                        HStack {
                                            Text(habitManager.habits[index].name)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if index < habitManager.habits.count - 1 {
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
                
                // Enhanced Add New Habit Form
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        VStack(spacing: 12) {
                            TextField("New Habit", text: $newHabitName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("Start Date")
                                Spacer()
                                DatePicker("", selection: $newHabitStartDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            HStack {
                                Text("Frequency")
                                Spacer()
                                Picker("", selection: $newHabitFrequency) {
                                    ForEach(Frequency.allCases) { frequency in
                                        Text(frequency.displayName).tag(frequency)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // Show end repeat options when frequency is not "Never"
                            if newHabitFrequency != .never {
                                HStack {
                                    Text("End Repeat")
                                    Spacer()
                                    Picker("", selection: $newHabitEndRepeatOption) {
                                        ForEach(EndRepeatOption.allCases) { option in
                                            Text(option.displayName).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                                
                                // Show date picker when "On Date" is selected
                                if newHabitEndRepeatOption == .onDate {
                                    HStack {
                                        Text("End Date")
                                        Spacer()
                                        DatePicker("", selection: $newHabitEndRepeatDate, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                }
                            }
                            
                            Button("Add Habit") {
                                addNewHabit()
                            }
                            .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .padding(.all, 16)
            }
            .background(Color("Background"))
            .navigationTitle("Manage Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .background(Color("Background"))
        .onChange(of: newHabitFrequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                newHabitEndRepeatOption = .never
            }
        }
    }
    
    private func addNewHabit() {
        let trimmedName = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            let newHabit = Habit(
                name: trimmedName,
                frequency: newHabitFrequency,
                completion: [:],
                startDate: newHabitStartDate,
                endRepeatOption: newHabitEndRepeatOption,
                endRepeatDate: newHabitEndRepeatDate
            )
            habitManager.addHabit(newHabit)
            
            // Reset form
            newHabitName = ""
            newHabitStartDate = Date()
            newHabitFrequency = .everyDay
            newHabitEndRepeatOption = .never
            newHabitEndRepeatDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        }
    }
}