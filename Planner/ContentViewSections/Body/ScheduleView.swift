//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ScheduleView: View {
    var selectedDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
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
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color1"))
                            .frame(width: 50, height: 75)
                        Image(systemName: getScheduleIcon(for: selectedDate))
                    }
                    Text(getScheduleTime(for: selectedDate))
                        .font(.body)
                        .foregroundColor(Color.gray)
                    Text(getScheduleTitle(for: selectedDate))
                        .font(.body)
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                
                
                HStack {
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color2"))
                            .frame(width: 50, height: 75)
                        
                        Image(systemName: "figure.walk")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    
                    Text("Morning Walk")
                        .font(.body)
                    
                    //  Image(systemName: "repeat")
                       // .foregroundColor(Color.gray.opacity(0.6))
                    Spacer()
                }
                HStack {
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color3"))
                            .frame(width: 50, height: 75)
                        
                        Image(systemName: "person.3.fill")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    
                    Text("Team Meeting")
                        .font(.body)
                    
                    Image(systemName: "repeat")
                        .foregroundColor(Color.gray.opacity(0.6))
                    
                    Spacer()
                }
               
            }
            .padding(.horizontal, 16)
        }
        .padding()
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
}

#Preview {
    ZStack {
        BackgroundView()
        ScheduleView(selectedDate: Date())
    }
}
