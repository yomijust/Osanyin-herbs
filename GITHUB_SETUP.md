# GitHub Setup Guide for Osanyin Herbs Data

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Name the repository: `osanyin-herbs`
5. Make it **Public** (so the raw URL can be accessed)
6. Don't initialize with README (we'll add files manually)
7. Click "Create repository"

## Step 2: Upload Herbs Data

1. In your new repository, click "Add file" → "Upload files"
2. Drag and drop the `herbs.json` file
3. Add a commit message: "Add initial herbs data"
4. Click "Commit changes"

## Step 3: Get Raw URL

1. Click on the `herbs.json` file in your repository
2. Click the "Raw" button (top right of the file view)
3. Copy the URL from your browser's address bar
4. The URL should look like: "https://raw.githubusercontent.com/YOUR_USERNAME/osanyin-herbs/main/herbs.json"

## Step 4: Update App Configuration

1. Open `Osanyin (Herbal Remedy)/Services/DataService.swift`
2. Find this line:
   ```swift
   private let herbsURL = "https://raw.githubusercontent.com/yourusername/osanyin-herbs/main/herbs.json"
   ```
3. Replace `yourusername` with your actual GitHub username
4. Save the file

## Step 5: Test the App

1. Build and run the app in Xcode
2. The app should now fetch herbs data from your GitHub repository
3. Verify that herbs are loading correctly

## Step 6: Add More Herbs (Optional)

To add more herbs to the database:

1. Edit the `herbs.json` file locally
2. Add new herb entries following the JSON structure
3. Upload the updated file to GitHub
4. The app will automatically fetch the new data

## Troubleshooting

### App not loading herbs
- Check that the GitHub repository is public
- Verify the raw URL is correct
- Ensure the JSON format is valid
- Check network connectivity

### JSON parsing errors
- Validate your JSON using a tool like [JSONLint](https://jsonlint.com/)
- Ensure all required fields are present
- Check for missing commas or brackets

### Performance issues
- The app caches data for 1 hour
- Large JSON files may take longer to load initially
- Consider splitting data into smaller files if needed

## Example Herb Entry

```json
{
  "id": "unique_id",
  "english_name": "Herb Name",
  "local_names": {"COUNTRY": "Local Name"},
  "scientific_name": "Scientific Name",
  "description": "Description of the herb",
  "uses": ["Use 1", "Use 2"],
  "category": "Herb",
  "vitamins": ["Vitamin A", "Vitamin C"],
  "nutrition": {"calories": 5, "carbs": 1.2},
  "ailments": ["Ailment 1", "Ailment 2"],
  "locations": ["Location 1", "Location 2"],
  "preparation": "How to prepare",
  "dosage": "Recommended dosage",
  "precautions": "Safety notes",
  "honey_usage": "Honey usage",
  "continents": ["AF", "AS"],
  "wikipedia_url": "https://en.wikipedia.org/wiki/Herb"
}
```

## Security Notes

- Keep the repository public so the app can access the raw URL
- Don't include sensitive information in the herbs data
- The app only reads data, it doesn't write back to GitHub
- Consider using GitHub Pages for better performance if needed 