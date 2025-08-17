//
//  Category.swift
//  Planner
//
//  Created by Assistant on 8/16/25.
//

import Foundation
import SwiftUI

// MARK: - Category Model
struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: String
    
    init(name: String, color: String = "Color1") {
        self.id = UUID()
        self.name = name
        self.color = color
    }
    
    // Pre-defined categories
    static let work = Category(name: "Work", color: "Color1")
    static let personal = Category(name: "Personal", color: "Color2")
    static let health = Category(name: "Health", color: "Color3")
    static let home = Category(name: "Home", color: "Color4")
    static let finance = Category(name: "Finance", color: "Color5")
    static let learning = Category(name: "Learning", color: "Color1")
    static let social = Category(name: "Social", color: "Color2")
    static let travel = Category(name: "Travel", color: "Color3")
    
    // Default categories
    static let defaultCategories: [Category] = [
        .work, .personal, .health, .home, .finance, .learning, .social, .travel
    ]
}

// MARK: - Category Data Manager
class CategoryDataManager: ObservableObject {
    @Published var categories: [Category] = []
    
    static let shared = CategoryDataManager()
    
    private init() {
        loadCategories()
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        categories.remove(at: index)
        saveCategories()
    }
    
    func getCategoryByName(_ name: String) -> Category? {
        return categories.first { $0.name == name }
    }
    
    private func saveCategories() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(categories)
            UserDefaults.standard.set(data, forKey: "Categories")
        } catch {
            print("Failed to save categories: \(error)")
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "Categories") {
            do {
                let decoder = JSONDecoder()
                categories = try decoder.decode([Category].self, from: data)
            } catch {
                print("Failed to load categories: \(error)")
                loadDefaultCategories()
            }
        } else {
            loadDefaultCategories()
        }
    }
    
    private func loadDefaultCategories() {
        categories = Category.defaultCategories
        saveCategories()
    }
}

// MARK: - Category Picker View
struct CategoryPickerView: View {
    @Binding var selectedCategory: Category?
    @StateObject private var categoryManager = CategoryDataManager.shared
    @State private var showingManageCategories = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Category")
                    .font(.headline)
                
                Spacer()
                
                Button("Manage") {
                    showingManageCategories = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                // None option
                Button(action: {
                    selectedCategory = nil
                }) {
                    Text("None")
                        .font(.body)
                        .foregroundColor(selectedCategory == nil ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedCategory == nil ? Color.gray : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Category options
                ForEach(categoryManager.categories) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.name)
                            .font(.body)
                            .foregroundColor(selectedCategory?.id == category.id ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedCategory?.id == category.id ? Color(category.color) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .lineLimit(1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showingManageCategories) {
            ManageCategoriesView()
        }
    }
}

// MARK: - Manage Categories View
struct ManageCategoriesView: View {
    @StateObject private var categoryManager = CategoryDataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newCategoryName = ""
    @State private var newCategoryColor = "Color1"
    
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
                            
                            Button("Delete") {
                                categoryManager.deleteCategory(at: index)
                            }
                            .foregroundColor(.red)
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
    }
    
    private func addNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = Category(name: trimmedName, color: newCategoryColor)
        categoryManager.addCategory(newCategory)
        
        // Reset form
        newCategoryName = ""
        newCategoryColor = "Color1"
    }
}
