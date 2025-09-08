//
//  ValueScreen3.swift
//  Planner
//
//  Created by Jessica Estes on 9/7/25.
//

import SwiftUI

struct ValueScreen3: View {
    @State var currentStep: Int
    private let totalSteps = 5
    var body: some View {
        VStack {
            Spacer()
            Text("Add morning and evening routin")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            OnboardingProgressView(totalSteps: totalSteps, currentStep: currentStep)
            HStack {
                NavigationLink(destination: ValueScreen2(currentStep: currentStep - 1)) {
                    Text("Back")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                Spacer()
                NavigationLink(destination: ValueScreen4(currentStep: currentStep + 1)) {
                    Text("Next")
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
    ValueScreen3(currentStep: 2)
}
