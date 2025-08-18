//
//  PlannerApp.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

@main
struct PlannerApp: App {
    @StateObject private var reviewManager = AppReviewManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // Increment launch count when app appears
                    reviewManager.incrementLaunchCount()
                }
                .sheet(isPresented: $reviewManager.shouldShowReviewPrompt) {
                    ReviewPromptView(reviewManager: reviewManager)
                        .interactiveDismissDisabled() // Prevents dismissing by swipe
                }
                .sheet(isPresented: $reviewManager.showingFeedbackSheet) {
                    FeedbackView()
                }
        }
    }
}
