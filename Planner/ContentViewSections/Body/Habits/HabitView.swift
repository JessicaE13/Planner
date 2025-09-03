//
//  HabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

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
        ZStack {
     
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
                                        .font(.title2)
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
}

#Preview {
    HabitView(selectedDate: Date())
}
