import Foundation

// MARK: - Drug Interaction Checker
class DrugInteractionChecker: ObservableObject {
    static let shared = DrugInteractionChecker()
    
    // MARK: - Configuration
    private let config = OpenAIConfig.self
    
    private init() {}
    
    // MARK: - Interaction Check
    func checkInteractions(herb: Herb, medications: [String]) async -> DrugInteractionResult {
        guard !medications.isEmpty else {
            return DrugInteractionResult(
                hasInteractions: false,
                interactions: [],
                recommendations: [],
                severity: .none
            )
        }
        
        // Create a structured prompt for ChatGPT
        let prompt = createStructuredPrompt(herb: herb, medications: medications)
        
        // Check if ChatGPT is configured
        guard config.isConfigured else {
            return createErrorResult(error: config.notConfiguredMessage)
        }
        
        // Check rate limiting
        guard config.canMakeRequest() else {
            return createErrorResult(error: "Please wait before making another request")
        }
        
        // Try ChatGPT first, fallback to local database if it fails
        do {
            let result = await callChatGPT(prompt: prompt, herb: herb, medications: medications)
            
            // Check if we got a real result or an error
            if result.recommendations.contains("Error occurred while checking interactions") {
                print("🔄 ChatGPT failed, falling back to local database...")
                return analyzeInteractions(herb: herb, medications: medications)
            }
            
            return result
        } catch {
            print("🔄 ChatGPT error, falling back to local database...")
            return analyzeInteractions(herb: herb, medications: medications)
        }
    }
    
    private func createStructuredPrompt(herb: Herb, medications: [String]) -> String {
        return """
        You are a medical AI assistant specializing in herb-drug interactions. Analyze the potential interactions between \(herb.englishName) (\(herb.scientificName)) and the following medications: \(medications.joined(separator: ", ")).
        
        Please provide your response in the following JSON format:
        {
            "severity": "none|low|moderate|high",
            "interactions": [
                {
                    "herb": "\(herb.englishName)",
                    "medication": "medication_name",
                    "description": "detailed interaction description",
                    "mechanism": "how the interaction works",
                    "recommendation": "specific safety recommendation"
                }
            ],
            "recommendations": [
                "general recommendation 1",
                "general recommendation 2"
            ]
        }
        
        Consider:
        1. Known herb-drug interactions from medical literature
        2. Pharmacokinetic interactions (absorption, distribution, metabolism, excretion)
        3. Pharmacodynamic interactions (effects on the same biological target)
        4. Severity levels based on clinical significance
        5. Evidence-based recommendations
        
        If no interactions are found, return severity as "none" with empty interactions array.
        Be conservative in your assessment and always recommend consulting healthcare providers.
        """
    }
    
    private func callChatGPT(prompt: String, herb: Herb, medications: [String]) async -> DrugInteractionResult {
        print("🤖 Starting ChatGPT API call...")
        print("📝 Model: \(config.model)")
        print("🔑 API Key configured: \(config.isConfigured)")
        
        guard let url = URL(string: config.baseURL) else {
            return createErrorResult(error: "Invalid API URL")
        }
        
        // Record the request
        config.recordRequest()
        
        // Prepare the request body
        let requestBody = ChatGPTRequest(
            model: config.model,
            messages: [
                ChatGPTMessage(role: "system", content: "You are a medical AI assistant. Always respond with valid JSON in the exact format requested."),
                ChatGPTMessage(role: "user", content: prompt)
            ],
            temperature: config.temperature,
            max_tokens: config.maxTokens
        )
        
        print("📤 Sending request to OpenAI...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("✅ Request body encoded successfully")
        } catch {
            print("❌ Failed to encode request: \(error)")
            return createErrorResult(error: "Failed to encode request: \(error.localizedDescription)")
        }
        
        do {
            print("🌐 Making network request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    print("❌ API Error Response: \(responseString)")
                    
                    // Handle specific error cases
                    if httpResponse.statusCode == 429 {
                        return createErrorResult(error: "API quota exceeded. Please check your OpenAI billing or try again later.")
                    } else if httpResponse.statusCode == 401 {
                        return createErrorResult(error: "Invalid API key. Please check your configuration.")
                    } else if httpResponse.statusCode == 404 {
                        return createErrorResult(error: "Model not found. Please check your OpenAI account access.")
                    } else {
                        return createErrorResult(error: "API Error \(httpResponse.statusCode): \(responseString)")
                    }
                }
            }
            
            print("✅ Received response from OpenAI")
            print("📄 Response size: \(data.count) bytes")
            
            // Parse ChatGPT response
            return parseChatGPTResponse(data: data, herb: herb, medications: medications)
            
        } catch {
            print("❌ Network Error: \(error)")
            return createErrorResult(error: "Network Error: \(error.localizedDescription)")
        }
    }
    
    private func parseChatGPTResponse(data: Data, herb: Herb, medications: [String]) -> DrugInteractionResult {
        do {
            print("🔍 Parsing ChatGPT response...")
            let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            guard let content = chatGPTResponse.choices.first?.message.content else {
                print("❌ No response content from ChatGPT")
                return createErrorResult(error: "No response content from ChatGPT")
            }
            
            print("📝 ChatGPT Response: \(content)")
            
            // Extract JSON from ChatGPT response
            return parseInteractionJSON(content: content, herb: herb, medications: medications)
            
        } catch {
            print("❌ Failed to parse ChatGPT response: \(error)")
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("📄 Raw response: \(responseString)")
            return createErrorResult(error: "Failed to parse ChatGPT response: \(error.localizedDescription)")
        }
    }
    
    private func parseInteractionJSON(content: String, herb: Herb, medications: [String]) -> DrugInteractionResult {
        // Extract JSON from the response (ChatGPT might wrap it in markdown)
        let jsonStart = content.firstIndex(of: "{")
        let jsonEnd = content.lastIndex(of: "}")
        
        guard let start = jsonStart, let end = jsonEnd else {
            return createErrorResult(error: "No JSON found in ChatGPT response")
        }
        
        let jsonString = String(content[start...end])
        
        do {
            let interactionData = try JSONDecoder().decode(InteractionResponse.self, from: jsonString.data(using: .utf8)!)
            
            // Convert to DrugInteractionResult
            let interactions = interactionData.interactions.map { interaction in
                DrugInteraction(
                    herb: interaction.herb,
                    medication: interaction.medication,
                    description: interaction.description,
                    severity: InteractionSeverity(rawValue: interactionData.severity.lowercased()) ?? .none,
                    mechanism: interaction.mechanism,
                    recommendation: interaction.recommendation
                )
            }
            
            let severity = interactions.map { $0.severity }.max() ?? .none
            
            return DrugInteractionResult(
                hasInteractions: !interactions.isEmpty,
                interactions: interactions,
                recommendations: interactionData.recommendations,
                severity: severity
            )
            
        } catch {
            // Fallback to pattern matching if JSON parsing fails
            return fallbackAnalysis(content: content, herb: herb, medications: medications)
        }
    }
    
    private func fallbackAnalysis(content: String, herb: Herb, medications: [String]) -> DrugInteractionResult {
        // Fallback to the original pattern matching if ChatGPT response parsing fails
        return analyzeInteractions(herb: herb, medications: medications)
    }
    
    private func createErrorResult(error: String) -> DrugInteractionResult {
        print("🔴 Drug Interaction Checker Error: \(error)")
        return DrugInteractionResult(
            hasInteractions: false,
            interactions: [],
            recommendations: [
                "Error occurred while checking interactions: \(error)",
                "Please try again or consult your healthcare provider.",
                "If the problem persists, check your internet connection and API key configuration.",
                "Note: The app will use local database as fallback for safety."
            ],
            severity: .none
        )
    }
    
    // MARK: - Fallback Analysis (Original Implementation)
    private func analyzeInteractions(herb: Herb, medications: [String]) -> DrugInteractionResult {
        var interactions: [DrugInteraction] = []
        var recommendations: [String] = []
        var severity: InteractionSeverity = .none
        
        // Common herb-drug interaction patterns
        let herbName = herb.englishName.lowercased()
        let medNames = medications.map { $0.lowercased() }
        
        // Check for specific interactions
        for medication in medNames {
            if let interaction = checkSpecificInteraction(herbName: herbName, medication: medication) {
                interactions.append(interaction)
                severity = max(severity, interaction.severity)
            }
        }
        
        // Add general recommendations based on herb type
        recommendations = generateRecommendations(herb: herb, interactions: interactions)
        
        return DrugInteractionResult(
            hasInteractions: !interactions.isEmpty,
            interactions: interactions,
            recommendations: recommendations,
            severity: severity
        )
    }
    
    private func checkSpecificInteraction(herbName: String, medication: String) -> DrugInteraction? {
        // Common interaction patterns
        let interactionPatterns: [String: [String: DrugInteraction]] = [
            "ginger": [
                "warfarin": DrugInteraction(
                    herb: "Ginger",
                    medication: "Warfarin",
                    description: "May increase bleeding risk due to antiplatelet effects",
                    severity: .moderate,
                    mechanism: "Antiplatelet activity",
                    recommendation: "Monitor bleeding time, consult healthcare provider"
                ),
                "aspirin": DrugInteraction(
                    herb: "Ginger",
                    medication: "Aspirin",
                    description: "May increase bleeding risk",
                    severity: .moderate,
                    mechanism: "Additive antiplatelet effects",
                    recommendation: "Monitor for bleeding, consider dose adjustment"
                )
            ],
            "turmeric": [
                "warfarin": DrugInteraction(
                    herb: "Turmeric",
                    medication: "Warfarin",
                    description: "May increase bleeding risk and INR",
                    severity: .high,
                    mechanism: "Anticoagulant effects",
                    recommendation: "Avoid combination, monitor INR closely"
                ),
                "diabetes": DrugInteraction(
                    herb: "Turmeric",
                    medication: "Diabetes medications",
                    description: "May lower blood sugar further",
                    severity: .moderate,
                    mechanism: "Hypoglycemic effects",
                    recommendation: "Monitor blood glucose, adjust medication if needed"
                )
            ],
            "garlic": [
                "warfarin": DrugInteraction(
                    herb: "Garlic",
                    medication: "Warfarin",
                    description: "May increase bleeding risk",
                    severity: .moderate,
                    mechanism: "Anticoagulant effects",
                    recommendation: "Monitor INR, consult healthcare provider"
                )
            ],
            "ginkgo": [
                "warfarin": DrugInteraction(
                    herb: "Ginkgo",
                    medication: "Warfarin",
                    description: "May increase bleeding risk",
                    severity: .high,
                    mechanism: "Anticoagulant effects",
                    recommendation: "Avoid combination, high risk of bleeding"
                ),
                "aspirin": DrugInteraction(
                    herb: "Ginkgo",
                    medication: "Aspirin",
                    description: "May increase bleeding risk",
                    severity: .moderate,
                    mechanism: "Additive antiplatelet effects",
                    recommendation: "Monitor for bleeding, consider alternatives"
                )
            ],
            "st. john's wort": [
                "antidepressants": DrugInteraction(
                    herb: "St. John's Wort",
                    medication: "Antidepressants",
                    description: "May cause serotonin syndrome",
                    severity: .high,
                    mechanism: "Serotonergic effects",
                    recommendation: "Avoid combination, high risk of serotonin syndrome"
                ),
                "birth control": DrugInteraction(
                    herb: "St. John's Wort",
                    medication: "Birth control pills",
                    description: "May reduce contraceptive effectiveness",
                    severity: .high,
                    mechanism: "Enzyme induction",
                    recommendation: "Use alternative contraception, consult healthcare provider"
                )
            ]
        ]
        
        // Check for matches
        for (herb, medInteractions) in interactionPatterns {
            if herbName.contains(herb) || herbName.contains(herb.replacingOccurrences(of: " ", with: "")) {
                for (med, interaction) in medInteractions {
                    if medication.contains(med) || medication.contains("blood thinner") || medication.contains("anticoagulant") {
                        return interaction
                    }
                }
            }
        }
        
        // Check for general categories
        if medication.contains("blood thinner") || medication.contains("anticoagulant") || medication.contains("warfarin") {
            return DrugInteraction(
                herb: herbName.capitalized,
                medication: medication.capitalized,
                description: "May interact with blood thinning medications",
                severity: .moderate,
                mechanism: "Potential anticoagulant effects",
                recommendation: "Consult healthcare provider before use"
            )
        }
        
        if medication.contains("diabetes") || medication.contains("insulin") || medication.contains("metformin") {
            return DrugInteraction(
                herb: herbName.capitalized,
                medication: medication.capitalized,
                description: "May affect blood sugar levels",
                severity: .moderate,
                mechanism: "Potential hypoglycemic effects",
                recommendation: "Monitor blood glucose, consult healthcare provider"
            )
        }
        
        return nil
    }
    
    private func generateRecommendations(herb: Herb, interactions: [DrugInteraction]) -> [String] {
        var recommendations: [String] = []
        
        if !interactions.isEmpty {
            recommendations.append("Consult your healthcare provider before using this herb")
            recommendations.append("Monitor for any unusual symptoms or side effects")
            recommendations.append("Consider spacing herb intake from medications by 2-4 hours")
        } else {
            recommendations.append("No known interactions found with your current medications")
            recommendations.append("Continue monitoring for any unexpected effects")
        }
        
        // Add herb-specific recommendations
        let herbName = herb.englishName.lowercased()
        if herbName.contains("ginger") || herbName.contains("turmeric") {
            recommendations.append("Take with food to minimize gastrointestinal effects")
        }
        
        if herbName.contains("garlic") {
            recommendations.append("Monitor for increased bleeding risk if on blood thinners")
        }
        
        return recommendations
    }
}

// MARK: - ChatGPT API Models
struct ChatGPTRequest: Codable {
    let model: String
    let messages: [ChatGPTMessage]
    let temperature: Double
    let max_tokens: Int
}

struct ChatGPTMessage: Codable {
    let role: String
    let content: String
}

struct ChatGPTResponse: Codable {
    let choices: [ChatGPTChoice]
}

struct ChatGPTChoice: Codable {
    let message: ChatGPTMessage
}

// MARK: - Interaction Response Models
struct InteractionResponse: Codable {
    let severity: String
    let interactions: [InteractionData]
    let recommendations: [String]
}

struct InteractionData: Codable {
    let herb: String
    let medication: String
    let description: String
    let mechanism: String
    let recommendation: String
}

// MARK: - Data Models
struct DrugInteractionResult {
    let hasInteractions: Bool
    let interactions: [DrugInteraction]
    let recommendations: [String]
    let severity: InteractionSeverity
}

struct DrugInteraction {
    let herb: String
    let medication: String
    let description: String
    let severity: InteractionSeverity
    let mechanism: String
    let recommendation: String
}

enum InteractionSeverity: String, CaseIterable, Comparable {
    case none = "none"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    
    static func < (lhs: InteractionSeverity, rhs: InteractionSeverity) -> Bool {
        let order: [InteractionSeverity] = [.none, .low, .moderate, .high]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }
    
    var color: String {
        switch self {
        case .none: return "green"
        case .low: return "yellow"
        case .moderate: return "orange"
        case .high: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "checkmark.circle.fill"
        case .low: return "exclamationmark.triangle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "xmark.octagon.fill"
        }
    }
} 