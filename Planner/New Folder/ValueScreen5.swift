//
//  ValueScreen5.swift
//  Planner
//
//  Created by Jessica Estes on 9/7/25.
//

import SwiftUI

struct ValueScreen5: View {
    @State var currentStep: Int
    private let totalSteps = 5
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Spacer()
            Text("You're ready to start planning!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            OnboardingProgressView(totalSteps: totalSteps, currentStep: currentStep)
            HStack {
                NavigationLink(destination: ValueScreen4(currentStep: currentStep - 1)) {
                    Text("Back")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                Spacer()
                NavigationLink(destination: ContentView()) {
                    Text("Finish")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
            
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ValueScreen5(currentStep: 4)
}
