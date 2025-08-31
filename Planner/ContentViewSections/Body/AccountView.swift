//
//  AccountView.swift
//  Planner
//
//  Created by Jessica Estes on 8/31/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userName: String = ""
    @State private var showingSavedConfirmation = false
    
    private let userNameKey = "userName"
    
    init() {
        // Load saved user name from UserDefaults
        let savedName = UserDefaults.standard.string(forKey: userNameKey) ?? ""
        _userName = State(initialValue: savedName)
    }
    
    private func saveUserName() {
        UserDefaults.standard.set(userName, forKey: userNameKey)
        showSavedConfirmation()
    }
    
    private func showSavedConfirmation() {
        showingSavedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingSavedConfirmation = false
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Manage your account information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Account Form
                    Form {
                        Section(header: Text("Personal Information")) {
                            HStack {
                                Text("Name")
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                TextField("Enter your name", text: $userName)
                                    .multilineTextAlignment(.trailing)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onChange(of: userName) { _, _ in
                                        saveUserName()
                                    }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if !userName.isEmpty {
                            Section {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Welcome back!")
                                            .font(.headline)
                                        Text(userName)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    
                    Spacer()
                    
                    // Saved confirmation
                    if showingSavedConfirmation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Changes saved")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showingSavedConfirmation)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body)
                    .fontWeight(.medium)
                }
            }
        }
    }
}

#Preview {
    AccountView()
}