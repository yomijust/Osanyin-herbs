import Foundation

// MARK: - Herb Categories
enum HerbCategory: String, CaseIterable, Codable {
    case herbs = "Herb"
    case roots = "Root"
    case barks = "Bark"
    case tonics = "Tonic"
    case mixedTonics = "Mixed Tonic"
    
    var displayName: String {
        switch self {
        case .herbs: return "Herbs"
        case .roots: return "Roots"
        case .barks: return "Barks"
        case .tonics: return "Tonics"
        case .mixedTonics: return "Mixed Tonics"
        }
    }
    
    var emoji: String {
        switch self {
        case .herbs: return "🌿"
        case .roots: return "🥕"
        case .barks: return "🪵"
        case .tonics: return "🧉"
        case .mixedTonics: return "🍯"
        }
    }
}

// MARK: - Herb Data Models
struct HerbResponse: Codable {
    let herbs: [Herb]
}

struct Herb: Codable, Identifiable, Hashable {
    let id: String
    let englishName: String
    let localNames: [String: String]
    let scientificName: String
    let description: String
    let uses: [String]
    let category: String
    let vitamins: [String]
    let nutrition: Nutrition
    let ailments: [String]
    let locations: [String]
    let preparation: String
    let dosage: String
    let precautions: String
    let honeyUsage: String
    let continents: [String]
    let wikipediaUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case englishName = "english_name"
        case localNames = "local_names"
        case scientificName = "scientific_name"
        case description
        case uses
        case category
        case vitamins
        case nutrition
        case ailments
        case locations
        case preparation
        case dosage
        case precautions
        case honeyUsage = "honey_usage"
        case continents
        case wikipediaUrl = "wikipedia_url"
    }
    
    // Computed properties for easier access
    var displayName: String {
        return englishName
    }
    
    var continentNames: [String] {
        return continents.compactMap { Continent(rawValue: $0)?.displayName }
    }
    
    var isRefresher: Bool {
        return category.lowercased() == "refresher"
    }
    
    var isHerb: Bool {
        return category.lowercased() == "herb"
    }
}

struct Nutrition: Codable, Hashable {
    let calories: Int
    let carbs: Double
}

// MARK: - Continent Enum
enum Continent: String, CaseIterable {
    case africa = "AF"
    case asia = "AS"
    case europe = "EU"
    case northAmerica = "NA"
    case southAmerica = "SA"
    case australia = "AU"
    case antarctica = "AN"
    
    var displayName: String {
        switch self {
        case .africa: return "Africa"
        case .asia: return "Asia"
        case .europe: return "Europe"
        case .northAmerica: return "North America"
        case .southAmerica: return "South America"
        case .australia: return "Australia"
        case .antarctica: return "Antarctica"
        }
    }
    
    var emoji: String {
        switch self {
        case .africa: return "🌍"
        case .asia: return "🌏"
        case .europe: return "🇪🇺"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🌎"
        case .australia: return "🇦🇺"
        case .antarctica: return "🏔️"
        }
    }
    
    var color: String {
        switch self {
        case .africa: return "green"
        case .asia: return "orange"
        case .europe: return "blue"
        case .northAmerica: return "red"
        case .southAmerica: return "purple"
        case .australia: return "yellow"
        case .antarctica: return "gray"
        }
    }
} 