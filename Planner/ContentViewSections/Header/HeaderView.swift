import SwiftUI

private struct IsFutureSelectedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFutureSelected: Bool {
        get { self[IsFutureSelectedKey.self] }
        set { self[IsFutureSelectedKey.self] = newValue }
    }
}

struct HeaderView: View {
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
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
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private var isFutureSelected: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: Date())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
   
                 
                Text("Hello, Jessica")
                   
                Spacer()
                
                // Previous week button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let newDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.trailing, 8)
                
                // Next week button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let newDate = calendar.date(byAdding: .day, value: 7, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                
                Button("Today") {
                    withAnimation(.easeInOut(duration: 0.3)) {
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
                                if let newDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            } else if value.translation.width < -20 {
                                if let newDate = calendar.date(byAdding: .day, value: 7, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        }
                    }
            )
        }
        .padding()
        .background(Color("BackgroundPopup"))
        .environment(\.isFutureSelected, isFutureSelected)
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
    }
}

#Preview {
    NavigationStack {
        HeaderView(selectedDate: .constant(Date()))
    }
}
