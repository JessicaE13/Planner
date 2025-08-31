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
    @State private var showingSavedConfirmation = false
    @State private var showingCustomFrequencyPicker = false
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habit.name)
                        .onChange(of: habit.name) { _, _ in
                            habitManager.updateHabit(habit)
                            showSavedConfirmation()
                        }
                    
                    HStack {
                        Text("Start Date")
                        Spacer()
                        DatePicker("", selection: $habit.startDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .onChange(of: habit.startDate) { _, _ in
                        habitManager.updateHabit(habit)
                        showSavedConfirmation()
                    }
                    
                    Picker("Frequency", selection: $habit.frequency) {
                        ForEach(Frequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .onChange(of: habit.frequency) { _, newFrequency in
                        if newFrequency == .custom {
                            // Initialize custom config if it doesn't exist
                            if habit.customFrequencyConfig == nil {
                                habit.customFrequencyConfig = CustomFrequencyConfig()
                            }
                            showingCustomFrequencyPicker = true
                        } else {
                            // Clear custom config for non-custom frequencies
                            habit.customFrequencyConfig = nil
                        }
                        habitManager.updateHabit(habit)
                        showSavedConfirmation()
                    }
                    
                    // Show custom frequency configuration button
                    if habit.frequency == .custom {
                        Button(action: {
                            if habit.customFrequencyConfig == nil {
                                habit.customFrequencyConfig = CustomFrequencyConfig()
                            }
                            showingCustomFrequencyPicker = true
                        }) {
                            HStack {
                                Text("Configure Custom Frequency")
                                Spacer()
                                if let config = habit.customFrequencyConfig {
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
                    
                    // Show frequency explanation
                    if habit.frequency != .never {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This habit will appear on:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getFrequencyExplanation())
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
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
                            showSavedConfirmation()
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
                                showSavedConfirmation()
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
            
            // Saved confirmation overlay
            if showingSavedConfirmation {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Changes saved")
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.secondary.colorInvert())
                    .cornerRadius(20)
                    .shadow(radius: 2)
                    .padding(.bottom, 100)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3), value: showingSavedConfirmation)
            }
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
        .sheet(isPresented: $showingCustomFrequencyPicker) {
            if habit.customFrequencyConfig != nil {
                CustomFrequencyPickerView(
                    customConfig: Binding(
                        get: { habit.customFrequencyConfig ?? CustomFrequencyConfig() },
                        set: { newConfig in
                            habit.customFrequencyConfig = newConfig
                            habitManager.updateHabit(habit)
                            showSavedConfirmation()
                        }
                    ),
                    endRepeatOption: $habit.endRepeatOption,
                    endRepeatDate: $habit.endRepeatDate
                )
            }
        }
    }
    
    private func showSavedConfirmation() {
        showingSavedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingSavedConfirmation = false
        }
    }
    
    private func getFrequencyExplanation() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Day name
        
        switch habit.frequency {
        case .never:
            return "Only on \(DateFormatter.localizedString(from: habit.startDate, dateStyle: .medium, timeStyle: .none))"
        case .everyDay:
            return "Every day starting from \(DateFormatter.localizedString(from: habit.startDate, dateStyle: .medium, timeStyle: .none))"
        case .everyWeek:
            let dayName = formatter.string(from: habit.startDate)
            return "Every \(dayName) starting from \(DateFormatter.localizedString(from: habit.startDate, dateStyle: .medium, timeStyle: .none))"
        case .everyTwoWeeks:
            let dayName = formatter.string(from: habit.startDate)
            return "Every other \(dayName) starting from \(DateFormatter.localizedString(from: habit.startDate, dateStyle: .medium, timeStyle: .none))"
        case .everyMonth:
            let day = Calendar.current.component(.day, from: habit.startDate)
            let suffix = getDaySuffix(day)
            return "On the \(day)\(suffix) of each month starting from \(DateFormatter.localizedString(from: habit.startDate, dateStyle: .medium, timeStyle: .none))"
        case .everyYear:
            let monthDay = DateFormatter.localizedString(from: habit.startDate, dateStyle: .long, timeStyle: .none)
            return "Every year on \(monthDay)"
        case .custom:
            if let config = habit.customFrequencyConfig {
                return config.displayDescription()
            }
            return "Custom frequency - tap to configure"
        }
    }
    
    private func getDaySuffix(_ day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
