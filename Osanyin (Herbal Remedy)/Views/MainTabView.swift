import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var selectedContinent: Continent?
    @State private var selectedCategory: HerbCategory?
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HeroView(selectedContinent: $selectedContinent, selectedCategory: $selectedCategory)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Herbs Tab
            HerbListView(dataService: DataService.shared, initialContinent: selectedContinent, initialCategory: selectedCategory)
                .id(selectedContinent?.rawValue ?? "no-continent") // Force recreation when continent changes
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Herbs")
                }
                .tag(1)
            
            // Ailments Tab
            AilmentsView()
                .tabItem {
                    Image(systemName: "cross.fill")
                    Text("Ailments")
                }
                .tag(2)
            
            // Favorites Tab
            FavoritesView()
                .environment(\.managedObjectContext, managedObjectContext)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.green)
        .onChange(of: selectedContinent) { _, newContinent in
            if newContinent != nil {
                // Automatically navigate to Herbs tab when a continent is selected
                selectedTab = 1
            }
        }
        .onChange(of: selectedCategory) { _, newCategory in
            if newCategory != nil {
                // Automatically navigate to Herbs tab when a category is selected
                selectedTab = 1
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 0 {
                // Refresh database when Home tab is tapped
                print("🏠 Home tab tapped - refreshing database...")
                DataService.shared.refreshData()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
} 