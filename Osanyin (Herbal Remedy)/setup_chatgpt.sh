#!/bin/bash

# ChatGPT API Key Setup Script
# This script helps you securely configure your OpenAI API key

echo "🤖 ChatGPT API Key Setup"
echo "=========================="
echo ""

# Check if Config.plist already exists
if [ -f "Osanyin (Herbal Remedy)/Config.plist" ]; then
    echo "⚠️  Config.plist already exists!"
    echo "   If you want to update your API key, edit the file manually."
    echo "   Location: Osanyin (Herbal Remedy)/Config.plist"
    exit 1
fi

# Check if example file exists
if [ ! -f "Osanyin (Herbal Remedy)/Config.plist.example" ]; then
    echo "❌ Config.plist.example not found!"
    echo "   Please make sure you're running this script from the project root."
    exit 1
fi

echo "📋 This script will help you set up your OpenAI API key securely."
echo ""
echo "🔑 To get an API key:"
echo "   1. Go to https://platform.openai.com/"
echo "   2. Sign up or log in"
echo "   3. Navigate to 'API Keys'"
echo "   4. Click 'Create new secret key'"
echo "   5. Copy your key (starts with 'sk-')"
echo ""

# Prompt for API key
read -p "Enter your OpenAI API key: " api_key

# Validate API key format
if [[ ! $api_key =~ ^sk-[a-zA-Z0-9]{32,}$ ]]; then
    echo "❌ Invalid API key format!"
    echo "   API keys should start with 'sk-' followed by 32+ characters"
    exit 1
fi

# Copy example file
cp "Osanyin (Herbal Remedy)/Config.plist.example" "Osanyin (Herbal Remedy)/Config.plist"

# Replace placeholder with actual key
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/YOUR_API_KEY_HERE/$api_key/g" "Osanyin (Herbal Remedy)/Config.plist"
else
    # Linux
    sed -i "s/YOUR_API_KEY_HERE/$api_key/g" "Osanyin (Herbal Remedy)/Config.plist"
fi

echo ""
echo "✅ Configuration complete!"
echo ""
echo "📁 Files created:"
echo "   - Osanyin (Herbal Remedy)/Config.plist (your API key)"
echo "   - .gitignore (excludes Config.plist from Git)"
echo ""
echo "🔒 Security:"
echo "   - Config.plist is added to .gitignore"
echo "   - Your API key will NOT be committed to version control"
echo ""
echo "🚀 Next steps:"
echo "   1. Build and run your app"
echo "   2. Go to Settings → ChatGPT Integration"
echo "   3. You should see 'Configured' status"
echo "   4. Test the Drug Interaction Checker"
echo ""
echo "⚠️  Important:"
echo "   - Never share your API key"
echo "   - Monitor your OpenAI usage and costs"
echo "   - Keep your Config.plist file secure"
echo ""
echo "📚 For more information, see CHATGPT_SETUP.md" 