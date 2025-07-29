import Foundation
import SwiftUI

// MARK: - Unit Enums
enum WeightUnit: String, CaseIterable, Codable {
    case kg = "kg"
    case lb = "lb"
    
    var displayName: String {
        switch self {
        case .kg: return "Kilograms (kg)"
        case .lb: return "Pounds (lb)"
        }
    }
    
    var shortName: String {
        switch self {
        case .kg: return "kg"
        case .lb: return "lb"
        }
    }
}

enum HeightUnit: String, CaseIterable, Codable {
    case cm = "cm"
    case ft = "ft"
    
    var displayName: String {
        switch self {
        case .cm: return "Centimeters (cm)"
        case .ft: return "Feet & Inches (ft/in)"
        }
    }
    
    var shortName: String {
        switch self {
        case .cm: return "cm"
        case .ft: return "ft"
        }
    }
}

class HealthProfileManager: ObservableObject {
    static let shared = HealthProfileManager()
    
    // MARK: - Published Properties
    @Published var age: Int = 25
    @Published var weight: Double = 70.0
    @Published var height: Double = 170.0
    @Published var weightUnit: WeightUnit = .kg
    @Published var heightUnit: HeightUnit = .cm
    @Published var healthConditions: [String] = []
    @Published var allergies: [String] = []
    @Published var medications: [String] = []
    @Published var isPregnant: Bool = false
    @Published var isNursing: Bool = false
    @Published var savedDosages: [DosageResult] = []
    
    // MARK: - Computed Properties
    var hasProfile: Bool {
        return age > 0 && weight > 0 && height > 0
    }
    
    var hasInteractions: Bool {
        return !medications.isEmpty
    }
    
    // MARK: - Unit Conversion Methods
    func convertWeight(to unit: WeightUnit) -> Double {
        switch (weightUnit, unit) {
        case (.kg, .lb):
            return weight * 2.20462
        case (.lb, .kg):
            return weight / 2.20462
        default:
            return weight
        }
    }
    
    func convertHeight(to unit: HeightUnit) -> (feet: Int, inches: Double)? {
        switch (heightUnit, unit) {
        case (.cm, .ft):
            let totalInches = height / 2.54
            let feet = Int(totalInches / 12)
            let inches = totalInches.truncatingRemainder(dividingBy: 12)
            return (feet, inches)
        case (.ft, .cm):
            return nil // We'll handle this differently
        default:
            return nil
        }
    }
    
    func getHeightInCm() -> Double {
        switch heightUnit {
        case .cm:
            return height
        case .ft:
            // Assuming height is stored as total inches when in feet
            return height * 2.54
        }
    }
    
    func getWeightInKg() -> Double {
        switch weightUnit {
        case .kg:
            return weight
        case .lb:
            return weight / 2.20462
        }
    }
    
    var bmi: Double {
        let heightInMeters = getHeightInCm() / 100
        let weightInKg = getWeightInKg()
        return weightInKg / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    // MARK: - Initialization
    private init() {
        loadProfile()
    }
    
    // MARK: - Health Conditions Management
    func addHealthCondition(_ condition: String) {
        if !healthConditions.contains(condition) {
            healthConditions.append(condition)
            saveProfile()
        }
    }
    
    func removeHealthCondition(_ condition: String) {
        healthConditions.removeAll { $0 == condition }
        saveProfile()
    }
    
    // MARK: - Allergies Management
    func addAllergy(_ allergy: String) {
        if !allergies.contains(allergy) {
            allergies.append(allergy)
            saveProfile()
        }
    }
    
    func removeAllergy(_ allergy: String) {
        allergies.removeAll { $0 == allergy }
        saveProfile()
    }
    
    // MARK: - Medications Management
    func addMedication(_ medication: String) {
        if !medications.contains(medication) {
            medications.append(medication)
            saveProfile()
        }
    }
    
    func removeMedication(_ medication: String) {
        medications.removeAll { $0 == medication }
        saveProfile()
    }
    
    // MARK: - Profile Management
    func updateBasicInfo(age: Int, weight: Double, height: Double) {
        self.age = age
        self.weight = weight
        self.height = height
        saveProfile()
    }
    
    func updateWeightUnit(_ unit: WeightUnit) {
        if weightUnit != unit {
            // Convert the weight to the new unit
            let convertedWeight = convertWeight(to: unit)
            weightUnit = unit
            weight = convertedWeight
            saveProfile()
        }
    }
    
    func updateHeightUnit(_ unit: HeightUnit) {
        if heightUnit != unit {
            // Convert the height to the new unit
            if unit == .ft {
                let heightInCm = getHeightInCm()
                let totalInches = heightInCm / 2.54
                height = totalInches
            } else {
                let heightInCm = getHeightInCm()
                height = heightInCm
            }
            heightUnit = unit
            saveProfile()
        }
    }
    
    func clearProfile() {
        age = 25
        weight = 70.0
        height = 170.0
        healthConditions.removeAll()
        allergies.removeAll()
        medications.removeAll()
        isPregnant = false
        isNursing = false
        saveProfile()
    }
    
    // MARK: - Safety Checks
    func checkHerbSafety(for herb: Herb) -> [String] {
        var warnings: [String] = []
        
        // Check pregnancy/nursing status
        if isPregnant || isNursing {
            if herb.precautions.lowercased().contains("pregnancy") ||
               herb.precautions.lowercased().contains("nursing") {
                warnings.append("Not recommended during pregnancy or nursing")
            }
        }
        
        // Check for allergies
        for allergy in allergies {
            if herb.englishName.lowercased().contains(allergy.lowercased()) ||
               herb.scientificName.lowercased().contains(allergy.lowercased()) {
                warnings.append("May contain \(allergy)")
            }
        }
        
        // Check for health conditions
        for condition in healthConditions {
            if condition.lowercased() == "diabetes" {
                if herb.uses.contains { $0.lowercased().contains("blood sugar") } {
                    warnings.append("May affect blood sugar levels")
                }
            }
            
            if condition.lowercased() == "hypertension" {
                if herb.uses.contains { $0.lowercased().contains("blood pressure") } {
                    warnings.append("May affect blood pressure")
                }
            }
        }
        
        return warnings
    }
    
    func getPersonalizedDosage(for herb: Herb) -> String {
        // First check if we have a saved dosage for this herb
        if let savedDosage = getSavedDosage(for: herb.id) {
            print("Found saved dosage for \(herb.englishName): \(savedDosage.calculatedDosage)")
            return savedDosage.calculatedDosage
        }
        
        // Fall back to basic personalized dosage
        var baseDosage = herb.dosage
        
        // Adjust for age
        if age < 18 {
            baseDosage = "1/2 - 3/4 of adult dose"
        } else if age > 65 {
            baseDosage = "3/4 of adult dose"
        }
        
        // Adjust for weight
        if weight < 50 {
            baseDosage = "Reduce dose by 25%"
        } else if weight > 100 {
            baseDosage = "Standard dose"
        }
        
        return baseDosage
    }
    
    // MARK: - Dosage Persistence Methods
    func saveDosageResult(_ dosageResult: DosageResult) {
        print("Saving dosage result for \(dosageResult.herbName): \(dosageResult.calculatedDosage)")
        
        // Remove existing dosage for this herb if it exists
        savedDosages.removeAll { $0.id == dosageResult.id }
        
        // Add new dosage result
        savedDosages.append(dosageResult)
        
        print("Current saved dosages count: \(savedDosages.count)")
        print("Saved dosages: \(savedDosages.map { "\($0.herbName): \($0.calculatedDosage)" })")
        
        // Notify observers of the change
        objectWillChange.send()
        
        // Save to UserDefaults
        saveDosagesToStorage()
        
        // Force UI refresh
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func getSavedDosage(for herbId: String) -> DosageResult? {
        print("Looking for saved dosage with herbId: \(herbId)")
        print("Available saved dosages: \(savedDosages.map { "\($0.herbName): \($0.id)" })")
        return savedDosages.first { $0.id == herbId }
    }
    
    func removeSavedDosage(for herbId: String) {
        savedDosages.removeAll { $0.id == herbId }
        objectWillChange.send()
        saveDosagesToStorage()
    }
    
    func clearAllSavedDosages() {
        savedDosages.removeAll()
        objectWillChange.send()
        saveDosagesToStorage()
    }
    
    // Debug method to check what's in UserDefaults
    func debugSavedDosages() {
        print("=== DEBUG: Saved Dosages ===")
        print("In-memory savedDosages count: \(savedDosages.count)")
        print("In-memory savedDosages: \(savedDosages.map { "\($0.herbName) (\($0.id)): \($0.calculatedDosage)" })")
        
        if let data = UserDefaults.standard.data(forKey: "saved_dosages") {
            print("UserDefaults has data for 'saved_dosages'")
            if let dosages = try? JSONDecoder().decode([DosageResult].self, from: data) {
                print("UserDefaults contains \(dosages.count) dosages")
                print("UserDefaults dosages: \(dosages.map { "\($0.herbName) (\($0.id)): \($0.calculatedDosage)" })")
            } else {
                print("Failed to decode dosages from UserDefaults")
            }
        } else {
            print("No data found in UserDefaults for 'saved_dosages'")
        }
        print("=== END DEBUG ===")
    }
    
    private func saveDosagesToStorage() {
        if let encoded = try? JSONEncoder().encode(savedDosages) {
            UserDefaults.standard.set(encoded, forKey: "saved_dosages")
            print("Successfully saved \(savedDosages.count) dosages to UserDefaults")
        } else {
            print("Failed to encode dosages for storage")
        }
    }
    
    private func loadDosagesFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "saved_dosages"),
           let dosages = try? JSONDecoder().decode([DosageResult].self, from: data) {
            savedDosages = dosages
            print("Loaded \(dosages.count) saved dosages from UserDefaults")
            print("Loaded dosages: \(dosages.map { "\($0.herbName): \($0.calculatedDosage)" })")
            objectWillChange.send()
        } else {
            print("No saved dosages found in UserDefaults")
        }
    }
    
    // MARK: - Persistence
    private func saveProfile() {
        let profile = HealthProfile(
            age: age,
            weight: weight,
            height: height,
            weightUnit: weightUnit,
            heightUnit: heightUnit,
            healthConditions: healthConditions,
            allergies: allergies,
            medications: medications,
            isPregnant: isPregnant,
            isNursing: isNursing
        )
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "health_profile")
        }
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "health_profile"),
           let profile = try? JSONDecoder().decode(HealthProfile.self, from: data) {
            age = profile.age
            weight = profile.weight
            height = profile.height
            weightUnit = profile.weightUnit
            heightUnit = profile.heightUnit
            healthConditions = profile.healthConditions
            allergies = profile.allergies
            medications = profile.medications
            isPregnant = profile.isPregnant
            isNursing = profile.isNursing
        }
        
        // Load saved dosages
        loadDosagesFromStorage()
    }
}

// MARK: - Dosage Result Model
struct DosageResult: Codable, Identifiable {
    let id: String // herb.id
    let herbName: String
    let calculatedDosage: String
    let age: Int
    let weight: Double
    let condition: String
    let conditionSeverity: String
    let dateCalculated: Date
    let isFromHealthProfile: Bool
    
    init(herbId: String, herbName: String, calculatedDosage: String, age: Int, weight: Double, condition: String, conditionSeverity: String, isFromHealthProfile: Bool) {
        self.id = herbId
        self.herbName = herbName
        self.calculatedDosage = calculatedDosage
        self.age = age
        self.weight = weight
        self.condition = condition
        self.conditionSeverity = conditionSeverity
        self.dateCalculated = Date()
        self.isFromHealthProfile = isFromHealthProfile
    }
    
    // Custom coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, herbName, calculatedDosage, age, weight, condition, conditionSeverity, dateCalculated, isFromHealthProfile
    }
}

// MARK: - Health Profile Data Model
struct HealthProfile: Codable {
    let age: Int
    let weight: Double
    let height: Double
    let weightUnit: WeightUnit
    let heightUnit: HeightUnit
    let healthConditions: [String]
    let allergies: [String]
    let medications: [String]
    let isPregnant: Bool
    let isNursing: Bool
}

// MARK: - Add Health Condition View
struct AddHealthConditionView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var conditionName = ""
    @State private var selectedCondition = ""
    
    private let commonConditions = [
        "Diabetes", "Hypertension", "Asthma", "Arthritis", "Heart Disease",
        "Depression", "Anxiety", "Insomnia", "Migraine", "Digestive Issues",
        "Allergies", "Thyroid Issues", "High Cholesterol", "Osteoporosis"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Custom condition input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Health Condition")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter condition name", text: $conditionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Common conditions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Conditions")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(commonConditions, id: \.self) { condition in
                            Button(action: {
                                selectedCondition = condition
                                conditionName = condition
                            }) {
                                Text(condition)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedCondition == condition ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedCondition == condition ? Color.blue : Color(.systemGray5))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Condition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !conditionName.isEmpty {
                            healthProfile.addHealthCondition(conditionName)
                            dismiss()
                        }
                    }
                    .disabled(conditionName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Allergy View
struct AddAllergyView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var allergyName = ""
    @State private var selectedAllergy = ""
    
    private let commonAllergies = [
        "Peanuts", "Tree Nuts", "Milk", "Eggs", "Soy", "Wheat", "Fish", "Shellfish",
        "Pollen", "Dust", "Pet Dander", "Latex", "Penicillin", "Sulfa Drugs"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Custom allergy input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Allergy")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter allergy name", text: $allergyName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Common allergies
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Allergies")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(commonAllergies, id: \.self) { allergy in
                            Button(action: {
                                selectedAllergy = allergy
                                allergyName = allergy
                            }) {
                                Text(allergy)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedAllergy == allergy ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedAllergy == allergy ? Color.orange : Color(.systemGray5))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Allergy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !allergyName.isEmpty {
                            healthProfile.addAllergy(allergyName)
                            dismiss()
                        }
                    }
                    .disabled(allergyName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Medication View
struct AddMedicationView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var medicationName = ""
    @State private var selectedMedication = ""
    
    private let commonMedications = [
        "Aspirin", "Ibuprofen", "Acetaminophen", "Lisinopril", "Metformin",
        "Atorvastatin", "Omeprazole", "Amlodipine", "Metoprolol", "Losartan",
        "Sertraline", "Fluoxetine", "Albuterol", "Warfarin", "Insulin"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Custom medication input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Medication")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter medication name", text: $medicationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Common medications
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Medications")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(commonMedications, id: \.self) { medication in
                            Button(action: {
                                selectedMedication = medication
                                medicationName = medication
                            }) {
                                Text(medication)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedMedication == medication ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedMedication == medication ? Color.purple : Color(.systemGray5))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !medicationName.isEmpty {
                            healthProfile.addMedication(medicationName)
                            dismiss()
                        }
                    }
                    .disabled(medicationName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 