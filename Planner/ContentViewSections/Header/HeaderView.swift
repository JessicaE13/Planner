import SwiftUI

struct HeaderView: View {
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    @State private var currentWeekOffset: Int = 0
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    private var weekDates: [Date] {
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let offsetWeekStart = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: startOfWeek) ?? startOfWeek
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: offsetWeekStart)
        }
    }
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle.fill")
                Text("Hello, Jessica")
                Spacer()
                
                // Previous week button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentWeekOffset -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.trailing, 8)
                
 
                
                // Next week button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentWeekOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .padding(.trailing, 8)
                
                // Today button
                Button("Today") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentWeekOffset = 0
                        selectedDate = Date()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
                
                // Calendar button
                Button {
                    showingDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                }
                .padding(.leading, 8)
            }
            
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack {
                        Text(dateFormatter.string(from: date))
                        Text(dayFormatter.string(from: date))
                    }
                    .padding(8)
                    .background(isSelected(date) ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if value.translation.width > 20 {
                                // Swipe right - go to previous week
                                currentWeekOffset -= 1
                            } else if value.translation.width < -20 {
                                // Swipe left - go to next week
                                currentWeekOffset += 1
                            }
                        }
                    }
            )
        }
        .padding()
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                            updateWeekOffsetForSelectedDate()
                        }
                    }
                }
            }
        }
        
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.5))
    }
    
    private func updateWeekOffsetForSelectedDate() {
        let today = Date()
        let todayWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let selectedWeekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        let weekDifference = calendar.dateComponents([.weekOfYear], from: todayWeekStart, to: selectedWeekStart).weekOfYear ?? 0
        currentWeekOffset = weekDifference
    }
}

#Preview {
    NavigationStack {
        HeaderView(selectedDate: .constant(Date()))
    }
}
