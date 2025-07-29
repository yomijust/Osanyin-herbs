import SwiftUI

struct HeroView: View {
    @ObservedObject private var dataService = DataService.shared
    @Binding var selectedContinent: Continent?
    @Binding var selectedCategory: HerbCategory?
    @State private var showingHerbList = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // App Title
                        VStack(spacing: 8) {
                            Text("🌿")
                                .font(.system(size: 60))
                            
                            Text("Osanyin")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Herbal Remedy Guide")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Description
                        Text("Discover traditional herbs and natural refreshers from around the world")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 30)
                        
                        // Category Selection
                        VStack(spacing: 12) {
                            Text("Select a Category")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(HerbCategory.allCases, id: \.self) { category in
                                    CategoryCard(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        herbCount: dataService.getHerbsByCategory(category.rawValue).count
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Continent Selection
                        VStack(spacing: 15) {
                            Text("Select a Continent")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(Continent.allCases.filter { $0 != .antarctica }, id: \.self) { continent in
                                    ContinentCard(
                                        continent: continent,
                                        isSelected: selectedContinent == continent,
                                        herbCount: dataService.getHerbsByContinent(continent).count
                                    ) {
                                        selectedContinent = continent
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Selection Notifications
                        if selectedCategory != nil || selectedContinent != nil {
                            VStack(spacing: 8) {
                                if selectedCategory != nil {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("\(selectedCategory?.displayName ?? "") selected")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                    }
                                }
                                
                                if selectedContinent != nil {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("\(selectedContinent?.displayName ?? "") selected")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("Go to Herbs tab →")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                            .padding(.horizontal, 30)
                        }
                        
                        // Explore All Button
                        Button(action: {
                            showingHerbList = true
                        }) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                Text("Explore All Herbs")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal, 30)
                        
                        // Bottom spacing
                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingHerbList) {
                HerbListView(dataService: dataService)
            }
            .onChange(of: selectedContinent) { continent in
                // Continent selection is now handled by the MainTabView
                // User can navigate to Herbs tab to see filtered results
            }
        }
    }
}

struct ContinentCard: View {
    let continent: Continent
    let isSelected: Bool
    let herbCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(continent.emoji)
                    .font(.system(size: 32))
                
                Text(continent.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(herbCount) herbs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryCard: View {
    let category: HerbCategory
    let isSelected: Bool
    let herbCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(category.emoji)
                    .font(.system(size: 24))
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(herbCount) items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HeroView(selectedContinent: .constant(nil), selectedCategory: .constant(nil))
} 