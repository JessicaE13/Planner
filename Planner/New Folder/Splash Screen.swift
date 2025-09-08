//
//  Splash Screen.swift
//  Planner
//
//  Created by Jessica Estes on 9/7/25.
//

import SwiftUI

struct Splash_Screen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToValueScreen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Image("AppIconImage")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(16)
                    
                    Text("Congratulations")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text("Planning your best days just got easier!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToValueScreen = true
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(Color(.systemBackground))
                            .cornerRadius(24)
                            .padding(40)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToValueScreen) {
                ValueScreen1(currentStep: 0)
            }
        }
    }
}

#Preview {
    Splash_Screen()
}
