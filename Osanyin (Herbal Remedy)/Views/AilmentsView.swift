import SwiftUI

struct AilmentsView: View {
    @ObservedObject var dataService = DataService.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var searchText = ""
    @State private var selectedAilment: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                AilmentsSearchBar(text: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if dataService.isLoading {
                    ModernLoadingView()
                } else if let errorMessage = dataService.errorMessage, !errorMessage.isEmpty {
                    ModernErrorView(message: errorMessage) {
                        dataService.fetchHerbs()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAilments, id: \.self) { ailment in
                                AilmentCard(
                                    ailment: ailment,
                                    herbs: herbsForAilment(ailment),
                                    isExpanded: selectedAilment == ailment,
                                    coreDataManager: coreDataManager
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if selectedAilment == ailment {
                                            selectedAilment = nil
                                        } else {
                                            selectedAilment = ailment
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Ailments")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var filteredAilments: [String] {
        let allAilments = Set(dataService.herbs.flatMap { $0.ailments })
        let sortedAilments = Array(allAilments).sorted()
        
        if searchText.isEmpty {
            return sortedAilments
        } else {
            return sortedAilments.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func herbsForAilment(_ ailment: String) -> [Herb] {
        return dataService.herbs.filter { herb in
            herb.ailments.contains { $0.localizedCaseInsensitiveContains(ailment) }
        }
    }
}

// MARK: - Ailment Card
struct AilmentCard: View {
    let ailment: String
    let herbs: [Herb]
    let isExpanded: Bool
    let coreDataManager: CoreDataManager
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ailment)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text("\(herbs.count) herb\(herbs.count == 1 ? "" : "s") available")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(isExpanded ? 0 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        
                        Text("\(herbs.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(herbs) { herb in
                        HerbAilmentRow(
                            herb: herb,
                            coreDataManager: coreDataManager
                        ) {
                            if coreDataManager.isFavorite(herb.id) {
                                coreDataManager.removeFromFavorites(herb.id)
                            } else {
                                coreDataManager.addToFavorites(herb)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Herb Ailment Row
struct HerbAilmentRow: View {
    let herb: Herb
    @ObservedObject var coreDataManager: CoreDataManager
    let onFavoriteToggle: () -> Void
    @State private var showingDetail = false
    
    private var isFavorite: Bool {
        coreDataManager.isFavorite(herb.id)
    }
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(categoryColor(for: herb.category))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: categoryIcon(for: herb.category))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Herb Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(herb.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(herb.scientificName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Continent Badge
                if !herb.continents.isEmpty {
                    HStack(spacing: 4) {
                        if let firstContinent = herb.continents.first,
                           let continent = Continent(rawValue: firstContinent) {
                            Text(continent.emoji)
                                .font(.system(size: 12))
                            
                            Text(continent.displayName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
                }
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFavorite ? .red : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            HerbDetailView(herb: herb)
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "herb":
            return .green
        case "refresher":
            return .blue
        case "spice":
            return .orange
        case "fruit":
            return .red
        case "vegetable":
            return .purple
        default:
            return .gray
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "herb":
            return "leaf.fill"
        case "refresher":
            return "drop.fill"
        case "spice":
            return "flame.fill"
        case "fruit":
            return "applelogo"
        case "vegetable":
            return "carrot.fill"
        default:
            return "leaf"
        }
    }
}

// MARK: - Ailments Search Bar
struct AilmentsSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search ailments...", text: $text)
                .font(.system(size: 16, weight: .regular))
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
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

#Preview {
    AilmentsView()
} 