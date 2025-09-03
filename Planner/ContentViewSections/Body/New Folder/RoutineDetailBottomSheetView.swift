import SwiftUI

struct RoutineDetailBottomSheetView: View {
    @Binding var routine: Routine
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var originalRoutine: Routine
    @State private var workingRoutine: Routine
    
    init(routine: Binding<Routine>, selectedDate: Date) {
        self._routine = routine
        self.selectedDate = selectedDate
        self._originalRoutine = State(initialValue: routine.wrappedValue)
        self._workingRoutine = State(initialValue: routine.wrappedValue)
    }
    
    private var visibleItems: [RoutineItem] {
        return workingRoutine.visibleItems(for: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: workingRoutine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(workingRoutine.color)
                        .frame(minHeight: 56, alignment: .center)
                  
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workingRoutine.name + " Routine")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        ProgressView(value: workingRoutine.progress(for: selectedDate), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: workingRoutine.color))
                            .scaleEffect(y: 1.5)
                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.progress(for: selectedDate))
                            .padding(.trailing, 16)
                    }
                }
                // Removed the "X out of Y items today" text
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
            
            ScrollView {
                if !visibleItems.isEmpty {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(visibleItems.indices, id: \.self) { index in
                                let item = visibleItems[index]
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        workingRoutine.toggleItem(item.name, for: selectedDate)
                                        // Don't save to routine binding immediately
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: workingRoutine.isItemCompleted(item.name, for: selectedDate) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .primary : .gray)
                                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                        Text(item.name)
                                            .strikethrough(workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                            .foregroundColor(workingRoutine.isItemCompleted(item.name, for: selectedDate) ? .secondary : .primary)
                                            .animation(.easeInOut(duration: 0.3), value: workingRoutine.isItemCompleted(item.name, for: selectedDate))
                                        Spacer()
                                        if item.frequency != workingRoutine.frequency {
                                            HStack(spacing: 4) {
                                                Image(systemName: "repeat")
                                                    .font(.caption2)
                                                if item.frequency == .custom {
                                                    Text(item.customFrequencyConfig?.displayDescription() ?? "Custom")
                                                        .font(.caption)
                                                } else {
                                                    Text(item.frequency.displayName)
                                                        .font(.caption)
                                                }
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .padding(.trailing, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                if index < visibleItems.count {
                                    Divider()
                                        .padding(.leading, 36)
                                        .padding(.trailing, 24)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No items scheduled for today")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("This routine has items with different frequencies. Check back on other days or edit the routine to adjust item schedules.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
            }
            
            HStack {
                Button("Save") {
                    // Save changes to the routine binding before dismissing
                    routine = workingRoutine
                    dismiss()
                }
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color("AccentColor"))
                .foregroundColor(Color("BackgroundPpopup"))
                .cornerRadius(20)
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 36)
            .padding(.top, 24)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background( Color("BackgroundPopup"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EditRoutineNavigationView(routine: $routine)) {
                    Text("Edit")
                        .foregroundColor(.primary)
                }
            }
        }
        .onChange(of: routine) { _, newRoutine in
            // Update workingRoutine when the bound routine changes (e.g., after editing)
            workingRoutine = newRoutine
        }
    }
}