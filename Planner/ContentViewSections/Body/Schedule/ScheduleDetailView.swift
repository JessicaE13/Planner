//
//  ScheduleDetailView.swift
//  Planner
//
//  Created by Jessica Estes on 8/13/25.
//

import SwiftUI

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
#Preview {
    ScheduleDetailView(
        item: ScheduleItem(
            title: "Sample Event",
            time: "10:00 AM",
            icon: "calendar",
            color: "Color1",
            isRepeating: true
        ),
        editingItem: .constant(nil)
    )
}
