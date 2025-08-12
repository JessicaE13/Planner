import SwiftUI

struct HeaderView: View {
    @Binding var selectedDate: Date
    
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
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle.fill")
                Text("Hello, Jessica")
                Spacer()
                Button {
                } label: {
                    Image(systemName: "distribute.horizontal.center")
                }
            }
            
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack {
                        Text(dateFormatter.string(from: date))
                        Text(dayFormatter.string(from: date))
                    }
                    .padding(8)
                    .background(isSelected(date) ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
        }
        .padding()
        
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.5))
    }
}

#Preview {
    HeaderView(selectedDate: .constant(Date()))
}
