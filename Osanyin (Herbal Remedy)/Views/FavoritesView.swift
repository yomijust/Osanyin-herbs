import SwiftUI

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Int16
    let maxRating: Int16 = 5
    let onRatingChanged: (Int16) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Button(action: {
                    onRatingChanged(Int16(star))
                }) {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(star <= rating ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct FavoritesView: View {
    @StateObject private var coreDataManager = CoreDataManager.shared
    @ObservedObject private var dataService = DataService.shared
    @Environment(\.dismiss) private var dismiss
    
    var favoriteHerbs: [(herb: Herb, favorite: FavoriteHerb)] {
        let favorites = coreDataManager.getFavorites()
        return favorites.compactMap { favorite in
            if let herb = dataService.herbs.first(where: { $0.id == favorite.id }) {
                return (herb: herb, favorite: favorite)
            }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if favoriteHerbs.isEmpty {
                    EmptyFavoritesView()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteHerbs, id: \.herb.id) { herbData in
                            VStack(spacing: 8) {
                                HerbCardView(
                                    herb: herbData.herb,
                                    isFavorite: true
                                ) {
                                    coreDataManager.removeFromFavorites(herbData.herb.id)
                                }
                                
                                // Star Rating
                                HStack {
                                    Text("Rating:")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    StarRatingView(
                                        rating: herbData.favorite.starRating,
                                        onRatingChanged: { newRating in
                                            coreDataManager.updateStarRating(for: herbData.herb.id, rating: newRating)
                                        }
                                    )
                                    
                                    Spacer()
                                    
                                    Text("\(herbData.favorite.starRating)/5")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.5))
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start exploring herbs and tap the heart icon to add them to your favorites")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
} 