import Foundation
import CoreData
import SwiftUI

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var herbs: [Herb] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let cache = NSCache<NSString, NSData>()
    private let cacheKey = "herbs_cache"
    private let cacheExpirationKey = "herbs_cache_expiration"
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    // GitHub raw URLs for the herbs data - multiple fallbacks
    private let herbsURLs = [
        "https://raw.githubusercontent.com/yomijust/Osanyin-herbs/main/herbs.json",
        "https://raw.githubusercontent.com/yomijust/Osanyin-herbs/main/Osanyin%20%28Herbal%20Remedy%29/herbs.json"
    ]
    
    private var currentURLIndex = 0
    private var herbsURL: String {
        return herbsURLs[currentURLIndex]
    }
    
    init() {
        print("🌿 DataService: Initializing...")
        print("🌿 DataService: Herbs array count: \(herbs.count)")
        
        // Clear any old cache to force fresh data from GitHub
        clearCache()
        
        // Fetch from GitHub repository
        fetchHerbs()
    }
    
    // MARK: - Data Fetching
    func fetchHerbs() {
        print("🌿 DataService: Fetching herbs from GitHub...")
        isLoading = true
        errorMessage = nil
        
        // Check if we have valid cached data
        if let cachedData = getCachedData(), !isCacheExpired() {
            print("🌿 DataService: Using cached data")
            decodeHerbs(from: cachedData)
            isLoading = false
            return
        }
        
        guard let url = URL(string: herbsURL) else {
            errorMessage = "Invalid URL - Please update the GitHub URL in DataService.swift"
            isLoading = false
            return
        }
        
        print("🌿 DataService: Fetching from URL: \(herbsURL)")
        
        // Create a request with User-Agent header to avoid potential issues
        var request = URLRequest(url: url)
        request.setValue("Osanyin-Herbal-Remedy/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                // Debug HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    print("🌿 DataService: HTTP Status Code: \(httpResponse.statusCode)")
                    print("🌿 DataService: Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "Unknown")")
                }
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Network error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received from server"
                    print("No data received")
                    return
                }
                
                // Check if response is valid JSON
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response preview: \(String(responseString.prefix(200)))")
                    print("Response length: \(responseString.count)")
                    print("Response starts with JSON: \(responseString.hasPrefix("{"))")
                    
                    // Check if response looks like HTML (error page)
                    // Only flag as HTML if it doesn't start with valid JSON
                    if !responseString.hasPrefix("{") && (responseString.contains("<html") || responseString.contains("404") || responseString.contains("Not Found") || responseString.contains("<!DOCTYPE")) {
                        print("Received HTML response instead of JSON")
                        print("Response preview: \(String(responseString.prefix(500)))")
                        
                        // Try next URL if available
                        if let self = self, self.currentURLIndex < self.herbsURLs.count - 1 {
                            self.currentURLIndex += 1
                            print("🌿 DataService: Trying fallback URL: \(self.herbsURL)")
                            self.fetchHerbs()
                            return
                        } else {
                            self?.errorMessage = "Unable to access GitHub repository. This might be due to network restrictions or the repository being private. Please check your internet connection and try again."
                            print("🌿 DataService: All URLs failed. Final error message: \(self?.errorMessage ?? "Unknown error")")
                            return
                        }
                    }
                }
                
                // Try to decode the data
                do {
                    print("🌿 DataService: Attempting to decode JSON data...")
                    let response = try JSONDecoder().decode(HerbResponse.self, from: data)
                    self?.herbs = response.herbs
                    print("🌿 DataService: Successfully loaded \(response.herbs.count) herbs from GitHub")
                    // Cache successful data
                    self?.cacheData(data)
                } catch {
                    self?.errorMessage = "Invalid JSON data received. Please check the herbs.json file format."
                    print("JSON decoding error: \(error)")
                    print("🌿 DataService: JSON decoding failed. Response length: \(data.count)")
                    // Don't cache invalid data
                }
            }
        }.resume()
    }
    
    private func decodeHerbs(from data: Data) {
        do {
            let response = try JSONDecoder().decode(HerbResponse.self, from: data)
            self.herbs = response.herbs
        } catch {
            self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
            print("Decoding error: \(error)")
        }
    }
    
    // MARK: - Sample Data for Testing
    private func loadSampleData() {
        let sampleHerbs = [
            Herb(
                id: "zobo_ng",
                englishName: "Hibiscus Tea",
                localNames: ["NG": "Zobo", "SD": "Karkade"],
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
            Herb(
                id: "ginger_tea",
                englishName: "Ginger Tea",
                localNames: ["IN": "Adrak Chai", "CN": "姜茶"],
                scientificName: "Zingiber officinale",
                description: "A warming herbal tea made from fresh or dried ginger root, known for its anti-inflammatory and digestive properties.",
                uses: ["Digestive health", "Anti-inflammatory", "Nausea relief"],
                category: "Herb",
                vitamins: ["B6", "C"],
                nutrition: Nutrition(calories: 2, carbs: 0.4),
                ailments: ["Nausea", "Indigestion", "Cold"],
                locations: ["Asia", "Tropics"],
                preparation: "Slice fresh ginger and steep in hot water for 5-10 minutes",
                dosage: "1-3 cups daily",
                precautions: "May cause heartburn in some people",
                honeyUsage: "Excellent with honey for soothing sore throat",
                continents: ["AS", "AF"],
                wikipediaUrl: "https://en.wikipedia.org/wiki/Ginger_tea"
            ),
            Herb(
                id: "mint_tea",
                englishName: "Mint Tea",
                localNames: ["MA": "Atay", "EG": "Shai Na'na"],
                scientificName: "Mentha spicata",
                description: "A refreshing herbal tea made from fresh or dried mint leaves, known for its cooling properties and digestive benefits.",
                uses: ["Digestive health", "Refreshment", "Stress relief"],
                category: "Herb",
                vitamins: ["A", "C"],
                nutrition: Nutrition(calories: 1, carbs: 0.2),
                ailments: ["Indigestion", "Nausea", "Stress"],
                locations: ["Mediterranean", "North Africa"],
                preparation: "Steep fresh mint leaves in hot water for 3-5 minutes",
                dosage: "2-4 cups daily",
                precautions: "Generally safe, may cause heartburn in some individuals",
                honeyUsage: "Light honey enhances the refreshing taste",
                continents: ["AF", "EU"],
                wikipediaUrl: "https://en.wikipedia.org/wiki/Mint_tea"
            ),
            Herb(
                id: "chamomile_tea",
                englishName: "Chamomile Tea",
                localNames: ["DE": "Kamillentee", "GR": "Χαμομήλι"],
                scientificName: "Matricaria chamomilla",
                description: "A gentle herbal tea made from chamomile flowers, known for its calming and sleep-inducing properties.",
                uses: ["Sleep aid", "Stress relief", "Digestive health"],
                category: "Herb",
                vitamins: ["A", "C"],
                nutrition: Nutrition(calories: 1, carbs: 0.2),
                ailments: ["Insomnia", "Anxiety", "Indigestion"],
                locations: ["Europe", "North America"],
                preparation: "Steep dried chamomile flowers in hot water for 5-7 minutes",
                dosage: "1-2 cups before bedtime",
                precautions: "May cause allergic reactions in people sensitive to ragweed",
                honeyUsage: "Honey enhances the calming effect",
                continents: ["EU", "NA"],
                wikipediaUrl: "https://en.wikipedia.org/wiki/Chamomile_tea"
            ),
            Herb(
                id: "turmeric_tea",
                englishName: "Turmeric Tea",
                localNames: ["IN": "Haldi Chai", "ID": "Teh Kunyit"],
                scientificName: "Curcuma longa",
                description: "A golden herbal tea made from turmeric root, known for its powerful anti-inflammatory and antioxidant properties.",
                uses: ["Anti-inflammatory", "Antioxidant", "Immunity boost"],
                category: "Herb",
                vitamins: ["C", "E"],
                nutrition: Nutrition(calories: 2, carbs: 0.4),
                ailments: ["Inflammation", "Arthritis", "Cold"],
                locations: ["South Asia", "Southeast Asia"],
                preparation: "Boil fresh turmeric root or powder with black pepper for 10 minutes",
                dosage: "1-2 cups daily",
                precautions: "May interact with blood thinners, avoid on empty stomach",
                honeyUsage: "Honey and milk enhance absorption and taste",
                continents: ["AS"],
                wikipediaUrl: "https://en.wikipedia.org/wiki/Turmeric_tea"
            )
        ]
        
        self.herbs = sampleHerbs
    }
    
    // MARK: - Caching
    private func cacheData(_ data: Data) {
        UserDefaults.standard.set(data, forKey: cacheKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: cacheExpirationKey)
    }
    
    private func getCachedData() -> Data? {
        return UserDefaults.standard.data(forKey: cacheKey)
    }
    
    private func isCacheExpired() -> Bool {
        let expirationTime = UserDefaults.standard.double(forKey: cacheExpirationKey)
        let currentTime = Date().timeIntervalSince1970
        return currentTime - expirationTime > cacheExpirationTime
    }
    
    private func loadCachedData() {
        if let cachedData = getCachedData(), !isCacheExpired() {
            do {
                let response = try JSONDecoder().decode(HerbResponse.self, from: cachedData)
                self.herbs = response.herbs
            } catch {
                print("Cached data is invalid, clearing cache")
                UserDefaults.standard.removeObject(forKey: cacheKey)
                UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
            }
        }
    }
    
    // MARK: - Filtering
    func filterHerbs(by category: String? = nil, by continent: String? = nil, searchText: String = "") -> [Herb] {
        var filteredHerbs = herbs
        
        if let category = category, !category.isEmpty {
            filteredHerbs = filteredHerbs.filter { $0.category.lowercased() == category.lowercased() }
        }
        
        if let continent = continent, !continent.isEmpty {
            filteredHerbs = filteredHerbs.filter { $0.continents.contains(continent) }
        }
        
        if !searchText.isEmpty {
            filteredHerbs = filteredHerbs.filter { herb in
                herb.englishName.localizedCaseInsensitiveContains(searchText) ||
                herb.scientificName.localizedCaseInsensitiveContains(searchText) ||
                herb.description.localizedCaseInsensitiveContains(searchText) ||
                herb.uses.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filteredHerbs
    }
    
    func getHerbsByContinent(_ continent: Continent) -> [Herb] {
        return herbs.filter { $0.continents.contains(continent.rawValue) }
    }
    
    func getHerbsByCategory(_ category: String) -> [Herb] {
        return herbs.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    func getCategories() -> [String] {
        return Array(Set(herbs.map { $0.category })).sorted()
    }
    
    // MARK: - Cache Management
    func clearCache() {
        print("🌿 DataService: Clearing cache...")
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheExpirationKey)
    }
    
    func refreshData() {
        print("🌿 DataService: Refreshing data from GitHub...")
        print("🌿 DataService: Current herbs count before refresh: \(herbs.count)")
        clearCache()
        currentURLIndex = 0 // Reset to first URL
        herbs = [] // Clear herbs array
        errorMessage = nil // Clear any error messages
        fetchHerbs()
    }
    
        func getDataInfo() -> String {
        let herbCount = herbs.count
        let hasCachedData = getCachedData() != nil
        let isExpired = isCacheExpired()
        let currentError = errorMessage ?? "None"

        return """
        📊 Data Info:
        - Total Herbs: \(herbCount)
        - Has Cached Data: \(hasCachedData)
        - Cache Expired: \(isExpired)
        - Current Error: \(currentError)
        - GitHub URL: \(herbsURL)
        - Is Loading: \(isLoading)
        - Current URL Index: \(currentURLIndex)
        """
    }
    
    func testConnection() {
        print("🌿 DataService: Testing connection to GitHub...")
        let testURL = "https://raw.githubusercontent.com/yomijust/Osanyin-herbs/main/herbs.json"
        
        guard let url = URL(string: testURL) else {
            print("🌿 DataService: Invalid test URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Osanyin-Herbal-Remedy/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print("🌿 DataService: Test HTTP Status: \(httpResponse.statusCode)")
                    print("🌿 DataService: Test Content-Type: \(httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "Unknown")")
                }
                
                if let error = error {
                    print("🌿 DataService: Test Error: \(error.localizedDescription)")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("🌿 DataService: Test Response Length: \(responseString.count)")
                    print("🌿 DataService: Test Response Preview: \(String(responseString.prefix(200)))")
                    print("🌿 DataService: Test Response is JSON: \(responseString.hasPrefix("{"))")
                }
            }
        }.resume()
    }
}

// MARK: - Core Data Manager
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HerbCoreData")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }
    
    // MARK: - Favorites Management
    func addToFavorites(_ herb: Herb, starRating: Int16 = 0) {
        let favorite = FavoriteHerb(context: context)
        favorite.id = herb.id
        favorite.englishName = herb.englishName
        favorite.scientificName = herb.scientificName
        favorite.category = herb.category
        favorite.dateAdded = Date()
        favorite.starRating = starRating
        
        save()
        objectWillChange.send()
    }
    
    func removeFromFavorites(_ herbId: String) {
        let request: NSFetchRequest<FavoriteHerb> = FavoriteHerb.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", herbId)
        
        do {
            let favorites = try context.fetch(request)
            favorites.forEach { context.delete($0) }
            save()
            objectWillChange.send()
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
    
    func isFavorite(_ herbId: String) -> Bool {
        let request: NSFetchRequest<FavoriteHerb> = FavoriteHerb.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", herbId)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking favorite status: \(error)")
            return false
        }
    }
    
    func getFavorites() -> [FavoriteHerb] {
        let request: NSFetchRequest<FavoriteHerb> = FavoriteHerb.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteHerb.dateAdded, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    // MARK: - Star Rating Management
    func updateStarRating(for herbId: String, rating: Int16) {
        let request: NSFetchRequest<FavoriteHerb> = FavoriteHerb.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", herbId)
        
        do {
            let favorites = try context.fetch(request)
            if let favorite = favorites.first {
                favorite.starRating = rating
                save()
                objectWillChange.send()
            }
        } catch {
            print("Error updating star rating: \(error)")
        }
    }
    
    func getStarRating(for herbId: String) -> Int16 {
        let request: NSFetchRequest<FavoriteHerb> = FavoriteHerb.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", herbId)
        
        do {
            let favorites = try context.fetch(request)
            return favorites.first?.starRating ?? 0
        } catch {
            print("Error getting star rating: \(error)")
            return 0
        }
    }
} 