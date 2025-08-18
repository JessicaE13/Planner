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
            BackgroundView()
            
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
                .padding()
                
                // Settings List
                ScrollView {
                    VStack(spacing: 16) {
                        // Account Section
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                
                                VStack(spacing: 0) {
                                    SettingsRow(
                                        icon: "person.circle.fill",
                                        title: "Account",
                                        action: {
                                            // Account action
                                        }
                                    )
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    SettingsRow(
                                        icon: "bell.fill",
                                        title: "Notifications",
                                        action: {
                                            // Notifications action
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Legal Section
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                
                                VStack(spacing: 0) {
                                    SettingsRow(
                                        icon: "doc.text.fill",
                                        title: "Terms and Conditions",
                                        action: {
                                            openURL("https://github.com")
                                        }
                                    )
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    SettingsRow(
                                        icon: "hand.raised.fill",
                                        title: "Privacy Policy",
                                        action: {
                                            openURL("https://github.com")
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // App Info Section
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                
                                VStack(spacing: 0) {
                                    SettingsRow(
                                        icon: "info.circle.fill",
                                        title: "About",
                                        showChevron: false,
                                        action: nil
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
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
                    .foregroundColor(.blue)
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
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview {
    SettingsView()
}
