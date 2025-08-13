//
//  BackgroundView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct BackgroundView: View {
    
    var topColor: Color = .orange.opacity(0.2075)
    var middleColor: Color = .pink.opacity(0.2075)
    var bottomColor: Color = .purple.opacity(0.2075)
    
    var body: some View {
//        LinearGradient(gradient: Gradient(colors: [topColor, middleColor, bottomColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
//            .edgesIgnoringSafeArea(.all)
        
        Color("Background").opacity(0.2)
            .edgesIgnoringSafeArea(.all)
            
        
        
    }
}

#Preview {
    BackgroundView()
}
