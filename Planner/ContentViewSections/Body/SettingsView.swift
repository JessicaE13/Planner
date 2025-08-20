//
//  SettingsView.swift
//  Planner
//
//  Created by Jessica Estes on 8/12/25.
//

import SwiftUI

struct SettingsView: View {
    // Function to open URLs
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundPopup")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Settings List
                Form {
                    Section {
                        SettingsRow(
                            icon: "person.circle.fill",
                            title: "Account",
                            action: {
                                // Account action
                            }
                        )
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            action: {
                                // Notifications action
                            }
                        )
                    }
                    
                    Section {
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms and Conditions",
                            action: {
                                openURL("https://github.com")
                            }
                        )
                        SettingsRow(
                            icon: "lock.fill",
                            title: "Privacy Policy",
                            action: {
                                openURL("https://github.com")
                            }
                        )
                    }
                    
                    Section {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "About",
                            showChevron: false,
                            action: nil
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(icon: String, title: String, showChevron: Bool = true, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
                
                // Content
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4) // Reduced vertical padding for compact row height
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview {
    SettingsView()
}
