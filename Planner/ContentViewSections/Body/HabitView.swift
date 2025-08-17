//
//  HabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    let id: UUID // Back to let - immutable as it should be
    var name: String
    var frequency: Frequency = .everyDay
    var completion: [String: Bool] // date string (yyyy-MM-dd) to completion status
    
    // Add start and end date properties
    var startDate: Date = Date()
    var endRepeatOption: EndRepeatOption = .never
    var endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    // Custom initializer for creating new habits
    init(name: String, frequency: Frequency = .everyDay, completion: [String: Bool] = [:], startDate: Date = Date(), endRepeatOption: EndRepeatOption = .never, endRepeatDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()) {
        self.id = UUID()
        self.name = name
        self.frequency = frequency
        self.completion = completion
        self.startDate = startDate
        self.endRepeatOption = endRepeatOption
        self.endRepeatDate = endRepeatDate
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case id, name, frequency, completion, startDate, endRepeatOption, endRepeatDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        completion = try container.decode([String: Bool].self, forKey: .completion)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        endRepeatOption = try container.decodeIfPresent(EndRepeatOption.self, forKey: .endRepeatOption) ?? .never
        endRepeatDate = try container.decodeIfPresent(Date.self, forKey: .endRepeatDate) ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(completion, forKey: .completion)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endRepeatOption, forKey: .endRepeatOption)
        try container.encode(endRepeatDate, forKey: .endRepeatDate)
    }
    
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
        // If frequency is never, only show on the exact start date
        if frequency == .never {
            return Calendar.current.isDate(startDate, inSameDayAs: date)
        }
        
        // Check if the habit should trigger based on frequency from start date
        let shouldTrigger = frequency.shouldTrigger(on: date, from: startDate)
        
        // If it shouldn't trigger based on frequency, don't show
        if !shouldTrigger {
            return false
        }
        
        // Check end repeat conditions
        if endRepeatOption == .onDate {
            return date <= endRepeatDate
        }
        
        // If endRepeatOption is .never, show indefinitely (as long as frequency matches)
        return true
    }
}

// MARK: - Habit Data Manager
class HabitDataManager: ObservableObject {
    @Published var habits: [Habit] = []
    
    static let shared = HabitDataManager()
    
    private init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(at index: Int) {
        guard index < habits.count else { return }
        habits.remove(at: index)
        saveHabits()
    }
    
    func toggleHabit(at index: Int, for date: Date) {
        guard index < habits.count else { return }
        habits[index].toggle(for: date)
        saveHabits()
    }
    
    private func saveHabits() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(habits)
            UserDefaults.standard.set(data, forKey: "SavedHabits")
        } catch {
            print("Failed to save habits: \(error)")
        }
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: "SavedHabits") else {
            // Load default habits if no saved data exists
            loadDefaultHabits()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            habits = try decoder.decode([Habit].self, from: data)
            
            // Migrate existing habits that might have today's date as start date
            migrateExistingHabits()
        } catch {
            print("Failed to load habits: \(error)")
            loadDefaultHabits()
        }
    }
    
    private func migrateExistingHabits() {
        let today = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        var needsUpdate = false
        
        for index in habits.indices {
            // If the habit's start date is today (indicating it's an old habit), update it
            if Calendar.current.isDate(habits[index].startDate, inSameDayAs: today) {
                habits[index].startDate = weekAgo
                needsUpdate = true
            }
        }
        
        if needsUpdate {
            saveHabits()
        }
    }
    
    private func loadDefaultHabits() {
        // Set start date to a week ago so habits show up in past days
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        habits = [
            Habit(name: "Drink Water", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Exercise", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Read", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Meditate", frequency: .everyDay, startDate: weekAgo),
            Habit(name: "Journal", frequency: .everyDay, startDate: weekAgo)
        ]
        saveHabits()
    }
}

struct HabitView: View {
    @StateObject private var habitManager = HabitDataManager.shared
    var selectedDate: Date
    @State private var showManageHabits = false
    
    // Debug function to check habit visibility
    private func debugHabitVisibility() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        print("=== HABIT DEBUG for \(formatter.string(from: selectedDate)) ===")
        for (index, habit) in habitManager.habits.enumerated() {
            let shouldShow = habit.shouldAppear(on: selectedDate)
            let startDateStr = formatter.string(from: habit.startDate)
            let frequencyTrigger = habit.frequency.shouldTrigger(on: selectedDate, from: habit.startDate)
            
            print("Habit \(index): \(habit.name)")
            print("  Start Date: \(startDateStr)")
            print("  Frequency: \(habit.frequency.displayName)")
            print("  Should Trigger: \(frequencyTrigger)")
            print("  Should Show: \(shouldShow)")
            print("  End Option: \(habit.endRepeatOption.displayName)")
            print("---")
        }
    }
    
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
                ForEach(habitManager.habits.indices, id: \.self) { index in
                    if habitManager.habits[index].shouldAppear(on: selectedDate) {
                        Button(action: {
                            habitManager.toggleHabit(at: index, for: selectedDate)
                        }) {
                            HStack {
                                Image(systemName: habitManager.habits[index].isCompleted(for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(habitManager.habits[index].isCompleted(for: selectedDate) ? .primary : .gray)
                                Text(habitManager.habits[index].name)
                                    .strikethrough(habitManager.habits[index].isCompleted(for: selectedDate))
                                    .foregroundColor(habitManager.habits[index].isCompleted(for: selectedDate) ? .secondary : .primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    
                        if index < habitManager.habits.count - 1 && habitManager.habits[(index + 1)...].contains(where: { $0.shouldAppear(on: selectedDate) }) {
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
            ManageHabitsView(habitManager: habitManager)
        }
        .onAppear {
            // Uncomment this line to see debug info in console
            // debugHabitVisibility()
        }
        .onChange(of: selectedDate) { _, _ in
            // Uncomment this line to see debug info when date changes
            // debugHabitVisibility()
        }
    }
}

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

struct EditableHabitRow: View {
    @ObservedObject var habitManager: HabitDataManager
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Habit Name", text: Binding(
                    get: { habitManager.habits[index].name },
                    set: { newValue in
                        habitManager.habits[index].name = newValue
                        habitManager.updateHabit(habitManager.habits[index])
                    }
                ))
                Spacer()
                Button(action: {
                    habitManager.deleteHabit(at: index)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Picker("", selection: Binding(
                    get: { habitManager.habits[index].frequency },
                    set: { newValue in
                        habitManager.habits[index].frequency = newValue
                        habitManager.updateHabit(habitManager.habits[index])
                    }
                )) {
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
