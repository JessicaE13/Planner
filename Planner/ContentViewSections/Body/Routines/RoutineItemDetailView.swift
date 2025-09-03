import SwiftUI

struct RoutineItemDetailView: View {
    @Binding var item: RoutineItem
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomFrequencyPicker = false
    @State private var customFrequencyConfig: CustomFrequencyConfig
    @State private var showingDeleteConfirmation = false
    @State private var useRoutineFrequency = false
    
    // Add properties to access the parent routine's frequency
    let routineFrequency: Frequency
    let routineCustomFrequencyConfig: CustomFrequencyConfig?
    
    init(item: Binding<RoutineItem>, onDelete: @escaping () -> Void, routineFrequency: Frequency = .everyDay, routineCustomFrequencyConfig: CustomFrequencyConfig? = nil) {
        self._item = item
        self.onDelete = onDelete
        self.routineFrequency = routineFrequency
        self.routineCustomFrequencyConfig = routineCustomFrequencyConfig
        
        if let existingConfig = item.wrappedValue.customFrequencyConfig {
            self._customFrequencyConfig = State(initialValue: existingConfig)
        } else {
            self._customFrequencyConfig = State(initialValue: CustomFrequencyConfig())
        }
        
        // Check if item is currently using routine frequency
        self._useRoutineFrequency = State(initialValue: item.wrappedValue.frequency == routineFrequency)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .edgesIgnoringSafeArea(.all)
                Form {
                    Section(header: Text("Item Details")) {
                        TextField("Item Name", text: $item.name)
                    }
                    Section(header: Text("Frequency")) {
                        // Add "Use Routine Frequency" option first
                        Button(action: {
                            useRoutineFrequency = true
                            item.frequency = routineFrequency
                            if routineFrequency == .custom {
                                item.customFrequencyConfig = routineCustomFrequencyConfig
                            } else {
                                item.customFrequencyConfig = nil
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Use Routine Frequency")
                                        .foregroundColor(.primary)
                                    if routineFrequency == .custom {
                                        Text(routineCustomFrequencyConfig?.displayDescription() ?? "Custom")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(routineFrequency.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if useRoutineFrequency && item.frequency == routineFrequency {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Show other frequency options
                        ForEach(Frequency.allCases) { frequency in
                            Button(action: {
                                useRoutineFrequency = false
                                item.frequency = frequency
                                if frequency == .custom {
                                    showingCustomFrequencyPicker = true
                                } else {
                                    item.customFrequencyConfig = nil
                                }
                            }) {
                                HStack {
                                    if frequency == .custom && item.frequency == .custom && !useRoutineFrequency {
                                        Text(customFrequencyConfig.displayDescription())
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(frequency.displayName)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    if !useRoutineFrequency && item.frequency == frequency {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    if item.frequency != .never {
                        Section(header: Text("End Repeat")) {
                            Picker("End Repeat", selection: $item.endRepeatOption) {
                                ForEach(EndRepeatOption.allCases) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if item.endRepeatOption == .onDate {
                                DatePicker("End Date", selection: $item.endRepeatDate, displayedComponents: .date)
                            }
                        }
                    }
                    Section {
                        Button("Delete Item", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                    Section {
                        if useRoutineFrequency {
                            Text("This item will follow the routine's overall frequency.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("This frequency will override the routine's overall frequency for this specific item.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Edit Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if item.frequency == .custom && !useRoutineFrequency {
                                item.customFrequencyConfig = customFrequencyConfig
                            }
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCustomFrequencyPicker) {
                CustomFrequencyPickerView(
                    customConfig: $customFrequencyConfig,
                    endRepeatOption: $item.endRepeatOption,
                    endRepeatDate: $item.endRepeatDate
                )
            }
            .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
            .onChange(of: item.frequency) { _, newFrequency in
                if newFrequency == .never {
                    item.endRepeatOption = .never
                }
                if newFrequency == .custom && !useRoutineFrequency {
                    showingCustomFrequencyPicker = true
                }
                // Update useRoutineFrequency state based on frequency match
                useRoutineFrequency = (newFrequency == routineFrequency)
            }
        }
    }
}