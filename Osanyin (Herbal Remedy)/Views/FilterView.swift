import SwiftUI

struct FilterView: View {
    @Binding var selectedCategory: String?
    @Binding var selectedContinent: Continent?
    let categories: [String]
    let dataService: DataService
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Categories Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Categories")
                            .font(.headline)
                        Spacer()
                        Text("(\(getTotalFilteredCount()) herbs)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            FilterOptionCard(
                                title: category,
                                count: getCategoryCount(category),
                                isSelected: selectedCategory == category
                            ) {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Continents Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Continents")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                        ForEach(Continent.allCases.filter { $0 != .antarctica }, id: \.self) { continent in
                            FilterOptionCard(
                                title: continent.displayName,
                                subtitle: continent.emoji,
                                count: getContinentCount(continent),
                                isSelected: selectedContinent == continent
                            ) {
                                if selectedContinent == continent {
                                    selectedContinent = nil
                                } else {
                                    selectedContinent = continent
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Clear All Filters") {
                        selectedCategory = nil
                        selectedContinent = nil
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("Apply Filters") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Filters")
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
    
    // MARK: - Helper Methods
    private func getCategoryCount(_ category: String) -> Int {
        return dataService.getHerbsByCategory(category).count
    }
    
    private func getContinentCount(_ continent: Continent) -> Int {
        return dataService.getHerbsByContinent(continent).count
    }
    
    private func getTotalFilteredCount() -> Int {
        var filteredHerbs = dataService.herbs
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            filteredHerbs = filteredHerbs.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        }
        
        // Apply continent filter
        if let selectedContinent = selectedContinent {
            filteredHerbs = filteredHerbs.filter { $0.continents.contains(selectedContinent.rawValue) }
        }
        
        return filteredHerbs.count
    }
}

struct FilterOptionCard: View {
    let title: String
    let subtitle: String?
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, count: Int = 0, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.title2)
                }
                
                HStack(spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("(\(count))")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FilterView(
        selectedCategory: .constant(nil),
        selectedContinent: .constant(nil),
        categories: ["Herb", "Refresher", "Spice"],
        dataService: DataService.shared
    )
} 