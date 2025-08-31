//
//  AddHabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/30/25.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @State private var habitName = ""
    @State private var startDate = Date()
    @State private var frequency: Frequency = .everyDay
    @State private var endRepeatOption: EndRepeatOption = .never
    @State private var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var customFrequencyConfig: CustomFrequencyConfig?
    @State private var showingCustomFrequencyPicker = false
    
    let onAdd: (Habit) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Habit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Create a new habit to track")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Form
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            TextField("Habit name", text: $habitName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("Start Date")
                                Spacer()
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            HStack {
                                Text("Frequency")
                                Spacer()
                                Picker("", selection: $frequency) {
                                    ForEach(Frequency.allCases) { frequency in
                                        Text(frequency.displayName).tag(frequency)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // Show custom frequency configuration button
                            if frequency == .custom {
                                Button(action: {
                                    if customFrequencyConfig == nil {
                                        customFrequencyConfig = CustomFrequencyConfig()
                                    }
                                    showingCustomFrequencyPicker = true
                                }) {
                                    HStack {
                                        Text("Configure Custom Frequency")
                                        Spacer()
                                        if let config = customFrequencyConfig {
                                            Text(config.displayDescription())
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                            
                            // Show end repeat options when frequency is not "Never"
                            if frequency != .never {
                                HStack {
                                    Text("End Repeat")
                                    Spacer()
                                    Picker("", selection: $endRepeatOption) {
                                        ForEach(EndRepeatOption.allCases) { option in
                                            Text(option.displayName).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                                
                                // Show date picker when "On Date" is selected
                                if endRepeatOption == .onDate {
                                    HStack {
                                        Text("End Date")
                                        Spacer()
                                        DatePicker("", selection: $endRepeatDate, displayedComponents: .date)
                                            .labelsHidden()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.primary.colorInvert())
                        .cornerRadius(12)
                        
                        Button("Add Habit") {
                            addHabit()
                        }
                        .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: frequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                endRepeatOption = .never
            }
            // Initialize or clear custom config based on frequency
            if newFrequency == .custom {
                if customFrequencyConfig == nil {
                    customFrequencyConfig = CustomFrequencyConfig()
                }
            } else {
                customFrequencyConfig = nil
            }
        }
        .sheet(isPresented: $showingCustomFrequencyPicker) {
            if customFrequencyConfig != nil {
                CustomFrequencyPickerView(
                    customConfig: Binding(
                        get: { customFrequencyConfig ?? CustomFrequencyConfig() },
                        set: { newConfig in
                            customFrequencyConfig = newConfig
                        }
                    ),
                    endRepeatOption: $endRepeatOption,
                    endRepeatDate: $endRepeatDate
                )
            }
        }
    }
    
    private func addHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            let newHabit = Habit(
                name: trimmedName,
                frequency: frequency,
                completion: [:],
                startDate: startDate,
                endRepeatOption: endRepeatOption,
                endRepeatDate: endRepeatDate,
                customFrequencyConfig: customFrequencyConfig
            )
            onAdd(newHabit)
        }
    }
}

#Preview {
    AddHabitView { habit in
        print("Added habit: \(habit.name)")
    }
}
