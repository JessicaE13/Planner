//
//  RoutinesView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct RoutineView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Routines")

                Spacer()
                
                Image(systemName: "ellipsis")
            }
            
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 150, height: 100)
                    VStack {
                        HStack {
                            
                            Image(systemName: "sunrise")
                            
                            VStack(alignment: .leading) {
                                
                                Text("Morning")
                                    .font(.callout)
                                Text("Routine")
                                    .font(.caption)
                                    
                                
                            }
                        }
                        ProgressView(value: 0.7, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("Color1")))
                            .frame(width: 100)
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 100, height: 100)
            }
            
            
        }
        .padding()
    }
}

#Preview {
    ZStack {
        BackgroundView()
        RoutineView()
    }
}
