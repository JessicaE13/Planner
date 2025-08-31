//
//  EditableHabitRow.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

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