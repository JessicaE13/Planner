//
//  ScheduleView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct ScheduleView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Schedule")
                
                Spacer()
                
                Image(systemName: "ellipsis")
            }
            
            VStack {
                HStack {
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color1"))
                            .frame(width: 50, height: 75)
                        
                        Image(systemName: "figure.yoga")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    
                    Text("Yoga Class")
                        .font(.body)
                    
                    Image(systemName: "repeat")
                        .foregroundColor(Color("Color1"))
                    
                    Spacer()
                }
                
                
                HStack {
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color2"))
                            .frame(width: 50, height: 75)
                        
                        Image(systemName: "figure.walk")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    
                    Text("Morning Walk")
                        .font(.body)
                    
                    //  Image(systemName: "repeat")
                       // .foregroundColor(Color("Color2"))
                    Spacer()
                }
                HStack {
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("Color3"))
                            .frame(width: 50, height: 75)
                        
                        Image(systemName: "person.3.fill")
                    }
                    Text("12:00 PM")
                        .font(.body)
                        .foregroundColor(Color.gray)
                    
                    Text("Team Meeting")
                        .font(.body)
                    
                    Image(systemName: "repeat")
                        .foregroundColor(Color("Color3"))
                    
                    Spacer()
                }
               
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ZStack {
        BackgroundView()
        ScheduleView()
    }
}
