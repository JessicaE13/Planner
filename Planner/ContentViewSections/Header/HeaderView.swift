import SwiftUI

struct HeaderView: View {
    @State private var selectedDate = Date()
    
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
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    var body: some View {
        HStack {
            ForEach(weekDates, id: \.self) { date in
                DateItemView(
                    date: date,
                    dayName: dateFormatter.string(from: date).uppercased(),
                    dayNumber: dayFormatter.string(from: date),
                    isSelected: isSelected(date),
                    isToday: isToday(date)
                ) {
                    selectedDate = date
                }
            }
        }
        .padding()
    }
}

private struct DateItemView: View {
    let date: Date
    let dayName: String
    let dayNumber: String
    let isSelected: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            Text(dayName)
                .font(.system(size: 12))
            Text(dayNumber)
                .font(.system(size: 22))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(backgroundView)
        .overlay(overlayView)
        .foregroundColor(.primary)
        .onTapGesture(perform: onTap)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor)
                .frame(width: 50, height: 75)
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if isToday && !isSelected {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 50, height: 75)
        }
    }
}

#Preview {
    NavigationStack {
        HeaderView()
    }
}
