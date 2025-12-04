import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var showingNewItem = false
    @StateObject private var plannerDataManager = PlannerDataManager.shared
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var healthAuthorizationRequested = false
    @State private var isHealthExpanded = false

    private func distanceString(from meters: Double) -> String {
        if Locale.current.measurementSystem == .metric {
            let km = Measurement(value: meters, unit: UnitLength.meters).converted(to: .kilometers).value
            return String(format: "%.2f km", km)
        } else {
            let miles = Measurement(value: meters, unit: UnitLength.meters).converted(to: .miles).value
            return String(format: "%.2f mi", miles)
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
                                .frame(height: 140)
                            
                            VStack(spacing: 0) {
                                Spacer(minLength: 8)
                                VStack(spacing: 12) {
                                    // Collapsed icon row (tappable)
                                    HStack {
                                        Image(systemName: "figure.walk")
                                        Spacer()
                                        Image(systemName: "figure.run")
                                        Spacer()
                                        Image(systemName: "figure.stand")
                                        Spacer()
                                        Image(systemName: "flame.fill")
                                        Spacer()
                                        Image(systemName: "clock")
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.title3)
                                    .foregroundStyle(.primary)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            isHealthExpanded.toggle()
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        Capsule()
                                            .fill(Color("BackgroundPopup"))
                                    )
                                    
                                    if isHealthExpanded {
                                        VStack(spacing: 0) {
                                            VStack(spacing: 12) {
                                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3), spacing: 12) {
                                                    HealthStatCard(title: "Steps", value: healthKitManager.todayStepCount.formatted(), systemImage: "figure.walk")
                                                    HealthStatCard(title: "Distance", value: distanceString(from: healthKitManager.todayDistanceMeters), systemImage: "figure.run")
                                                    HealthStatCard(title: "Stand", value: "\(healthKitManager.todayStandHours)/12 hr", systemImage: "figure.stand")
                                                    HealthStatCard(title: "Active", value: "\(Int(healthKitManager.todayActiveEnergy)) kcal", systemImage: "flame.fill")
                                                    HealthStatCard(title: "Exercise", value: "\(healthKitManager.todayExerciseMinutes) min", systemImage: "clock")
                                                    HealthStatCard(title: "HR Avg", value: healthKitManager.todayAverageHeartRate > 0 ? "\(healthKitManager.todayAverageHeartRate) bpm" : "--", systemImage: "heart.fill")
                                                }
                                            }
                                            .padding(16)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(Color("BackgroundPopup"))
                                            )
                                            .overlay(alignment: .top) {
                                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                                    .fill(Color("BackgroundPopup"))
                                                    .frame(width: 14, height: 14)
                                                    .rotationEffect(.degrees(45))
                                                    .offset(y: -7)
                                            }
                                        }
                                        .padding(.top, 8)
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                    }

                                }
                                //.padding(16)
                                //.background(
                                //    RoundedRectangle(cornerRadius: isHealthExpanded ? 16 : 999, style: .continuous)
                                //        .fill(Color("BackgroundPopup"))
                                //)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .animation(.easeInOut, value: isHealthExpanded)

                                ScheduleView(selectedDate: selectedDate)
                            }
                            .padding(.top, 8)
                        }
                        .ignoresSafeArea(edges: .top)
                    }

                    // Curved header on top
                    VStack(spacing: 0) {
                        HeaderView(selectedDate: $selectedDate)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(
                        // Curved bottom background for the header
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color("BackgroundPopup"))
                            .ignoresSafeArea(edges: [.top, .horizontal])
                            .frame(height: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0.0),
                                                .init(color: .black, location: 0.5),
                                                .init(color: .black, location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .ignoresSafeArea(edges: [.top, .horizontal])
                            )
                    )
                    .zIndex(1)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                // TODO: Handle floating action button tap
                showingNewItem = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
        }
        .onChange(of: selectedDate) { newDate in
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
