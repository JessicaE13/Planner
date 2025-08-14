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
    @State private var showEditView = false
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
                        Text(DateFormatter.localizedString(from: item.time, dateStyle: .none, timeStyle: .short))
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
                    showEditView = true
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
                // NavigationLink to ScheduleEditView
                NavigationLink(
                    destination: ScheduleEditView(item: item) { editedItem in
                        editingItem = editedItem
                    },
                    isActive: $showEditView
                ) {
                    EmptyView()
                }
                .hidden()
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
    @State @Previewable var editingItem: ScheduleItem? = nil
    return ScheduleDetailView(
        item: ScheduleItem(title: "Sample Event", time: Date(), icon: "star", color: "Color1", isRepeating: false),
        editingItem: $editingItem
    )
}
