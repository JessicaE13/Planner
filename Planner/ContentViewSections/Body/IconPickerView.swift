//
//  IconPickerView.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private let iconDataSource = IconDataSource.shared
    
    private var filteredCategories: [IconCategory] {
        iconDataSource.getFilteredCategories(searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search icons...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    // Icons grid
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                            ForEach(filteredCategories, id: \.name) { category in
                                Section {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                        ForEach(category.icons, id: \.name) { iconItem in
                                            Button(action: {
                                                selectedIcon = iconItem.name
                                                dismiss()
                                            }) {
                                                VStack(spacing: 8) {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(selectedIcon == iconItem.name ? Color("Color2") : Color.clear)
                                                            .frame(width: 60, height: 60)
                                                        
                                                        Image(systemName: iconItem.name)
                                                            .font(.system(size: 24))
                                                            .foregroundColor(selectedIcon == iconItem.name ? .white : .primary)
                                                    }
                                                    
                                                    Text(iconItem.displayName)
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.center)
                                                        .lineLimit(2)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                } header: {
                                    HStack {
                                        Text(category.name)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color("BackgroundPopup"))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("calendar"))
}
