import SwiftUI
import CloudKit

struct iCloudRequiredView: View {
    @State private var iCloudAvailable = true
    @State private var checkingStatus = true
    
    var body: some View {
        VStack(spacing: 24) {
            if checkingStatus {
                ProgressView("Checking iCloud status...")
            } else if !iCloudAvailable {
                Image(systemName: "icloud.slash")
                    .resizable()
                    .frame(width: 60, height: 48)
                    .foregroundColor(.accentColor)
                Text("iCloud Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("To sync your data across devices, please enable iCloud for this app in Settings.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button(action: openSettings) {
                    Text("Open Settings")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
            } else {
                // iCloud is available, nothing to show
                EmptyView()
            }
        }
        .onAppear(perform: checkiCloudStatus)
    }
    
    private func checkiCloudStatus() {
        checkingStatus = true
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                self.checkingStatus = false
                self.iCloudAvailable = (status == .available)
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    iCloudRequiredView()
}
