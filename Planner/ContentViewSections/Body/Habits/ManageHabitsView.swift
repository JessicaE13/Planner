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
    @State private var showingAddHabit = false
    @State private var selectedHabitIndex: Int?
    @State private var showingHabitDetail = false
    
    var body: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Manage Habits")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Build and track your daily routines")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Done") { 
                        dismiss() 
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                .padding()
                
                // Habits list or empty state
                if habitManager.habits.isEmpty {
                    // Empty state - centered
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "repeat.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No habits yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start building better habits by adding your first one using the + button below!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    // Habits list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(habitManager.habits.indices, id: \.self) { index in
                                Button(action: {
                                    selectedHabitIndex = index
                                    showingHabitDetail = true
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(habitManager.habits[index].name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text(habitManager.habits[index].frequency.displayName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    .background(Color.primary.colorInvert())
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating action button
                    }
                }
                
                Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("BackgroundPopup"))
                            .frame(width: 56, height: 56)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 34) // Account for tab bar
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { newHabit in
                habitManager.addHabit(newHabit)
                showingAddHabit = false
            }
        }
        .sheet(isPresented: $showingHabitDetail) {
            if let index = selectedHabitIndex, 
               index >= 0 && index < habitManager.habits.count {
                HabitDetailView(
                    habit: .constant(habitManager.habits[index]),
                    habitManager: habitManager,
                    onDelete: {
                        habitManager.deleteHabit(at: index)
                        showingHabitDetail = false
                        selectedHabitIndex = nil
                    }
                )
            }
        }
        .onChange(of: newHabitFrequency) { _, newFrequency in
            // Reset end repeat options when frequency changes to "Never"
            if newFrequency == .never {
                newHabitEndRepeatOption = .never
            }
        }
    }
}

// Helper struct to make the habit identifiable for the sheet
struct HabitWrapper: Identifiable {
    let id = UUID()
    let habit: Habit
    let index: Int
}

#Preview {
    ManageHabitsView(habitManager: HabitDataManager.shared)
}
