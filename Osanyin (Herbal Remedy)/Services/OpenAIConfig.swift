import Foundation

// MARK: - OpenAI Configuration
struct OpenAIConfig {
    // MARK: - API Configuration
    // SECURITY: Do NOT hardcode your API key here!
    // Use one of the secure methods below instead
    static let apiKey: String = {
        // Method 1: Environment Variable (Recommended for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return envKey
        }
        
        // Method 2: Configuration File (Add Config.plist to .gitignore)
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let configKey = dict["OpenAIAPIKey"] as? String {
            return configKey
        }
        
        // Method 3: Keychain Storage (Most secure for production)
        if let keychainKey = KeychainService.shared.getAPIKey() {
            return keychainKey
        }
        
        // Fallback: Return placeholder (will show configuration needed)
        return "YOUR_OPENAI_API_KEY"
    }()
    
    static let baseURL = "https://api.openai.com/v1/chat/completions"
    static let model = "gpt-3.5-turbo" // Changed from gpt-4 to gpt-3.5-turbo for better compatibility
    
    // MARK: - Request Configuration
    static let temperature: Double = 0.1 // Low temperature for consistent, factual responses
    static let maxTokens: Int = 1000
    
    // MARK: - Validation
    static var isConfigured: Bool {
        return apiKey != "YOUR_OPENAI_API_KEY" && !apiKey.isEmpty
    }
    
    // MARK: - Error Messages
    static let notConfiguredMessage = """
    OpenAI API key not configured. 
    
    To use ChatGPT features:
    1. Get an API key from https://platform.openai.com/
    2. Add it to your environment variables or Config.plist
    3. Restart the app
    
    See CHATGPT_SETUP.md for detailed instructions.
    """
    static let rateLimitMessage = "Rate limit exceeded. Please try again later."
    static let networkErrorMessage = "Network error. Please check your internet connection."
    
    // MARK: - Usage Tracking
    static var requestCount: Int = 0
    static var lastRequestTime: Date?
    
    // MARK: - Rate Limiting
    static let maxRequestsPerMinute = 60
    static let maxRequestsPerHour = 1000
    
    static func canMakeRequest() -> Bool {
        guard isConfigured else { return false }
        
        // Basic rate limiting check
        if let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            if timeSinceLastRequest < 1.0 { // Minimum 1 second between requests
                return false
            }
        }
        
        return true
    }
    
    static func recordRequest() {
        requestCount += 1
        lastRequestTime = Date()
    }
    
    // MARK: - Test Function
    static func testAPIKey() async -> Bool {
        print("🧪 Testing API key...")
        
        guard isConfigured else {
            print("❌ API key not configured")
            return false
        }
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid API URL")
            return false
        }
        
        let testRequest = ChatGPTRequest(
            model: model,
            messages: [
                ChatGPTMessage(role: "user", content: "Say 'Hello' if you can read this.")
            ],
            temperature: 0.1,
            max_tokens: 10
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(testRequest)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Test HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("✅ API key is working!")
                    return true
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response"
                    print("❌ API test failed: \(responseString)")
                    return false
                }
            }
            
            return false
        } catch {
            print("❌ API test error: \(error)")
            return false
        }
    }
}

// MARK: - Keychain Service (Optional - for production apps)
class KeychainService {
    static let shared = KeychainService()
    private let service = "com.osanyin.openai"
    private let account = "api_key"
    
    private init() {}
    
    func saveAPIKey(_ key: String) -> Bool {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteAPIKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
} 