//
//  ValueScreen1.swift
//  Planner
//
//  Created by Jessica Estes on 9/7/25.
//

import SwiftUI

struct ValueScreen1: View {
    @State var currentStep: Int
    private let totalSteps = 5
    var body: some View {
        VStack {
            Spacer()
            Text("Add events and tasks to your schedule")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            Spacer()
            OnboardingProgressView(totalSteps: totalSteps, currentStep: currentStep)
            HStack {
                Spacer()
                NavigationLink(destination: ValueScreen2(currentStep: currentStep + 1)) {
                    Text("Next")
                        .font(.headline)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
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
    ValueScreen1(currentStep: 0)
}
