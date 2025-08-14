//
//  Untitled.swift
//  Planner
//
//  Created by Jessica Estes on 8/14/25.
//

import SwiftUI

struct ParagraphInputView: View {
    @State private var paragraphText: String = "This is a placeholder for your multi-line text. You can type paragraphs and new lines will be automatically handled."

    var body: some View {
        NavigationStack {
            VStack {
                Text("Enter your detailed description:")
                    .font(.headline)
                    .padding(.bottom)

                TextEditor(text: $paragraphText)
                    .frame(minHeight: 150) // Set a minimum height for the TextEditor
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Paragraph Input")
        }
    }
}


#Preview {
    ParagraphInputView()
}
