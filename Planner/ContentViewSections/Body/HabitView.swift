//
//  HabitView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Habit: Identifiable {
    let id = UUID()
    let name: String
    var isCompleted: Bool
}

struct HabitView: View {
    @State private var habits = [
        Habit(name: "Habit 1", isCompleted: false),
        Habit(name: "Habit 2", isCompleted: false),
        Habit(name: "Habit 3", isCompleted: false),
        Habit(name: "Habit 4", isCompleted: false),
        Habit(name: "Habit 5", isCompleted: false)
    ]
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Habits")
                Spacer()
                Image(systemName: "ellipsis")
            }
            VStack(spacing: 0) {
                ForEach(habits.indices, id: \ .self) { index in
                    Button(action: {
                        habits[index].isCompleted.toggle()
                    }) {
                        HStack {
                            Image(systemName: habits[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habits[index].isCompleted ? .accentColor : .secondary)
                            Text(habits[index].name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 8)
                    if index < habits.count - 1 {
                        Divider()
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    HabitView()
}
