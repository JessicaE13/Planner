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
                Section {
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                       
                        TextField("Title", text: $item.title)
                            .multilineTextAlignment(.leading)
                    }
                    
                    
                       HStack {
                           
                           TextField("Location", text: $item.location)
                               .multilineTextAlignment(.leading)
                           
                       }
                    
    
                }
                
                Section {
                 
                    HStack {
                        
                        Text("All-day")
                        Spacer()
                        Toggle("", isOn: $item.isRepeating)
                    }
                    HStack {
                        Text("Start")
                        Spacer()
                        DatePicker("", selection: $item.startTime, displayedComponents: .date)
                            .labelsHidden()
                        DatePicker("", selection: $item.startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }

                    HStack {
                        Text("End")
                        Spacer()
                        DatePicker("", selection: $item.endTime, displayedComponents: .date)
                            .labelsHidden()
                        DatePicker("", selection: $item.endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }

                        HStack {
                 
                            Text("Repeat")
                            Spacer()
                            Picker("", selection: $item.frequency) {
                                ForEach(Frequency.allCases) { frequency in
                                    Text(frequency.displayName).tag(frequency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    
                }
                
                Section {
                    HStack {
                        Text("Icon")
                        Spacer()
               
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
