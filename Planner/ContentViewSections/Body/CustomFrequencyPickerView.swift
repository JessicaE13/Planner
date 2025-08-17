//
//  CustomFrequencyPickerView.swift
//  Planner
//
//  Custom frequency picker for schedule events
//

import SwiftUI

struct CustomFrequencyPickerView: View {
    @Binding var customConfig: CustomFrequencyConfig
    @Binding var endRepeatOption: EndRepeatOption
    @Binding var endRepeatDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Frequency Type Picker
                Section(header: Text("Frequency Type")) {
                    HStack {
                        Text("Repeats")
                        
                        Spacer()
                        
                        Picker("", selection: $customConfig.type) {
                            ForEach(CustomFrequencyType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Interval Section
                Section(header: Text("Interval")) {
                    HStack {
                        Text("Every")
                        
                        Stepper(value: $customConfig.interval, in: 1...99) {
                            TextField("Interval", value: $customConfig.interval, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                                .keyboardType(.numberPad)
                        }
                        
                        Text(intervalLabel)
                    }
                }
                
                // Type-specific selections
                switch customConfig.type {
                case .daily:
                    EmptyView() // No additional options for daily
                    
                case .weekly:
                    WeeklySelectionSection(selectedWeekdays: $customConfig.selectedWeekdays)
                    
                case .monthly:
                    MonthlySelectionSection(selectedMonthDays: $customConfig.selectedMonthDays)
                    
                case .yearly:
                    YearlySelectionSection(selectedMonths: $customConfig.selectedMonths)
                }
                
                // End Repeat Section
                Section(header: Text("End Repeat")) {
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
                
                // Preview Section
                Section(header: Text("Preview")) {
                    Text("Repeats \(customConfig.displayDescription().lowercased())")
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Custom Frequency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: customConfig.type) { _, newType in
            // Reset selections when type changes and set defaults
            customConfig.selectedWeekdays = []
            customConfig.selectedMonthDays = []
            customConfig.selectedMonths = []
            
            switch newType {
            case .daily:
                break // No defaults needed
            case .weekly:
                customConfig.selectedWeekdays = [Calendar.current.component(.weekday, from: Date())]
            case .monthly:
                customConfig.selectedMonthDays = [Calendar.current.component(.day, from: Date())]
            case .yearly:
                customConfig.selectedMonths = [Calendar.current.component(.month, from: Date())]
            }
        }
    }
    
    private var intervalLabel: String {
        switch customConfig.type {
        case .daily:
            return customConfig.interval == 1 ? "day" : "days"
        case .weekly:
            return customConfig.interval == 1 ? "week" : "weeks"
        case .monthly:
            return customConfig.interval == 1 ? "month" : "months"
        case .yearly:
            return customConfig.interval == 1 ? "year" : "years"
        }
    }
}

// MARK: - Weekly Selection Section
struct WeeklySelectionSection: View {
    @Binding var selectedWeekdays: Set<Int>
    
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        Section(header: Text("Days of the Week")) {
            HStack {
                ForEach(1...7, id: \.self) { dayNumber in
                    Button(action: {
                        if selectedWeekdays.contains(dayNumber) {
                            selectedWeekdays.remove(dayNumber)
                        } else {
                            selectedWeekdays.insert(dayNumber)
                        }
                    }) {
                        Text(weekdaySymbols[dayNumber - 1])
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 40, height: 40)
                            .background(selectedWeekdays.contains(dayNumber) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedWeekdays.contains(dayNumber) ? .white : .primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Monthly Selection Section
struct MonthlySelectionSection: View {
    @Binding var selectedMonthDays: Set<Int>
    
    var body: some View {
        Section(header: Text("Days of the Month")) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(1...31, id: \.self) { day in
                    Button(action: {
                        if selectedMonthDays.contains(day) {
                            selectedMonthDays.remove(day)
                        } else {
                            selectedMonthDays.insert(day)
                        }
                    }) {
                        Text("\(day)")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 35, height: 35)
                            .background(selectedMonthDays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedMonthDays.contains(day) ? .white : .primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Yearly Selection Section
struct YearlySelectionSection: View {
    @Binding var selectedMonths: Set<Int>
    
    private let monthNames = Calendar.current.monthSymbols
    
    var body: some View {
        Section(header: Text("Months of the Year")) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...12, id: \.self) { month in
                    Button(action: {
                        if selectedMonths.contains(month) {
                            selectedMonths.remove(month)
                        } else {
                            selectedMonths.insert(month)
                        }
                    }) {
                        Text(monthNames[month - 1])
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedMonths.contains(month) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedMonths.contains(month) ? .white : .primary)
                            .cornerRadius(8)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    CustomFrequencyPickerView(
        customConfig: .constant(CustomFrequencyConfig()),
        endRepeatOption: .constant(.never),
        endRepeatDate: .constant(Date())
    )
}
