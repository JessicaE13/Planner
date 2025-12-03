import SwiftUI

struct HeaderView: View {
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    @State private var currentWeekOffset: Int = 0
    @State private var showingSettings = false
    @Environment(\.colorScheme) private var colorScheme
    
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
        VStack(spacing: 20) {
            HStack {
   
                 
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
                
                Button("Today") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentWeekOffset = 0
                        selectedDate = Date()
                    }
                }
             
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.001))
                .foregroundColor(Color("AccentColor"))
                .cornerRadius(12)
                
                Button {
                    showingDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                      
                }
                
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .font(.title3)
            
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 4) {
                        // Weekday name - always in primary color (never highlighted)
                        Text(dateFormatter.string(from: date))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        // Date number - highlighted when selected
                        Text(dayFormatter.string(from: date))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(isSelected(date) ? (colorScheme == .dark ? .black : .white) : .primary)
                            .frame(width: 40, height: 40)
                            .background(isSelected(date) ? Color("AccentColor") : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
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
                                currentWeekOffset -= 1
                            } else if value.translation.width < -20 {
                                currentWeekOffset += 1
                            }
                        }
                    }
            )
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
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
                }
                .background(Color("Background").opacity(0.2))
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
            .presentationDetents([.medium])
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
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
