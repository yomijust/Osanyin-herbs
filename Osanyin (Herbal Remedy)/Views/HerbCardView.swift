import SwiftUI

struct HerbCardView: View {
    let herb: Herb
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    @StateObject private var healthProfile = HealthProfileManager.shared
    @StateObject private var localizationService = LocalizationService.shared
    @State private var showingDetail = false
    
    // MARK: - Computed Properties
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
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with name and favorite button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Always show English name as main title
                        Text(herb.englishName)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(herb.scientificName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                        
                        // Show localized name under scientific name if different from English
                        if hasLocalizedName {
                            Text("Localized Name: \(localizedName)")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onFavoriteToggle) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Description
                Text(herb.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                // Category and continents
                HStack {
                    CategoryBadge(category: herb.category)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(herb.continents.prefix(2), id: \.self) { continentCode in
                            if let continent = Continent(rawValue: continentCode) {
                                Text(continent.emoji)
                                    .font(.caption)
                            }
                        }
                        
                        if herb.continents.count > 2 {
                            Text("+\(herb.continents.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Uses
                if !herb.uses.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(herb.uses.prefix(3), id: \.self) { use in
                                Text(use)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            HerbDetailView(herb: herb)
        }
    }
}

struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        switch category.lowercased() {
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
}

#Preview {
    HerbCardView(
        herb: Herb(
            id: "test",
            englishName: "Hibiscus Tea",
            localNames: ["NG": "Zobo"],
            scientificName: "Hibiscus sabdariffa",
            description: "A tangy herbal drink made from dried hibiscus petals, known for its refreshing taste and potential health benefits.",
            uses: ["Refreshment", "Blood pressure", "Antioxidant"],
            category: "Refresher",
            vitamins: ["C", "B1"],
            nutrition: Nutrition(calories: 5, carbs: 1.2),
            ailments: ["Hypertension", "Fatigue"],
            locations: ["West Africa", "Tropics"],
            preparation: "Boil dried petals in water for 10-15 minutes",
            dosage: "1-2 cups daily",
            precautions: "Avoid during pregnancy",
            honeyUsage: "Common sweetener",
            continents: ["AF"],
            wikipediaUrl: "https://en.wikipedia.org/wiki/Hibiscus_tea"
        ),
        isFavorite: false
    ) {
        // Favorite toggle action
    }
    .padding()
} 