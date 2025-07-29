# Osanyin - Herbal Remedy Guide

A beautiful iOS app built with SwiftUI that helps users discover traditional herbs and natural refreshers from around the world.

## Features

- 🌍 **Interactive Continent Selection**: Explore herbs by continent with beautiful emoji-based navigation
- 🔍 **Advanced Search & Filtering**: Find herbs by name, category, continent, or ailment
- ❤️ **Favorites System**: Save your favorite herbs locally using Core Data
- ⚡ **Optimized Performance**: Fast loading with prefetching, lazy loading, and local caching
- 📱 **Modern UI**: Beautiful, intuitive interface designed with SwiftUI
- 🌐 **Cloud Data**: Herbs data hosted on GitHub for easy updates

## Setup Instructions

### 1. GitHub Repository Setup

1. Create a new GitHub repository named `osanyin-herbs`
2. Upload the `herbs.json` file to the repository
3. Get the raw URL: `https://raw.githubusercontent.com/YOUR_USERNAME/osanyin-herbs/main/herbs.json`
4. Update the URL in `DataService.swift`:

```swift
private let herbsURL = "https://raw.githubusercontent.com/YOUR_USERNAME/osanyin-herbs/main/herbs.json"
```

### 2. Xcode Project Setup

1. Open the project in Xcode
2. Ensure Core Data model is properly configured
3. Build and run the project

### 3. Adding More Herbs

To add more herbs to the database:

1. Edit the `herbs.json` file
2. Follow the JSON structure shown in the example
3. Commit and push to GitHub
4. The app will automatically fetch the updated data

## Data Structure

Each herb in the JSON follows this structure:

```json
{
  "id": "unique_identifier",
  "english_name": "Common English Name",
  "local_names": {"COUNTRY_CODE": "Local Name"},
  "scientific_name": "Scientific Name",
  "description": "Detailed description",
  "uses": ["Use 1", "Use 2"],
  "category": "Herb|Refresher|Spice",
  "vitamins": ["Vitamin A", "Vitamin C"],
  "nutrition": {"calories": 5, "carbs": 1.2},
  "ailments": ["Ailment 1", "Ailment 2"],
  "locations": ["Location 1", "Location 2"],
  "preparation": "Preparation instructions",
  "dosage": "Recommended dosage",
  "precautions": "Safety precautions",
  "honey_usage": "Honey usage notes",
  "continents": ["AF", "AS", "EU"],
  "wikipedia_url": "Wikipedia article URL"
}
```

## Continent Codes

- `AF` - Africa
- `AS` - Asia
- `EU` - Europe
- `NA` - North America
- `SA` - South America
- `AU` - Australia
- `AN` - Antarctica

## Technical Architecture

### Core Components

- **Models**: `Herb.swift` - Data models and enums
- **Services**: `DataService.swift` - Network and caching logic
- **Views**: 
  - `HeroView.swift` - Main landing page with continent selection
  - `HerbListView.swift` - Herb listing with search and filters
  - `HerbDetailView.swift` - Detailed herb information
  - `FilterView.swift` - Advanced filtering options
  - `FavoritesView.swift` - Saved favorites management

### Performance Optimizations

- **Lazy Loading**: Herb cards load as needed
- **Local Caching**: 1-hour cache expiration for network data
- **Prefetching**: Data loaded on app launch
- **Core Data**: Efficient local storage for favorites

### Dependencies

- SwiftUI for UI
- Core Data for local storage
- Foundation for networking
- SafariServices for Wikipedia links

## Contributing

1. Fork the repository
2. Add new herbs to `herbs.json`
3. Test the app thoroughly
4. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

For questions or issues, please open an issue on GitHub. 