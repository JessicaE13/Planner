//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ScheduleItem: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let icon: String
    let color: String
    let description: String
    let isRepeating: Bool
}

struct ScheduleView: View {
    var selectedDate: Date
    @State private var presentedItem: ScheduleItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    private var scheduleItems: [ScheduleItem] {
        [
            ScheduleItem(
                title: getScheduleTitle(for: selectedDate),
                time: getScheduleTime(for: selectedDate),
                icon: getScheduleIcon(for: selectedDate),
                color: "Color1",
                description: getScheduleDescription(for: selectedDate),
                isRepeating: true
            ),
            ScheduleItem(
                title: "Morning Walk",
                time: "12:00 PM",
                icon: "figure.walk",
                color: "Color2",
                description: "A refreshing walk to get some fresh air and exercise during lunch break.",
                isRepeating: false
            ),
            ScheduleItem(
                title: "Team Meeting",
                time: "12:00 PM",
                icon: "person.3.fill",
                color: "Color3",
                description: "Weekly team sync to discuss project progress, blockers, and upcoming milestones.",
                isRepeating: true
            )
        ]
    }
    
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
                ForEach(scheduleItems, id: \.id) { item in
                    ScheduleRowView(item: item) {
                        presentedItem = item
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .sheet(item: $presentedItem) { item in
            ScheduleDetailView(item: item)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
    
    private func getScheduleDescription(for date: Date) -> String {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1, 7: return "Join us for a relaxing yoga session to improve flexibility and reduce stress." // Weekend
        case 2, 4, 6: return "A brisk run to kickstart your day with energy and enthusiasm." // Mon, Wed, Fri
        default: return "A pleasant walk to enjoy your lunch break and refresh your mind." // Other days
        }
    }
}

struct ScheduleRowView: View {
    let item: ScheduleItem
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(item.color))
                    .frame(width: 50, height: 75)
                Image(systemName: item.icon)
                    .foregroundColor(.white)
            }
            
            Text(item.time)
                .font(.body)
                .foregroundColor(Color.gray)
            
            Text(item.title)
                .font(.body)
            
            if item.isRepeating {
                Image(systemName: "repeat")
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct ScheduleDetailView: View {
    let item: ScheduleItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Main content
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(item.color))
                            .frame(width: 60, height: 90)
                        Image(systemName: item.icon)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(item.time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if item.isRepeating {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text("Repeating")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // Description section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Schedule Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
