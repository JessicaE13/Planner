//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

// Schedule item data model
struct ScheduleItem: Identifiable {
    let id = UUID()
    var title: String
    var time: String
    var icon: String
    var color: String
    var isRepeating: Bool
    var frequency: Frequency = .everyWeek
}

struct ScheduleView: View {
    var selectedDate: Date
    @State private var presentedItem: ScheduleItem?
    @State private var editingItem: ScheduleItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text("Schedule")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 16)
            
            VStack {
                // First schedule item - dynamic based on date
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color1"))
                            .frame(width: 50, height: 75)
                        Image(systemName: getScheduleIcon(for: selectedDate))
                    }
                    Text(getScheduleTime(for: selectedDate))
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text(getScheduleTitle(for: selectedDate))
                        .font(.body)
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    presentedItem = ScheduleItem(
                        title: getScheduleTitle(for: selectedDate),
                        time: getScheduleTime(for: selectedDate),
                        icon: getScheduleIcon(for: selectedDate),
                        color: "Color1",
                        isRepeating: true
                    )
                }
                
                // Second schedule item - Morning Walk
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color2"))
                            .frame(width: 50, height: 75)
                        Image(systemName: "figure.walk")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text("Morning Walk")
                        .font(.body)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    presentedItem = ScheduleItem(
                        title: "Morning Walk",
                        time: "12:00 PM",
                        icon: "figure.walk",
                        color: "Color2",
                        isRepeating: false
                    )
                }
                
                // Third schedule item - Team Meeting
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("Color3"))
                            .frame(width: 50, height: 75)
                        Image(systemName: "person.3.fill")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text("Team Meeting")
                        .font(.body)
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    presentedItem = ScheduleItem(
                        title: "Team Meeting",
                        time: "12:00 PM",
                        icon: "person.3.fill",
                        color: "Color3",
                        isRepeating: true
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(item: $presentedItem) { item in
            ScheduleDetailView(item: item, editingItem: $editingItem)
        }
        .sheet(item: $editingItem) { item in
            ScheduleEditView(item: item) { updatedItem in
                editingItem = nil
            }
        }
    }
    
    private func getScheduleIcon(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "figure.yoga" // Weekend - Yoga
        case 2, 4, 6: return "figure.run" // Mon, Wed, Fri - Running
        default: return "figure.walk" // Other days - Walking
        }
    }
    
    private func getScheduleTime(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "10:00 AM" // Weekend - Morning
        case 2, 4, 6: return "6:00 AM" // Mon, Wed, Fri - Early morning
        default: return "12:00 PM" // Other days - Noon
        }
    }
    
    private func getScheduleTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "Yoga Class" // Weekend
        case 2, 4, 6: return "Morning Run" // Mon, Wed, Fri
        default: return "Lunch Walk" // Other days
        }
    }
}

// MARK: - Schedule Detail View (Popup)
struct ScheduleDetailView: View {
    let item: ScheduleItem
    @Binding var editingItem: ScheduleItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Event Icon and Color
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(item.color))
                        .frame(width: 80, height: 120)
                    Image(systemName: item.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                // Event Details
                VStack(spacing: 16) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(item.time)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    if item.isRepeating {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.gray)
                            Text("Repeating")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Edit Button
                Button(action: {
                    editingItem = item
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Event")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Schedule Edit View
struct ScheduleEditView: View {
    @State private var item: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(item: ScheduleItem, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    HStack {
                        Text("Title")
                        Spacer()
                        TextField("Event title", text: $item.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Time")
                        Spacer()
                        TextField("Time", text: $item.time)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Settings") {
                    HStack {
                        Image(systemName: "repeat")
                        Text("Repeating")
                        Spacer()
                        Toggle("", isOn: $item.isRepeating)
                    }
                    
                    if item.isRepeating {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Frequency")
                            Spacer()
                            Picker("Frequency", selection: $item.frequency) {
                                ForEach(Frequency.allCases) { frequency in
                                    Text(frequency.displayName).tag(frequency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                Section("Appearance") {
                    HStack {
                        Text("Icon")
                        Spacer()
                        Image(systemName: item.icon)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Circle()
                            .fill(Color(item.color))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(item)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        ScheduleView(selectedDate: Date())
    }
}
