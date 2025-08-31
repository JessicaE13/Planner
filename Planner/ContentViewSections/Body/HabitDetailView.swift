//
//  HabitDetailView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    var habitManager: HabitDataManager
    var onDelete: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habit.name)
                        .onChange(of: habit.name) { _, _ in
                            habitManager.updateHabit(habit)
                        }
                    
                    HStack {
                        Text("Start Date")
                        Spacer()
                        DatePicker("", selection: $habit.startDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .onChange(of: habit.startDate) { _, _ in
                        habitManager.updateHabit(habit)
                    }
                    
                    Picker("Frequency", selection: $habit.frequency) {
                        ForEach(Frequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .onChange(of: habit.frequency) { _, _ in
                        habitManager.updateHabit(habit)
                    }
                    
                    // Show end repeat options when frequency is not "Never"
                    if habit.frequency != .never {
                        HStack {
                            Text("End Repeat")
                            Spacer()
                            Picker("", selection: $habit.endRepeatOption) {
                                ForEach(EndRepeatOption.allCases) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .onChange(of: habit.endRepeatOption) { _, _ in
                            habitManager.updateHabit(habit)
                        }
                        
                        // Show date picker when "On Date" is selected
                        if habit.endRepeatOption == .onDate {
                            HStack {
                                Text("End Date")
                                Spacer()
                                DatePicker("", selection: $habit.endRepeatDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .onChange(of: habit.endRepeatDate) { _, _ in
                                habitManager.updateHabit(habit)
                            }
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
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: habit.frequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                habit.endRepeatOption = .never
                habitManager.updateHabit(habit)
            }
        }
    }
}