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
    let onSave: (ScheduleItem) -> Void
    @State private var showingMapOptions = false
    @StateObject private var dataManager = UnifiedDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Remove the edit sheet state as we'll use navigation instead
    
    // Add state to track the height of the VStack (title & location)
    @State private var vStackHeight: CGFloat = 80
    
    // Add computed property for display date
    private var displayDate: Date {
        item.frequency != .never ? selectedDate : item.startTime
    }
    
    init(item: ScheduleItem, selectedDate: Date, onSave: @escaping (ScheduleItem) -> Void) {
        self._item = State(initialValue: item)
        self.selectedDate = selectedDate
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
            Color("BackgroundPopup")
                .ignoresSafeArea()
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Show time info for scheduled items OR todos with dates assigned
                                if item.itemType == .scheduled || (item.itemType == .todo && item.hasDate) {
                                    createTimeView()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 0)
                                }
                                
                                // Show checkbox for todo items OR scheduled items with showCheckbox enabled
                                if item.itemType == .todo || (item.itemType == .scheduled && item.showCheckbox) {
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
                                    .padding(.trailing, 12)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.leading, 8)
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
                    .padding(.top, 32)

                    if !item.location.isEmpty {
                        Button(action: {
                            showingMapOptions = true
                        }) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top, spacing: 4) {
                                        Image(systemName: "location")
                                            .foregroundColor(.blue)
                                        Text(item.location)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.blue)
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                            }
                            .font(.title)
                            .contentShape(Rectangle())
                        }
                    
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 24)
                        .padding(.top, 24)
                    
                    }
                    
                    if !item.url.isEmpty {
                        Button(action: {
                            if let url = URL(string: item.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top, spacing: 4) {
                                        Image(systemName: "link")
                                            .foregroundColor(.blue)
                                        Text(item.url)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.blue)
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                            }
                            .font(.title)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 24)
                        .padding(.bottom, 8)
                    }
                    
                    if item.itemType == .scheduled {
                        EmptyView()
                    }
             
                    if let category = item.category {
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
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

                    if item.frequency != .never {
                        // Add divider above repeat section if there's no category
                        if item.category == nil {
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                        }
                        
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
                    
                    if !item.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .kerning(1)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            Text(item.descriptionText)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        
                   
                    }

                    if !item.checklist.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Checklist")
                                .font(.headline)
                                .kerning(1)
                                .fontWeight(.bold)
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
                NavigationLink(destination: EditScheduleItemView(
                    item: item,
                    selectedDate: selectedDate,
                    onSave: { updatedItem in
                        onSave(updatedItem)
                    },
                    onDelete: { deleteOption in
                        // Handle delete operations
                        switch deleteOption {
                        case .thisEvent:
                            dataManager.excludeDateFromRecurring(item: item, excludeDate: selectedDate)
                            dismiss() // Dismiss the view after excluding this occurrence
                        case .allEvents:
                            dataManager.deleteItem(item)
                            dismiss() // Dismiss the view after delete
                        }
                    }
                )) {
                    Text("Edit")
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
                    Text(dateFormatter.string(from: displayDate))
                }

                // Only show time line if it's NOT an all-day event
                if !item.allDay {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                        Text("from \(timeFormatter.string(from: displayDateForTimeRangeStart())) to \(timeFormatter.string(from: displayDateForTimeRangeEnd()))")
                    }
                }
            }
            .font(.footnote)
            .foregroundColor(.primary)
        }
        // Remove horizontal padding so time aligns with title
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
            item: {
                var item = ScheduleItem.createScheduled(
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
                )
                item.url = "https://zoom.us/j/1234567890"
                return item
            }(),
            selectedDate: Date(),
            onSave: { _ in }
        )
    }
}
