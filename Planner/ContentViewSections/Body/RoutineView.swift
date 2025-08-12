//
//  RoutinesView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct RoutineView: View {
    var selectedDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Routines")
                    .sectionHeaderStyle()
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 16)
            
            HStack (spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 150, height: 100)
                    VStack {
                        HStack {
                            Image(systemName: "sunrise")
                            VStack(alignment: .leading) {
                                Text("Morning")
                                    .font(.callout)
                                Text("Routine")
                                    .font(.caption)
                            }
                        }
                        ProgressView(value: progressForDate(selectedDate), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                            .frame(width: 100)
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 100, height: 100)
            }
            .padding(.horizontal, 16)
        }
        .padding()
    }
    
    private func progressForDate(_ date: Date) -> Double {
        // Example: Different progress based on day of week
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        return Double(dayOfWeek) / 7.0
    }
}

#Preview {
    ZStack {
        BackgroundView()
        RoutineView(selectedDate: Date())
    }
}

