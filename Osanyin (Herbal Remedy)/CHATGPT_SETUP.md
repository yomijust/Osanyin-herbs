# 🤖 ChatGPT Integration Setup Guide

## Overview
The Osanyin Herbal Remedy app now includes **real ChatGPT integration** for drug interaction analysis. This provides AI-powered, evidence-based analysis of potential herb-drug interactions.

## 🔑 Setup Instructions

### 1. Get OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to "API Keys" in your dashboard
4. Click "Create new secret key"
5. Copy your API key (starts with `sk-`)

### 2. Configure the App (Choose ONE method)

#### **Method A: Configuration File (Recommended)**
1. Copy `Config.plist.example` to `Config.plist`
2. Add `Config.plist` to your `.gitignore` file
3. Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```xml
   <key>OpenAIAPIKey</key>
   <string>sk-your-actual-api-key-here</string>
   ```

#### **Method B: Environment Variable**
1. Set environment variable in Xcode:
   - Edit Scheme → Run → Arguments → Environment Variables
   - Add: `OPENAI_API_KEY` = `sk-your-actual-api-key-here`

#### **Method C: Keychain Storage (Production)**
1. Use the KeychainService to store keys securely:
   ```swift
   KeychainService.shared.saveAPIKey("sk-your-actual-api-key-here")
   ```

**⚠️ SECURITY WARNING: Never hardcode API keys in your source code!**

### 3. Choose Your Model
You can choose between different ChatGPT models:
- **GPT-4** (Recommended): More accurate, higher cost
- **GPT-3.5-turbo**: Faster, lower cost

Edit the model in `OpenAIConfig.swift`:
```swift
static let model = "gpt-4" // or "gpt-3.5-turbo"
```

## 🎯 Features

### AI-Powered Analysis
- **Real-time interaction checking** using ChatGPT
- **Evidence-based recommendations** from medical literature
- **Severity assessment** (None, Low, Moderate, High)
- **Detailed mechanisms** of interactions
- **Safety recommendations** for each interaction

### Fallback System
- **Offline database** of common interactions
- **Pattern matching** for known herb-drug combinations
- **Graceful degradation** if API is unavailable

### User Experience
- **Visual indicators** when ChatGPT is being used
- **Loading states** with "AI Analyzing..." message
- **Error handling** with helpful messages
- **Rate limiting** to prevent API abuse

## 🔒 Security & Privacy

### API Key Security
- **Never commit** your API key to version control
- **Use environment variables** in production
- **Rotate keys** regularly

### Data Privacy
- **No personal data** sent to OpenAI
- **Only herb and medication names** are transmitted
- **No medical records** or personal information shared

## 💰 Cost Management

### API Costs
- **GPT-4**: ~$0.03 per request
- **GPT-3.5-turbo**: ~$0.002 per request
- **Rate limiting** prevents excessive usage

### Quota Limits
- **Free accounts**: Limited monthly usage
- **Paid accounts**: Higher limits based on billing
- **Quota exceeded**: App automatically falls back to local database
- **Check billing**: Visit https://platform.openai.com/account/billing

### Usage Tracking
The app tracks:
- Request count
- Last request time
- Rate limiting status

## 🛠️ Configuration Options

### Rate Limiting
```swift
static let maxRequestsPerMinute = 60
static let maxRequestsPerHour = 1000
```

### Request Settings
```swift
static let temperature: Double = 0.1  // Lower = more consistent
static let maxTokens: Int = 1000      // Response length limit
```

## 🚨 Error Handling

### Common Issues
1. **Invalid API Key**: Check your key format
2. **Rate Limit Exceeded**: Wait before making another request
3. **Network Error**: Check internet connection
4. **API Error**: Check OpenAI service status

### Fallback Behavior
If ChatGPT fails, the app automatically falls back to:
- Local interaction database
- Pattern matching
- Basic recommendations

## 🔧 Development

### Testing
1. **Test with valid API key** to verify ChatGPT integration
2. **Test without API key** to verify fallback behavior
3. **Test rate limiting** by making rapid requests
4. **Test error scenarios** by using invalid keys

### Debugging
- Check console logs for API errors
- Monitor request/response data
- Verify JSON parsing works correctly

## 📱 User Interface

### Visual Indicators
- **Brain icon** shows when ChatGPT is configured
- **"AI Analyzing..."** during processing
- **Color-coded severity** levels
- **Detailed interaction cards**

### Settings Integration
- **ChatGPT status** in Settings
- **Configuration status** indicator
- **Easy access** to setup instructions

## 🎉 Benefits

### For Users
- **More accurate** interaction analysis
- **Up-to-date** medical information
- **Comprehensive** safety recommendations
- **Professional-grade** analysis

### For Developers
- **Scalable** architecture
- **Robust** error handling
- **Easy** configuration
- **Maintainable** codebase

## 🔮 Future Enhancements

### Planned Features
- **Batch analysis** for multiple herbs
- **Interaction history** tracking
- **Personalized recommendations** based on health profile
- **Integration** with medical databases

### Advanced AI Features
- **Natural language** interaction queries
- **Image recognition** for herb identification
- **Voice input** for medication lists
- **Predictive** interaction warnings

---

## ⚠️ Important Notes

1. **Medical Disclaimer**: This is not a substitute for professional medical advice
2. **API Dependencies**: Requires active internet connection and OpenAI service
3. **Cost Considerations**: Monitor your OpenAI usage and costs
4. **Privacy**: Review OpenAI's privacy policy for data handling

## 🆘 Support

If you encounter issues:
1. Check your API key format
2. Verify internet connection
3. Check OpenAI service status
4. Review error messages in console
5. Test with fallback mode

---

**Happy coding! 🚀** 