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
    var icon: String
    
    init(name: String, color: String = "Color1", icon: String = "folder") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.icon = icon
    }
    
    // Pre-defined categories
    static let work = Category(name: "Work", color: "Color1", icon: "briefcase")
    static let personal = Category(name: "Personal", color: "Color2", icon: "person")
    static let health = Category(name: "Health", color: "Color3", icon: "heart")
    static let home = Category(name: "Home", color: "Color4", icon: "house")
    static let finance = Category(name: "Finance", color: "Color5", icon: "dollarsign.circle")
    static let learning = Category(name: "Learning", color: "Color1", icon: "book")
    static let social = Category(name: "Social", color: "Color2", icon: "person.2")
    static let travel = Category(name: "Travel", color: "Color3", icon: "airplane")
    
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                // None option
                Button(action: {
                    selectedCategory = nil
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                            .foregroundColor(selectedCategory == nil ? .white : .gray)
                            .frame(width: 40, height: 40)
                            .background(selectedCategory == nil ? Color.gray : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("None")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Category options
                ForEach(categoryManager.categories) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundColor(selectedCategory?.id == category.id ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(selectedCategory?.id == category.id ? Color(category.color) : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            
                            Text(category.name)
                                .font(.caption2)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
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
    @State private var newCategoryIcon = "folder"
    
    private let availableColors = ["Color1", "Color2", "Color3", "Color4", "Color5"]
    private let availableIcons = [
        "folder", "briefcase", "person", "heart", "house", "dollarsign.circle",
        "book", "person.2", "airplane", "car", "gamecontroller", "music.note",
        "camera", "paintbrush", "wrench", "star", "flag", "bell"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Existing Categories")) {
                    ForEach(categoryManager.categories.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: categoryManager.categories[index].icon)
                                .foregroundColor(Color(categoryManager.categories[index].color))
                                .frame(width: 30)
                            
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
                    
                    HStack {
                        Text("Icon")
                        Spacer()
                        
                        Picker("", selection: $newCategoryIcon) {
                            ForEach(availableIcons, id: \.self) { icon in
                                HStack {
                                    Image(systemName: icon)
                                    Text(icon)
                                }.tag(icon)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
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
        
        let newCategory = Category(name: trimmedName, color: newCategoryColor, icon: newCategoryIcon)
        categoryManager.addCategory(newCategory)
        
        // Reset form
        newCategoryName = ""
        newCategoryColor = "Color1"
        newCategoryIcon = "folder"
    }
}
