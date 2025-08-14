//
//  ScheduleEditView.swift
//  Planner
//
//  Created by Jessica Estes on 8/13/25.
//

import SwiftUI
import MapKit

struct ScheduleEditView: View {
    @State private var item: ScheduleItem
    let onSave: (ScheduleItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showMapPicker = false
    @State private var locationSearchResults: [MKMapItem] = []
    @State private var isSearchingLocation = false
    @State private var locationSearchTask: Task<Void, Never>? = nil
    
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
                    // Inline Location Search
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Location", text: $item.location, onEditingChanged: { editing in
                            isSearchingLocation = editing
                            if editing { performLocationSearch() }
                        })
                        .multilineTextAlignment(.leading)
                        .onChange(of: item.location) { _, _ in
                            performLocationSearch()
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        if isSearchingLocation && !locationSearchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(locationSearchResults.prefix(5), id: \.self) { itemResult in
                                    Button(action: {
                                        let name = itemResult.name ?? "Selected Location"
                                        let address = itemResult.placemark.title ?? ""
                                        item.location = name + (address.isEmpty ? "" : "\n" + address)
                                        isSearchingLocation = false
                                        locationSearchResults = []
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(itemResult.name ?? "Unknown")
                                            Text(itemResult.placemark.title ?? "")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.top, 2)
                        }
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
        .onAppear {
            performLocationSearch()
        }
    }
    
    private func performLocationSearch() {
        locationSearchTask?.cancel()
        guard !item.location.isEmpty else {
            locationSearchResults = []
            return
        }
        locationSearchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = item.location
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            if let items = response?.mapItems {
                locationSearchResults = items
            } else {
                locationSearchResults = []
            }
        }
    }
}


#Preview {
    ScheduleEditView(item: ScheduleItem(title: "Sample Event", time: Date(), icon: "star", color: "Color1", isRepeating: false), onSave: { _ in })
}
