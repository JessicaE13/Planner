//
//  AppReviewManager.swift
//  Planner
//
//  App review and feedback system
//

import SwiftUI
import StoreKit
import MessageUI

// MARK: - App Review Manager
class AppReviewManager: ObservableObject {
    static let shared = AppReviewManager()
    
    @Published var shouldShowReviewPrompt = false
    @Published var showingFeedbackSheet = false
    
    private let launchCountKey = "AppLaunchCount"
    private let hasShownReviewPromptKey = "HasShownReviewPrompt"
    private let reviewPromptThreshold = 15
    
    private init() {}
    
    func incrementLaunchCount() {
        let currentCount = UserDefaults.standard.integer(forKey: launchCountKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: launchCountKey)
        
        print("App launch count: \(newCount)")

        checkForReviewPrompt(launchCount: newCount)
    }
    
    private func checkForReviewPrompt(launchCount: Int) {
        let hasShownPrompt = UserDefaults.standard.bool(forKey: hasShownReviewPromptKey)
        
        if launchCount >= reviewPromptThreshold && !hasShownPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.shouldShowReviewPrompt = true
            }
        }
    }
    
    @MainActor
    func handleLoveResponse() {
        // User loves the app - request App Store review
        markReviewPromptAsShown()
        requestAppStoreReview()
    }
    
    func handleDislikeResponse() {
        // User doesn't love the app - show feedback form
        markReviewPromptAsShown()
        showingFeedbackSheet = true
    }
    
    func dismissReviewPrompt() {
        markReviewPromptAsShown()
        shouldShowReviewPrompt = false
    }
    
    private func markReviewPromptAsShown() {
        UserDefaults.standard.set(true, forKey: hasShownReviewPromptKey)
        shouldShowReviewPrompt = false
    }
    
    @MainActor
    private func requestAppStoreReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func resetReviewPrompt() {
        UserDefaults.standard.removeObject(forKey: launchCountKey)
        UserDefaults.standard.removeObject(forKey: hasShownReviewPromptKey)
        shouldShowReviewPrompt = false
        showingFeedbackSheet = false
    }
    
    func getCurrentLaunchCount() -> Int {
        return UserDefaults.standard.integer(forKey: launchCountKey)
    }
}

// MARK: - Review Prompt View
struct ReviewPromptView: View {
    @ObservedObject var reviewManager: AppReviewManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            VStack(spacing: 16) {
                Text("Loving Planner?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We'd love to hear from you! Your feedback helps us make Planner even better.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    reviewManager.handleLoveResponse()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Yes, I love it!")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    reviewManager.handleDislikeResponse()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Not quite, I have feedback")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    reviewManager.dismissReviewPrompt()
                    dismiss()
                }) {
                    Text("Maybe later")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var userEmail = ""
    @State private var showingMailComposer = false
    @State private var showingEmailAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Help us improve Planner")) {
                    Text("We value your feedback! Please let us know what we can do better.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Your Email (Optional)")) {
                    TextField("your.email@example.com", text: $userEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Your Feedback")) {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 120)
                }
                
                Section {
                    Button(action: {
                        sendFeedback()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Feedback")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["feedback@yourapp.com"], // Replace with your email
                subject: "Planner App Feedback",
                messageBody: createEmailBody(),
                isShowing: $showingMailComposer
            )
        }
        .alert("Email Not Available", isPresented: $showingEmailAlert) {
            Button("Copy to Clipboard") {
                copyFeedbackToClipboard()
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Mail is not available on this device. Your feedback has been copied to the clipboard. Please paste it into your preferred email app and send to feedback@yourapp.com")
        }
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            showingEmailAlert = true
        }
    }
    
    private func createEmailBody() -> String {
        var body = "Feedback from Planner App User\n\n"
        body += "Feedback:\n\(feedbackText)\n\n"
        
        if !userEmail.isEmpty {
            body += "User Email: \(userEmail)\n\n"
        }
        
        body += "---\n"
        body += "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n"
        body += "iOS Version: \(UIDevice.current.systemVersion)\n"
        body += "Device: \(UIDevice.current.model)\n"
        
        return body
    }
    
    private func copyFeedbackToClipboard() {
        let emailBody = createEmailBody()
        UIPasteboard.general.string = emailBody
    }
}

// MARK: - Mail Composer Wrapper
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
        }
    }
}

// MARK: - Testing/Debug View (Optional)
struct ReviewManagerDebugView: View {
    @StateObject private var reviewManager = AppReviewManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Review Manager Debug")
                .font(.title)
            
            Text("Current Launch Count: \(reviewManager.getCurrentLaunchCount())")
                .font(.body)
            
            Button("Simulate App Launch") {
                reviewManager.incrementLaunchCount()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Reset Review Prompt") {
                reviewManager.resetReviewPrompt()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Force Show Review Prompt") {
                reviewManager.shouldShowReviewPrompt = true
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
