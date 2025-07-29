import SwiftUI

struct HerbListView: View {
    @ObservedObject var dataService: DataService
    @StateObject private var coreDataManager = CoreDataManager.shared
    @StateObject private var healthProfile = HealthProfileManager.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedContinent: Continent?
    @State private var showingFilters = false
    @State private var showingFavorites = false
    
    let initialContinent: Continent?
    let initialCategory: HerbCategory?
    
    init(dataService: DataService, initialContinent: Continent? = nil, initialCategory: HerbCategory? = nil) {
        self.dataService = dataService
        self.initialContinent = initialContinent
        self.initialCategory = initialCategory
        // Initialize selectedContinent with the initial value
        self._selectedContinent = State(initialValue: initialContinent)
        // Initialize selectedCategory with the initial value
        self._selectedCategory = State(initialValue: initialCategory?.rawValue)
    }
    
    var filteredHerbs: [Herb] {
        dataService.filterHerbs(
            by: selectedCategory,
            by: selectedContinent?.rawValue,
            searchText: searchText
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filter Section
                    VStack(spacing: 16) {
                        // Search Bar
                        ModernSearchBar(text: $searchText)
                        
                        // Active Filters
                        if selectedCategory != nil || selectedContinent != nil {
                            ActiveFiltersView(
                                selectedCategory: $selectedCategory,
                                selectedContinent: $selectedContinent
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .background(Color(.systemBackground))
                    
                    // Content
                    if dataService.isLoading {
                        ModernLoadingView()
                    } else if let errorMessage = dataService.errorMessage {
                        ModernErrorView(message: errorMessage) {
                            dataService.fetchHerbs()
                        }
                    } else if filteredHerbs.isEmpty {
                        ModernEmptyStateView(searchText: searchText)
                    } else {
                        ModernHerbList(herbs: filteredHerbs, coreDataManager: coreDataManager)
                    }
                }
            }
            .navigationTitle("Herbs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ModernFilterButton {
                        showingFilters = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ModernFavoritesButton {
                        showingFavorites = true
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedCategory: $selectedCategory,
                    selectedContinent: $selectedContinent,
                    categories: dataService.getCategories()
                )
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
            .onAppear {
                if let initialContinent = initialContinent {
                    selectedContinent = initialContinent
                }
                if let initialCategory = initialCategory {
                    selectedCategory = initialCategory.rawValue
                }
            }
            .onChange(of: initialContinent) { newContinent in
                if let newContinent = newContinent {
                    selectedContinent = newContinent
                }
            }
        }
    }
}

// MARK: - Modern Search Bar
struct ModernSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search herbs, uses, or ailments...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Active Filters View
struct ActiveFiltersView: View {
    @Binding var selectedCategory: String?
    @Binding var selectedContinent: Continent?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = selectedCategory {
                    ModernFilterChip(text: category, icon: "tag.fill") {
                        selectedCategory = nil
                    }
                }
                
                if let continent = selectedContinent {
                    ModernFilterChip(text: continent.displayName, icon: "globe") {
                        selectedContinent = nil
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Modern Filter Chip
struct ModernFilterChip: View {
    let text: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.green.opacity(0.15))
        )
        .foregroundColor(.green)
    }
}

// MARK: - Modern Herb List
struct ModernHerbList: View {
    let herbs: [Herb]
    let coreDataManager: CoreDataManager
    @StateObject private var healthProfile = HealthProfileManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(herbs) { herb in
                    ModernHerbCard(
                        herb: herb,
                        coreDataManager: coreDataManager,
                        healthProfile: healthProfile
                    ) {
                        if coreDataManager.isFavorite(herb.id) {
                            coreDataManager.removeFromFavorites(herb.id)
                        } else {
                            coreDataManager.addToFavorites(herb)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Modern Herb Card
struct ModernHerbCard: View {
    let herb: Herb
    @ObservedObject var coreDataManager: CoreDataManager
    @ObservedObject var healthProfile: HealthProfileManager
    @StateObject private var localizationService = LocalizationService.shared
    let onFavoriteToggle: () -> Void
    
    @State private var showingDetail = false
    
    private var isFavorite: Bool {
        coreDataManager.isFavorite(herb.id)
    }
    
    private var hasSafetyWarnings: Bool {
        !healthProfile.checkHerbSafety(for: herb).isEmpty
    }
    
    // MARK: - Localization Properties
    private var localizedName: String {
        return localizationService.getLocalizedName(
            for: herb,
            userLocation: healthProfile.location,
            userLanguages: healthProfile.additionalLanguages
        )
    }
    
    private var hasLocalizedName: Bool {
        return localizedName != herb.englishName
    }
    
    private var localizedLanguageName: String? {
        return localizationService.getLocalizedLanguageName(
            for: herb,
            userLocation: healthProfile.location,
            userLanguages: healthProfile.additionalLanguages
        )
    }
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .top, spacing: 12) {
                    // Category Icon
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: categoryIcon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(categoryColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Always show English name as main title
                        Text(herb.englishName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(herb.scientificName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .italic()
                        
                        // Show localized name under scientific name if different from English
                        if hasLocalizedName {
                            if let languageName = localizedLanguageName {
                                Text("\(languageName) Name: \(localizedName)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            } else {
                                Text("Localized Name: \(localizedName)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        // Safety Warning Indicator
                        if hasSafetyWarnings {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        // Favorite Button
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(isFavorite ? .red : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Description
                Text(herb.description)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Uses
                if !herb.uses.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(herb.uses.prefix(4), id: \.self) { use in
                                Text(use)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Footer
                HStack {
                    // Continents
                    HStack(spacing: 4) {
                        ForEach(herb.continents.prefix(3), id: \.self) { continentCode in
                            if let continent = Continent(rawValue: continentCode) {
                                Text(continent.emoji)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        if herb.continents.count > 3 {
                            Text("+\(herb.continents.count - 3)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Category Badge
                    Text(herb.category)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(categoryColor.opacity(0.15))
                        )
                        .foregroundColor(categoryColor)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            HerbDetailView(herb: herb)
        }
    }
    
    private var categoryColor: Color {
        switch herb.category.lowercased() {
        case "refresher":
            return .blue
        case "herb":
            return .green
        case "spice":
            return .orange
        default:
            return .gray
        }
    }
    
    private var categoryIcon: String {
        switch herb.category.lowercased() {
        case "refresher":
            return "drop.fill"
        case "herb":
            return "leaf.fill"
        case "spice":
            return "flame.fill"
        default:
            return "circle.fill"
        }
    }
}

// MARK: - Modern Loading View
struct ModernLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.green)
            
            Text("Loading herbs...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Error View
struct ModernErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.system(size: 24, weight: .bold))
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Try Again") {
                retryAction()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.green)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Empty State View
struct ModernEmptyStateView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 50))
                .foregroundColor(.green.opacity(0.6))
            
            Text(searchText.isEmpty ? "No herbs found" : "No matching herbs")
                .font(.system(size: 20, weight: .semibold))
            
            Text(searchText.isEmpty ? "Try adjusting your filters" : "Try a different search term")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Filter Button
struct ModernFilterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                Text("Filters")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.green)
        }
    }
}

// MARK: - Modern Favorites Button
struct ModernFavoritesButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.red)
        }
    }
}

#Preview {
    HerbListView(dataService: DataService())
} 