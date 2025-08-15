//
//  HabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Habit: Identifiable, Codable {
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
        let startDate = Date()
        return frequency.shouldTrigger(on: date, from: startDate)
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
        } catch {
            print("Failed to load habits: \(error)")
            loadDefaultHabits()
        }
    }
    
    private func loadDefaultHabits() {
        habits = [
            Habit(name: "Drink Water", completion: [:]),
            Habit(name: "Exercise", completion: [:]),
            Habit(name: "Read", completion: [:]),
            Habit(name: "Meditate", completion: [:]),
            Habit(name: "Journal", completion: [:])
        ]
        saveHabits()
    }
}

struct HabitView: View {
    @StateObject private var habitManager = HabitDataManager.shared
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
                    Picker("Frequency", selection: $habit.frequency) {
                        ForEach(Frequency.allCases) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .onChange(of: habit.frequency) { _, _ in
                        habitManager.updateHabit(habit)
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
    }
}

struct ManageHabitsView: View {
    @ObservedObject var habitManager: HabitDataManager
    @Environment(\.dismiss) var dismiss
    @State private var newHabitName = ""
    
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
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .frame(height: 56)
                    HStack {
                        TextField("New Habit", text: $newHabitName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                addNewHabit()
                            }
                        Button("Add") {
                            addNewHabit()
                        }
                        .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
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
    }
    
    private func addNewHabit() {
        let trimmedName = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            let newHabit = Habit(name: trimmedName, completion: [:])
            habitManager.addHabit(newHabit)
            newHabitName = ""
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
