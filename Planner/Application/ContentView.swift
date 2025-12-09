import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showingNewItem = false
    @StateObject private var plannerDataManager = PlannerDataManager.shared
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var healthAuthorizationRequested = false
    @State private var swipeHaptic = UIImpactFeedbackGenerator(style: .light)

    private func distanceString(from meters: Double) -> String {
        if Locale.current.measurementSystem == .metric {
            let km = Measurement(value: meters, unit: UnitLength.meters).converted(to: .kilometers).value
            return String(format: "%.2f km", km)
        } else {
            let miles = Measurement(value: meters, unit: UnitLength.meters).converted(to: .miles).value
            return String(format: "%.2f mi", miles)
        }
    }
    
    private func stepsFormatted(_ steps: Int) -> String {
        if steps >= 1000 {
            let value = Double(steps) / 1000.0
            return String(format: "%.1fk", value)
        } else {
            return "\(steps)"
        }
    }

    private func distanceShortString(from meters: Double) -> String {
        if Locale.current.measurementSystem == .metric {
            let km = Measurement(value: meters, unit: UnitLength.meters).converted(to: .kilometers).value
            return String(format: "%.1f km", km)
        } else {
            let miles = Measurement(value: meters, unit: UnitLength.meters).converted(to: .miles).value
            return String(format: "%.1f mi", miles)
        }
    }
    
    private func sleepDurationString(from seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%d:%02d h", hours, minutes)
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = newDate
            }
            swipeHaptic.impactOccurred()
        }
    }
    
    var body: some View {
        ZStack {
//            Color("BackgroundPopup")
//                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    // Scrollable content underneath header
                    ScrollView {
                        VStack(spacing: 0) {
                            // Top spacer to allow content to scroll under the curved header
                            Color.clear
                                .frame(height: 170)
                            
                            VStack(spacing: 0) {
                                Spacer(minLength: 8)
                                VStack(spacing: 12) {
                                    // Activity bar with icons; simplified (no expand/collapse)
                                    HStack(spacing: 16) {
                                        // Sleep (real data)
                                        HStack(spacing: 6) {
                                            Image(systemName: "bed.double.fill")
                                            Text(sleepDurationString(from: healthKitManager.todaySleepDuration))
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .layoutPriority(1)

                                        // Steps
                                        HStack(spacing: 6) {
                                            Image(systemName: "figure.walk")
                                            Text("\(stepsFormatted(healthKitManager.todayStepCount)) steps")
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .layoutPriority(1)

                                        // Distance
                                        HStack(spacing: 6) {
                                            Image(systemName: "figure.run")
                                            Text(distanceShortString(from: healthKitManager.todayDistanceMeters))
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .layoutPriority(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 16) // Left/right padding equals spacing
                                    .padding(.vertical, 16)
                                    .contentShape(Rectangle())
                                    .font(.title3)
                                    .foregroundStyle(.primary)
                                    .background(
                                        Capsule()
                                            .fill(Color("Background"))
                                    )
                                    .frame(maxWidth: 360)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                //.padding(16)
                                
                                //.background(
                                //    RoundedRectangle(cornerRadius: isHealthExpanded ? 16 : 999, style: .continuous)
                                //        .fill(Color("BackgroundPopup"))
                                //)
                                .padding(.horizontal)
                                .padding(.vertical, 8)

                                ScheduleView(selectedDate: selectedDate)
                            }
                            .contentShape(Rectangle())
                        }
                        .ignoresSafeArea(edges: .top)
                        .contentShape(Rectangle())
//                        .highPriorityGesture(
//                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
//                                .onEnded { value in
//                                    let horizontal = value.translation.width
//                                    let vertical = abs(value.translation.height)
//                                    // Prefer horizontal intent
//                                    guard abs(horizontal) > 30, vertical < 50 else { return }
//                                    if horizontal < 0 {
//                                        changeDate(by: 1)
//                                    } else {
//                                        changeDate(by: -1)
//                                    }
//                                }
//                        )
                    }

                    // Curved header on top
                    VStack(spacing: 0) {
                        HeaderView(selectedDate: $selectedDate)
                            .padding(.top, 8)
                            .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(
                        // Curved bottom background for the header
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color("BackgroundPopup"))
                            .ignoresSafeArea(edges: [.top, .horizontal])
                    )
                    .zIndex(1)
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded { value in
                                let horizontal = value.translation.width
                                let vertical = abs(value.translation.height)
                                guard abs(horizontal) > 30, vertical < 50 else { return }
                                if horizontal < 0 {
                                    changeDate(by: 1)
                                } else {
                                    changeDate(by: -1)
                                }
                            }
                    )
                }
            }
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = abs(value.translation.height)
                    guard abs(horizontal) > 30, vertical < 50 else { return }
                    if horizontal < 0 {
                        changeDate(by: 1)
                    } else {
                        changeDate(by: -1)
                    }
                }
        )
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                // TODO: Handle floating action button tap
                showingNewItem = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color("Background"))
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showingNewItem) {
            NewScheduleItemView(
                selectedDate: selectedDate,
                onSave: { newItem in
                    UnifiedDataManager.shared.addItem(newItem)
                    showingNewItem = false
                }
            )
            // Make the sheet open very compact and only grow to large when necessary
            .presentationDetents([
                .fraction(0.18), // roughly ~18% of the screen height to avoid large negative space
                .large
            ])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationSizing(.fitted)
        }
        .onChange(of: selectedDate) { _, newDate in
            Task {
                do {
                    try await healthKitManager.fetchMetrics(for: newDate)
                } catch {
                    print("Fetching metrics for date failed: \(error)")
                }
            }
        }
        .onAppear {
            Task {
                // Check iCloud status and perform initial sync
                await cloudKitManager.checkiCloudStatus()
                if cloudKitManager.isSignedInToiCloud {
                    do {
                        try await plannerDataManager.performInitialSync()
                    } catch {
                        print("Initial sync failed: \(error)")
                    }
                }

                // Request HealthKit authorization once and fetch today's metrics
                if !healthAuthorizationRequested {
                    do {
                        try await healthKitManager.requestAuthorization()
                        try await healthKitManager.fetchMetrics(for: selectedDate)
                        healthAuthorizationRequested = true
                    } catch {
                        print("HealthKit auth/fetch failed: \(error)")
                    }
                } else {
                    // Refresh metrics on subsequent appears
                    do {
                        try await healthKitManager.fetchMetrics(for: selectedDate)
                    } catch {
                        print("Fetching steps failed: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}

#Preview {
    ContentView()
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .fontWeight(.semibold)
            //.kerning(2)
            //.textCase(.uppercase)
            .foregroundColor(.primary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}

struct HealthStatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.clear)
        )
    }
}
