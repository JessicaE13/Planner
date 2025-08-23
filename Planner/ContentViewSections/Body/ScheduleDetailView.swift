//
//  ScheduleDetailView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI
import MapKit

// MARK: - Enhanced Schedule Detail View with Repeat Icon

struct ScheduleDetailView: View {
    @State private var item: ScheduleItem
    let selectedDate: Date
    let onEdit: (ScheduleItem) -> Void
    let onSave: (ScheduleItem) -> Void
    @State private var showingMapOptions = false
    @StateObject private var dataManager = UnifiedDataManager.shared
    // Add state to track the height of the VStack (title & location)
    @State private var vStackHeight: CGFloat = 80
    
    // Add computed property for display date
    private var displayDate: Date {
        item.frequency != .never ? selectedDate : item.startTime
    }
    
    init(item: ScheduleItem, selectedDate: Date, onEdit: @escaping (ScheduleItem) -> Void, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.selectedDate = selectedDate
        self.onEdit = onEdit
        self.onSave = onSave
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing:8) {

                    // Add top padding to move icon/title section down
                    HStack(alignment: .top, spacing: 16) {
                        // Use the measured height for the ZStack
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(item.color))
                                .frame(width: 56, height: max(vStackHeight, 75))
                            Image(systemName: item.icon)
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        // Measure the height of the VStack (title, time & location)
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.title)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                // --- TIME PART MOVED UP HERE ---
                                if item.itemType == .scheduled {
                                    createTimeView()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 0)
                                }
                                // --- LOCATION PART MOVED BELOW TIME ---
                                if !item.location.isEmpty {
                                    Button(action: {
                                        showingMapOptions = true
                                    }) {
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(alignment: .top, spacing: 4) {
                                                    Image(systemName: "location")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                    Text(item.location)
                                                        .font(.caption)
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.blue)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            Spacer()
                                            
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.leading, 8)
                        // GeometryReader to measure height
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        vStackHeight = geometry.size.height
                                    }
                                    .onChange(of: geometry.size.height) { newValue, _ in
                                        vStackHeight = newValue
                                    }
                            }
                        )
                    }
                    .padding(.leading, 24)
                    .padding(.top, 32) // Added top padding here
                    
                    
                    if item.itemType == .todo {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.primary)
                                    .frame(width: 20)
                                Text("Task Status")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        item.isCompleted.toggle()
                                        onSave(item)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isCompleted ? .primary : .gray)
                                            .font(.title2)
                                        
                                        Text("Mark as Completed")
                                            .font(.body)
                                            .strikethrough(item.isCompleted)
                                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    
                    if item.itemType == .scheduled {
                        // removed: createTimeView()
                        EmptyView()
                    }
             
                    
                    if let category = item.category {
                        Divider()
                            .padding(.horizontal, 24)
                        HStack {
                            Text("Category")
                                .foregroundColor(.primary)
                            Spacer()
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(category.color))
                                    .frame(width: 16, height: 16)
                                Text(category.name)
                            }
                            .padding(.horizontal, 12)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 0)
                    }

                    // Repeat row (recurrence)
                    if item.frequency != .never {
                        HStack {
                            Text("Repeat")
                                .foregroundColor(.primary)
                            Spacer()
                            HStack(spacing: 8) {
                                Text(getFrequencyDisplayText())
                            }
                            .padding(.horizontal, 12)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 0)
                    }
                    
                    // Description
                    if !item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .kerning(1)
                                .textCase(.uppercase)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            Text(item.descriptionText)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }

                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        
                   
                    }
                    
                    // Checklist - Full row tap functionality
                    if !item.checklist.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Checklist")
                                .font(.headline)
                                .kerning(1)
                                .textCase(.uppercase)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            VStack(spacing: 0) {
                                ForEach(Array(item.checklist.enumerated()), id: \.element.id) { index, checklistItem in
                                    Button(action: {
                                        item.checklist[index].isCompleted.toggle()
                                        onSave(item)
                                    }) {
                                        HStack {
                                            Image(systemName: checklistItem.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(checklistItem.isCompleted ? .primary : .gray)
                                                .font(.title3)
                                            Text(checklistItem.text)
                                                .strikethrough(checklistItem.isCompleted)
                                                .foregroundColor(checklistItem.isCompleted ? .secondary : .primary)
                                                .font(.body)
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        .cornerRadius(8)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .animation(.easeInOut(duration: 0.2), value: checklistItem.isCompleted)
                                    if index < item.checklist.count  {
                                        Divider()
                                            .padding(.leading, 36)
                                            .padding(.trailing, 12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
        }
        .navigationTitle(item.itemType == .todo ? "Task Details" : "Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    onEdit(item)
                }
            }
        }
        .actionSheet(isPresented: $showingMapOptions) {
            ActionSheet(
                title: Text("Navigate to Location"),
                message: Text(item.location),
                buttons: [
                    .default(Text("Open in Apple Maps")) {
                        openInAppleMaps()
                    },
                    .default(Text("Open in Google Maps")) {
                        openInGoogleMaps()
                    },
                    .cancel()
                ]
            )
        }
        .onReceive(dataManager.$items) { _ in
            if let updatedItem = dataManager.items.first(where: { $0.id == item.id }) {
                item = updatedItem
            }
        }
    }
    
    // MARK: - Updated Time View Creation Helper with Repeat Icon
    private func createTimeView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
        
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.primary)
                        .font(.caption2)
                    Text(dateFormatter.string(from: displayDate))
                        .font(.caption)
     
                        .foregroundColor(.primary)
                }

 
                if item.allDay {
                    Text("All Day")
                        .font(.caption)
                     //   .fontWeight(.medium)
                        .foregroundColor(.primary)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.primary)
                            .font(.caption2)
                        Text("from \(timeFormatter.string(from: displayDateForTimeRangeStart())) to \(timeFormatter.string(from: displayDateForTimeRangeEnd()))")
                            .font(.caption)
                      //      .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func displayDateForTimeRangeStart() -> Date {
        if item.frequency != .never {
            // Use selectedDate with the time from item.startTime
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: item.startTime)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: timeComponents.second ?? 0, of: selectedDate) ?? selectedDate
        } else {
            return item.startTime
        }
    }
    
    private func displayDateForTimeRangeEnd() -> Date {
        if item.frequency != .never {
            _ = Calendar.current
            let duration = item.endTime.timeIntervalSince(item.startTime)
            let start = displayDateForTimeRangeStart()
            return start.addingTimeInterval(duration)
        } else {
            return item.endTime
        }
    }
    
    // MARK: - Helper method to get frequency display text
    private func getFrequencyDisplayText() -> String {
        if item.frequency == .custom, let customConfig = item.customFrequencyConfig {
            return customConfig.displayDescription()
        } else {
            return item.frequency.displayName
        }
    }
    
    // MARK: - Navigation Helper Methods
    
    private func openInAppleMaps() {
        let encodedLocation = item.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedLocation)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let encodedLocation = item.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        
        if let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedLocation)"),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } else {
            
            if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedLocation)") {
                UIApplication.shared.open(webURL)
            }
        }
    }
}

// MARK: - Preview

#Preview("Schedule Detail View") {
    NavigationView {
        ScheduleDetailView(
            item: ScheduleItem.createScheduled(
                title: "Team Meeting",
                startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date()) ?? Date(),
                icon: "calendar",
                color: "Color1",
                frequency: .everyWeek,
                descriptionText: "Weekly team standup meeting to discuss project progress and upcoming deliverables.",
                location: "Conference Room A",
                allDay: false,
                checklist: [
                    ChecklistItem(text: "Prepare agenda"),
                    ChecklistItem(text: "Review project updates", isCompleted: true),
                    ChecklistItem(text: "Schedule follow-ups")
                ],
                category: .learning,
                endRepeatOption: .never,
                endRepeatDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
            ),
            selectedDate: Date(),
            onEdit: { _ in },
            onSave: { _ in }
        )
    }
}
