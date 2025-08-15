//
//  RoutinesView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct Routine: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var items: [String]
    var completedItems: Set<String> = []
    
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedItems.count) / Double(items.count)
    }
    
    mutating func toggleItem(_ item: String) {
        if completedItems.contains(item) {
            completedItems.remove(item)
        } else {
            completedItems.insert(item)
        }
    }
}

struct RoutineView: View {
    var selectedDate: Date
    @Binding var routines: [Routine]
    @Binding var showRoutineDetail: Bool
    @Binding var selectedRoutineIndex: Int?
    
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 16) {
                    ForEach(routines.indices, id: \.self) { index in
                        Button(action: {
                            selectedRoutineIndex = index
                            withAnimation {
                                showRoutineDetail = true
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Background").opacity(0.75))
                                    .frame(width: 164, height: 100)
                                VStack {
                                    HStack(alignment: .bottom) {
                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(routines[index].name)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .kerning(1)
                                                .foregroundColor(.primary)
                                               
                                            Text("Routine")
                                                .font(.system(size: 10, weight: .regular, design: .default))
                                                .kerning(1)
                                                .textCase(.uppercase)
                                                .foregroundColor(.primary.opacity(0.75))
                                             
                                        }
                                        Spacer()
                                        
                                        Image(systemName: routines[index].icon)
                                            .frame(width: 36, height: 36)
                                            .font(.largeTitle)
                                            .foregroundColor(Color(UIColor.lightGray).opacity(0.25))
                                
                                    }
                                    .padding(.horizontal, 8)
                                    
                                    // Added animation to progress view
                                    ProgressView(value: routines[index].progress, total: 1.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                                        .padding(.top, 8)
                                        .animation(.easeInOut(duration: 0.3), value: routines[index].progress)
                                }
                                .frame(width: 136)
                            }
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
    }
}


// Popup?
struct RoutineDetailView: View {
    @Binding var routine: Routine
    var dismissAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
  
            ZStack {
                VStack (spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismissAction?() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(12)
                    }
                    .padding()
                }
                
                VStack(spacing: 16) {
                    Image(systemName: routine.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.primary)
                    
                    Text(routine.name + " Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Added animation to progress view in detail
                    ProgressView(value: routine.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                        .frame(maxWidth: 200)
                        .animation(.easeInOut(duration: 0.3), value: routine.progress)
                }
            }
            }
            .padding(.top, 24)
            .padding(.bottom, 32)

            if !routine.items.isEmpty {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("Background"))
                        
                        VStack(spacing: 0) {
                            ForEach(routine.items.indices, id: \.self) { index in
                                Button(action: {
                                    // Use withAnimation to synchronize all visual changes
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        routine.toggleItem(routine.items[index])
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: routine.completedItems.contains(routine.items[index]) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(routine.completedItems.contains(routine.items[index]) ? .primary : .gray)
                                            .animation(.easeInOut(duration: 0.3), value: routine.completedItems.contains(routine.items[index]))
                                        
                                        Text(routine.items[index])
                                            .strikethrough(routine.completedItems.contains(routine.items[index]))
                                            .foregroundColor(routine.completedItems.contains(routine.items[index]) ? .secondary : .primary)
                                            .animation(.easeInOut(duration: 0.3), value: routine.completedItems.contains(routine.items[index]))
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if index < routine.items.count {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            Button("Done") {
                dismissAction?()
            }
            .font(.headline)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color("Color1").opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    ZStack {
       // BackgroundView()
        RoutineView(
            selectedDate: Date(),
            routines: .constant([
                Routine(name: "Morning", icon: "sunrise.fill", items: ["Wake up", "Brush teeth", "Exercise"]),
                Routine(name: "Evening", icon: "moon.stars.fill", items: ["Read", "Meditate", "Sleep"]),
                Routine(name: "Afternoon", icon: "cloud.sun_fill", items: ["Lunch", "Walk", "Check email"]),
                Routine(name: "Workout", icon: "figure.walk", items: ["Warm up", "Run", "Stretch"])
            ]),
            showRoutineDetail: .constant(false),
            selectedRoutineIndex: .constant(nil)
        )
    }
}
