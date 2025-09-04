import SwiftUI
import CloudKit

struct CloudKitSyncView: View {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @StateObject private var plannerDataManager = PlannerDataManager.shared
    @State private var showingSyncAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // iCloud Status
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: cloudKitManager.isSignedInToiCloud ? "icloud.fill" : "icloud.slash")
                        .foregroundColor(cloudKitManager.isSignedInToiCloud ? .green : .red)
                    Text("iCloud Status")
                        .font(.headline)
                    Spacer()
                }
                
                Text(cloudKitManager.isSignedInToiCloud ? "Signed in to iCloud" : "Not signed in to iCloud")
                    .foregroundColor(.secondary)
                
                if !cloudKitManager.isSignedInToiCloud {
                    Text("Sign in to iCloud in Settings to enable sync")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Sync Status
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: cloudKitManager.isSyncing ? "arrow.triangle.2.circlepath" : "checkmark.circle")
                        .foregroundColor(cloudKitManager.isSyncing ? .blue : .green)
                        .rotationEffect(.degrees(cloudKitManager.isSyncing ? 360 : 0))
                        .animation(cloudKitManager.isSyncing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: cloudKitManager.isSyncing)
                    
                    Text("Sync Status")
                        .font(.headline)
                    Spacer()
                }
                
                Text(cloudKitManager.isSyncing ? "Syncing..." : "Ready to sync")
                    .foregroundColor(.secondary)
                
                if let error = cloudKitManager.syncError {
                    Text("Last sync error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Manual Sync Button
            Button(action: {
                Task {
                    await performSync()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Now")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(cloudKitManager.isSignedInToiCloud ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!cloudKitManager.isSignedInToiCloud || cloudKitManager.isSyncing)
            
            // Data Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Local Data")
                    .font(.headline)
                
                HStack {
                    Text("Routines:")
                    Spacer()
                    Text("\(plannerDataManager.routines.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Habits:")
                    Spacer()
                    Text("\(plannerDataManager.habits.count)")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("iCloud Sync")
        .alert("Sync Complete", isPresented: $showingSyncAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await cloudKitManager.checkiCloudStatus()
        }
    }
    
    private func performSync() async {
        await plannerDataManager.syncNow()
        
        await MainActor.run {
            if let error = cloudKitManager.syncError {
                alertMessage = "Sync failed: \(error)"
            } else {
                alertMessage = "Your data has been successfully synced with iCloud"
            }
            showingSyncAlert = true
        }
    }
}

#Preview {
    NavigationView {
        CloudKitSyncView()
    }
}