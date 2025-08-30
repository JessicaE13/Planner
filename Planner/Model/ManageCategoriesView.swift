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
    @State private var showingEditSheet = false
    
    private let availableColors = ["Color1", "Color2", "Color3", "Color4", "Color5"]
    
    var body: some View {
        NavigationView {
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
                                showingEditSheet = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
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
                                        .frame(width: 30, height: 30)
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
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let category = editingCategory {
                EditCategoryView(
                    category: category,
                    onSave: { updatedCategory in
                        categoryManager.updateCategory(updatedCategory)
                        showingEditSheet = false
                        editingCategory = nil
                    },
                    onDelete: {
                        if let index = categoryManager.categories.firstIndex(where: { $0.id == category.id }) {
                            categoryManager.deleteCategory(at: index)
                        }
                        showingEditSheet = false
                        editingCategory = nil
                    }
                )
            }
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
    
    private let availableColors = ["Color1", "Color2", "Color3", "Color4", "Color5"]
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
                                        .frame(width: 30, height: 30)
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
