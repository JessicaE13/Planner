import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @State private var searchText: String
    @Environment(\.dismiss) private var dismiss
    
    private let iconDataSource = IconDataSource.shared
    
    init(selectedIcon: Binding<String>, initialSearchText: String = "") {
        self._selectedIcon = selectedIcon
        self._searchText = State(initialValue: initialSearchText)
    }
    
    private var filteredCategories: [IconCategory] {
        iconDataSource.getFilteredCategories(searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                SearchBar(text: $searchText)
                    .padding()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(filteredCategories, id: \.name) { category in
                            Section {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                    ForEach(category.icons, id: \.name) { iconItem in
                                        IconButton(
                                            iconItem: iconItem,
                                            isSelected: selectedIcon == iconItem.name,
                                            onTap: {
                                                selectedIcon = iconItem.name
                                                dismiss()
                                            }
                                        )
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
                            }
                            .background(Color("Background2"))
                        }
                    }
                }
            }
            .background(Color("Background2"))
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    IconPickerView(selectedIcon: .constant("sunrise.fill"))
}
