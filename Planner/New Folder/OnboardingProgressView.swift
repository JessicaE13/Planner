import SwiftUI

struct OnboardingProgressView: View {
    let totalSteps: Int
    let currentStep: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \ .self) { index in
                Circle()
                    .fill(index == currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    OnboardingProgressView(totalSteps: 5, currentStep: 2)
}
