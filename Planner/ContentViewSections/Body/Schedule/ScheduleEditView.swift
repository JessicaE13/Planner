//
//  ScheduleEditView.swift
//  Planner
//
//  Created by Jessica Estes on 8/13/25.
//

import SwiftUI

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
                        DatePicker("", selection: $item.time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
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
    ScheduleEditView(item: ScheduleItem(title: "Sample Event", time: Date(), icon: "star", color: "Color1", isRepeating: false), onSave: { _ in })
}
