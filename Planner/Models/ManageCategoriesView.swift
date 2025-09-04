//
//  ManageCategoriesView.swift
//  Planner
//
//  Created by Assistant on 8/30/25.
//

import Foundation
import SwiftUI

// MARK: - Manage Categories View
struct ManageCategoriesView: View {
    @StateObject private var categoryManager = CategoryDataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "Color1"
    @State private var editingCategory: Category?
    
    private let availableColors = ["Color1", "Color2", "Color3", "Color4", "Color5", "Color6", "Color7"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Existing Categories")) {
                        ForEach(categoryManager.categories.indices, id: \.self) { index in
                            HStack {
                                Circle()
                                    .fill(Color(categoryManager.categories[index].color))
                                    .frame(width: 20, height: 20)
                                
                                Text(categoryManager.categories[index].name)
                                
                                Spacer()
                                
                                Button(action: {
                                    editingCategory = categoryManager.categories[index]
                                }) {
                                    Image(systemName: "pencil")
                                        //.foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Add New Category")) {
                        TextField("Category Name", text: $newCategoryName)
                        
                        HStack {
                            Text("Color")
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: {
                                        newCategoryColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(color))
                                            .frame(width: 25, height: 25)
                                            .overlay(
                                                Circle()
                                                    .stroke(newCategoryColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        Button("Add Category") {
                            addNewCategory()
                        }
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(
                category: category,
                onSave: { updatedCategory in
                    categoryManager.updateCategory(updatedCategory)
                    editingCategory = nil
                },
                onDelete: {
                    if let index = categoryManager.categories.firstIndex(where: { $0.id == category.id }) {
                        categoryManager.deleteCategory(at: index)
                    }
                    editingCategory = nil
                }
            )
        }
    }
    
    private func addNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = Category(name: trimmedName, color: newCategoryColor)
        categoryManager.addCategory(newCategory)
        newCategoryName = ""
        newCategoryColor = "Color1"
    }
}

// MARK: - Edit Category View
struct EditCategoryView: View {
    @State private var categoryName: String
    @State private var categoryColor: String
    let onSave: (Category) -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let availableColors = ["Color1", "Color2", "Color3", "Color4", "Color5", "Color6", "Color7"]
    private let originalCategory: Category
    
    init(category: Category, onSave: @escaping (Category) -> Void, onDelete: @escaping () -> Void) {
        self.originalCategory = category
        self._categoryName = State(initialValue: category.name)
        self._categoryColor = State(initialValue: category.color)
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPopup")
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Category Details")) {
                        TextField("Category Name", text: $categoryName)
                        
                        HStack {
                            Text("Color")
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: {
                                        categoryColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(color))
                                            .frame(width: 25, height: 25)
                                            .overlay(
                                                Circle()
                                                    .stroke(categoryColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button("Delete Category", role: .destructive) {
                            onDelete()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Create updated category with same ID
                        var updatedCategory = originalCategory
                        updatedCategory.name = categoryName
                        updatedCategory.color = categoryColor
                        onSave(updatedCategory)
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Manage Categories") {
    ManageCategoriesView()
}

#Preview("Edit Category") {
    EditCategoryView(
        category: Category.work,
        onSave: { _ in },
        onDelete: { }
    )
}
