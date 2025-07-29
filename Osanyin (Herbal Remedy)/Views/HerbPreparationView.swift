import SwiftUI

// MARK: - Condition Severity Enum
enum ConditionSeverity: String, CaseIterable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    
    var displayName: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        }
    }
    
    var description: String {
        switch self {
        case .mild: return "Minor symptoms, slight discomfort"
        case .moderate: return "Noticeable symptoms, some impact on daily life"
        case .severe: return "Significant symptoms, major impact on daily life"
        }
    }
    
    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .mild: return "circle.fill"
        case .moderate: return "triangle.fill"
        case .severe: return "exclamationmark.triangle.fill"
        }
    }
    
    var dosageMultiplier: Double {
        switch self {
        case .mild: return 0.7      // 70% of standard dose
        case .moderate: return 1.0   // 100% of standard dose
        case .severe: return 1.3     // 130% of standard dose
        }
    }
}

struct HerbPreparationView: View {
    let herb: Herb
    @StateObject private var healthProfile = HealthProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var age = ""
    @State private var weight = ""
    @State private var condition = ""
    @State private var showingDosageResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with herb info
                HerbPreparationHeader(herb: herb)
                
                // Health Profile Integration
                if healthProfile.hasProfile {
                    PreparationHealthProfileSection(herb: herb, healthProfile: healthProfile)
                }
                
                // Tab selector
                PreparationTabSelector(selectedTab: $selectedTab)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Step-by-step instructions
                    PreparationInstructionsView(herb: herb)
                        .tag(0)
                    
                    // Dosage calculator
                    DosageCalculatorView(
                        herb: herb,
                        age: $age,
                        weight: $weight,
                        condition: $condition,
                        showingResult: $showingDosageResult
                    )
                    .tag(1)
                    
                    // Timing recommendations
                    TimingRecommendationsView(herb: herb)
                        .tag(2)
                    
                    // Storage instructions
                    StorageInstructionsView(herb: herb)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Preparation Guide")
            .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Herb Preparation Header
struct HerbPreparationHeader: View {
    let herb: Herb
    
    var body: some View {
        VStack(spacing: 16) {
            // Herb icon and name
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(categoryColor(for: herb.category).opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: categoryIcon(for: herb.category))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(categoryColor(for: herb.category))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(herb.englishName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(herb.scientificName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            
            // Quick info cards
            HStack(spacing: 12) {
                QuickInfoCard(
                    icon: "clock.fill",
                    title: "Prep Time",
                    value: preparationTime(for: herb.category),
                    color: .blue
                )
                
                QuickInfoCard(
                    icon: "thermometer",
                    title: "Temperature",
                    value: preparationTemperature(for: herb.category),
                    color: .orange
                )
                
                QuickInfoCard(
                    icon: "drop.fill",
                    title: "Water Ratio",
                    value: waterRatio(for: herb.category),
                    color: .cyan
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "herb": return .green
        case "refresher": return .blue
        case "spice": return .orange
        case "fruit": return .red
        case "vegetable": return .purple
        default: return .gray
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "herb": return "leaf.fill"
        case "refresher": return "drop.fill"
        case "spice": return "flame.fill"
        case "fruit": return "applelogo"
        case "vegetable": return "carrot.fill"
        default: return "leaf"
        }
    }
    
    private func preparationTime(for category: String) -> String {
        switch category.lowercased() {
        case "herb": return "5-10 min"
        case "refresher": return "2-5 min"
        case "spice": return "10-15 min"
        case "fruit": return "3-8 min"
        case "vegetable": return "8-12 min"
        default: return "5-10 min"
        }
    }
    
    private func preparationTemperature(for category: String) -> String {
        switch category.lowercased() {
        case "herb": return "80-90°C"
        case "refresher": return "Cold"
        case "spice": return "100°C"
        case "fruit": return "70-80°C"
        case "vegetable": return "85-95°C"
        default: return "80-90°C"
        }
    }
    
    private func waterRatio(for category: String) -> String {
        switch category.lowercased() {
        case "herb": return "1:8"
        case "refresher": return "1:10"
        case "spice": return "1:6"
        case "fruit": return "1:12"
        case "vegetable": return "1:9"
        default: return "1:8"
        }
    }
}

// MARK: - Quick Info Card
struct QuickInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preparation Tab Selector
struct PreparationTabSelector: View {
    @Binding var selectedTab: Int
    
    private let tabs = ["Instructions", "Dosage", "Timing", "Storage"]
    private let icons = ["list.bullet", "calculator", "clock", "archivebox"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: icons[index])
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedTab == index ? .green : .secondary)
                            
                            Text(tabs[index])
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedTab == index ? .green : .secondary)
                        }
                        .frame(width: 80, height: 50)
                        .background(
                            Rectangle()
                                .fill(selectedTab == index ? Color.green.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preparation Instructions View
struct PreparationInstructionsView: View {
    let herb: Herb
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Step-by-step instructions
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Step-by-Step Instructions", icon: "list.bullet")
                    
                    ForEach(preparationSteps(for: herb.category), id: \.self) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(preparationSteps(for: herb.category).firstIndex(of: step)! + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Color.green))
                            
                            Text(step)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                
                // Tips and notes
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Preparation Tips", icon: "lightbulb.fill")
                    
                    ForEach(preparationTips(for: herb.category), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text(tip)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Safety warnings
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Safety Notes", icon: "exclamationmark.triangle.fill")
                    
                    ForEach(safetyNotes(for: herb.category), id: \.self) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Text(note)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    private func preparationSteps(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
            return [
                "Bring fresh, filtered water to a gentle boil (80-90°C)",
                "Add 1-2 teaspoons of dried herb per cup of water",
                "Cover and let steep for 5-10 minutes",
                "Strain through a fine mesh strainer",
                "Serve hot or warm as needed"
            ]
        case "refresher":
            return [
                "Use cold, filtered water or room temperature water",
                "Add 1-2 tablespoons of fresh herb per cup",
                "Let infuse for 2-4 hours at room temperature",
                "Strain and refrigerate for up to 24 hours",
                "Serve cold with ice if desired"
            ]
        case "spice":
            return [
                "Bring water to a rolling boil (100°C)",
                "Add 1/2-1 teaspoon of ground spice per cup",
                "Reduce heat and simmer for 10-15 minutes",
                "Strain through a fine mesh strainer",
                "Allow to cool slightly before serving"
            ]
        default:
            return [
                "Bring water to appropriate temperature",
                "Add herb in recommended ratio",
                "Steep for recommended time",
                "Strain and serve",
                "Store properly if not consumed immediately"
            ]
        }
    }
    
    private func preparationTips(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
            return [
                "Use fresh herbs when possible for best flavor and potency",
                "Don't boil herbs too vigorously as it can destroy beneficial compounds",
                "Steep covered to prevent volatile oils from escaping",
                "Use glass or ceramic containers to avoid metallic taste"
            ]
        case "refresher":
            return [
                "Use filtered water for best taste",
                "Don't let cold infusions sit too long to avoid spoilage",
                "Add citrus or honey for enhanced flavor",
                "Store in refrigerator and consume within 24 hours"
            ]
        case "spice":
            return [
                "Toast spices lightly before grinding for enhanced flavor",
                "Use whole spices when possible and grind fresh",
                "Don't over-boil as it can make spices bitter",
                "Add a pinch of salt to enhance flavors"
            ]
        default:
            return [
                "Always use clean, filtered water",
                "Follow recommended ratios for best results",
                "Store prepared remedies properly",
                "Consult with healthcare provider if unsure"
            ]
        }
    }
    
    private func safetyNotes(for category: String) -> [String] {
        return [
            "Start with small amounts to test tolerance",
            "Don't exceed recommended dosages",
            "Discontinue if you experience adverse reactions",
            "Consult healthcare provider if pregnant, nursing, or on medications",
            "Keep out of reach of children"
        ]
    }
}

// MARK: - Dosage Calculator View
struct DosageCalculatorView: View {
    let herb: Herb
    @StateObject private var healthProfile = HealthProfileManager.shared
    @Binding var age: String
    @Binding var weight: String
    @Binding var condition: String
    @Binding var showingResult: Bool
    
    @State private var useHealthProfile = true
    @State private var customAge = ""
    @State private var customWeight = ""
    @State private var customCondition = ""
    @State private var conditionSeverity: ConditionSeverity = .moderate
    
    private var isCalculateDisabled: Bool {
        if useHealthProfile && healthProfile.hasProfile {
            // When health profile is enabled, we have age and weight from profile
            // Condition is optional - can calculate dosage without specific condition
            return false
        } else {
            // When using custom input, require all fields
            return age.isEmpty || weight.isEmpty || condition.isEmpty
        }
    }
    
    private var effectiveAge: String {
        if useHealthProfile && healthProfile.hasProfile {
            return String(healthProfile.age)
        } else {
            return age
        }
    }
    
    private var effectiveWeight: String {
        if useHealthProfile && healthProfile.hasProfile {
            return String(format: "%.1f", healthProfile.weight)
        } else {
            return weight
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Health Profile Integration
                if healthProfile.hasProfile {
                    HealthProfileIntegrationSection(
                        healthProfile: healthProfile,
                        useHealthProfile: $useHealthProfile
                    )
                }
                
                // Input fields
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Dosage Calculator", icon: "calculator")
                    
                    if useHealthProfile && healthProfile.hasProfile {
                        // Show health profile data with option to modify
                        VStack(spacing: 16) {
                            DosageInputField(
                                title: "Age (years)",
                                value: Binding(
                                    get: { String(healthProfile.age) },
                                    set: { customAge = $0 }
                                ),
                                placeholder: "Enter your age",
                                icon: "person.fill",
                                isFromProfile: true
                            )
                            
                            DosageInputField(
                                title: "Weight (\(healthProfile.weightUnit.shortName))",
                                value: Binding(
                                    get: { String(format: "%.1f", healthProfile.weight) },
                                    set: { customWeight = $0 }
                                ),
                                placeholder: "Enter your weight",
                                icon: "scalemass.fill",
                                isFromProfile: true
                            )
                            
                            // Condition selector with health profile integration
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.red)
                                        .frame(width: 20)
                                    
                                    Text("Condition")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                
                                ConditionSelectorView(
                                    selectedCondition: $condition,
                                    healthConditions: healthProfile.healthConditions
                                )
                            }
                            
                            // Condition Severity Selector
                            ConditionSeveritySelector(selectedSeverity: $conditionSeverity)
                        }
                    } else {
                        // Show custom input fields
                        VStack(spacing: 16) {
                            DosageInputField(
                                title: "Age (years)",
                                value: $age,
                                placeholder: "Enter your age",
                                icon: "person.fill"
                            )
                            
                            DosageInputField(
                                title: "Weight (\(healthProfile.weightUnit.shortName))",
                                value: $weight,
                                placeholder: "Enter your weight",
                                icon: "scalemass.fill"
                            )
                            
                            // Condition selector (same as health profile section)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.red)
                                        .frame(width: 20)
                                    
                                    Text("Condition")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                
                                ConditionSelectorView(
                                    selectedCondition: $condition,
                                    healthConditions: healthProfile.healthConditions
                                )
                            }
                            
                            // Condition Severity Selector
                            ConditionSeveritySelector(selectedSeverity: $conditionSeverity)
                        }
                    }
                    
                    Button(action: {
                        showingResult = true
                    }) {
                        HStack {
                            Image(systemName: "calculator.fill")
                            Text("Calculate Dosage")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                    }
                    .disabled(isCalculateDisabled)
                    .opacity(isCalculateDisabled ? 0.6 : 1.0)
                }
                
                // General dosage guidelines
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "General Guidelines", icon: "info.circle.fill")
                    
                    VStack(spacing: 12) {
                        DosageGuidelineCard(
                            title: "Adults (18+)",
                            dosage: "1-2 cups per day",
                            frequency: "2-3 times daily",
                            color: .blue
                        )
                        
                        DosageGuidelineCard(
                            title: "Teens (13-17)",
                            dosage: "1 cup per day",
                            frequency: "1-2 times daily",
                            color: .green
                        )
                        
                        DosageGuidelineCard(
                            title: "Children (6-12)",
                            dosage: "1/2 cup per day",
                            frequency: "1 time daily",
                            color: .orange
                        )
                        
                        DosageGuidelineCard(
                            title: "Children (2-5)",
                            dosage: "1/4 cup per day",
                            frequency: "1 time daily",
                            color: .red
                        )
                    }
                }
            }
            .padding(20)
        }
        .sheet(isPresented: $showingResult) {
            DosageResultView(
                herb: herb,
                age: effectiveAge,
                weight: effectiveWeight,
                condition: condition,
                conditionSeverity: conditionSeverity,
                healthProfile: healthProfile
            )
        }
    }
}

// MARK: - Condition Severity Selector
struct ConditionSeveritySelector: View {
    @Binding var selectedSeverity: ConditionSeverity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                Text("Condition Severity")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(ConditionSeverity.allCases, id: \.self) { severity in
                    SeverityOptionCard(
                        severity: severity,
                        isSelected: selectedSeverity == severity
                    ) {
                        selectedSeverity = severity
                    }
                }
            }
        }
    }
}

struct SeverityOptionCard: View {
    let severity: ConditionSeverity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: severity.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(severity.color)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(severity.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(severity.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(severity.color)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? severity.color.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? severity.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Condition Selector View
struct ConditionSelectorView: View {
    @Binding var selectedCondition: String
    let healthConditions: [String]
    
    @State private var showingConditionPicker = false
    @State private var customCondition = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Health Profile Conditions (if available)
            if !healthConditions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Health Conditions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(healthConditions, id: \.self) { condition in
                                ConditionChip(
                                    condition: condition,
                                    isSelected: selectedCondition == condition
                                ) {
                                    selectedCondition = condition
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            // Custom Condition Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Or enter custom condition (optional)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    TextField("e.g., headache, insomnia, stress", text: $customCondition)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: customCondition) { newValue in
                            if !newValue.isEmpty {
                                selectedCondition = newValue
                            }
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Selected Condition Display
            if !selectedCondition.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Selected: \(selectedCondition)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Clear") {
                        selectedCondition = ""
                        customCondition = ""
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
    }
}

struct ConditionChip: View {
    let condition: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(condition)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.green : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Health Profile Integration Section
struct HealthProfileIntegrationSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Binding var useHealthProfile: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Health Profile Integration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $useHealthProfile)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            
            if useHealthProfile {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Using your health profile data:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            ProfileDataChip(
                                label: "Age",
                                value: "\(healthProfile.age) years",
                                icon: "person.fill",
                                color: .blue
                            )
                            
                            ProfileDataChip(
                                label: "Weight",
                                value: formatWeight(healthProfile.weight, unit: healthProfile.weightUnit),
                                icon: "scalemass.fill",
                                color: .green
                            )
                        }
                        
                        // Health Conditions
                        if !healthProfile.healthConditions.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Health Conditions:")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(healthProfile.healthConditions, id: \.self) { condition in
                                            Text(condition)
                                                .font(.system(size: 10, weight: .medium))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 3)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.red.opacity(0.1))
                                                )
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("You can select from your health conditions or enter custom conditions below (optional).")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            } else {
                Text("Enter custom values below")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct ProfileDataChip: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Dosage Input Field
struct DosageInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let icon: String
    let isFromProfile: Bool
    
    init(title: String, value: Binding<String>, placeholder: String, icon: String, isFromProfile: Bool = false) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.icon = icon
        self.isFromProfile = isFromProfile
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                if isFromProfile {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.green)
                        
                        Text("Profile")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField(placeholder, text: $value)
                    .font(.system(size: 16))
                    .textFieldStyle(PlainTextFieldStyle())
                    .disabled(isFromProfile)
                    .opacity(isFromProfile ? 0.7 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Dosage Guideline Card
struct DosageGuidelineCard: View {
    let title: String
    let dosage: String
    let frequency: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(title.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(dosage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(frequency)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Dosage Result View
struct DosageResultView: View {
    let herb: Herb
    let age: String
    let weight: String
    let condition: String
    let conditionSeverity: ConditionSeverity
    let healthProfile: HealthProfileManager?
    @Environment(\.dismiss) private var dismiss
    
    init(herb: Herb, age: String, weight: String, condition: String, conditionSeverity: ConditionSeverity, healthProfile: HealthProfileManager? = nil) {
        self.herb = herb
        self.age = age
        self.weight = weight
        self.condition = condition
        self.conditionSeverity = conditionSeverity
        self.healthProfile = healthProfile
    }
    
    private var calculatedDosage: String {
        guard let ageInt = Int(age), let weightDouble = Double(weight) else {
            return "Please enter valid values"
        }
        
        // Age-based adjustments (take priority)
        if ageInt < 2 {
            return "Consult healthcare provider"
        } else if ageInt < 6 {
            return applySeverityToAgeBasedDosage("1/4 cup, 1 time daily")
        } else if ageInt < 13 {
            return applySeverityToAgeBasedDosage("1/2 cup, 1 time daily")
        } else if ageInt < 18 {
            return applySeverityToAgeBasedDosage("1 cup, 1-2 times daily")
        } else {
            // For adults, use herb's standard dosage with severity adjustment
            return applySeverityToStandardDosage(herb.dosage)
        }
    }
    
    private func applySeverityToStandardDosage(_ standardDosage: String) -> String {
        // Handle common dosage patterns
        if standardDosage.contains("cups") {
            return applySeverityToCupDosage(standardDosage)
        } else if standardDosage.contains("before bedtime") {
            return applySeverityToBedtimeDosage(standardDosage)
        } else {
            // Generic adjustment
            return "\(standardDosage) (adjusted for \(conditionSeverity.displayName.lowercased()) condition)"
        }
    }
    
    private func applySeverityToAgeBasedDosage(_ ageDosage: String) -> String {
        // For age-based dosages, apply severity but be more conservative
        let conservativeMultiplier = min(conditionSeverity.dosageMultiplier, 1.2) // Cap at 120%
        
        if ageDosage.contains("1/4 cup") {
            switch conditionSeverity {
            case .mild: return "1/5 cup, 1 time daily"
            case .moderate: return "1/4 cup, 1 time daily"
            case .severe: return "1/3 cup, 1 time daily"
            }
        } else if ageDosage.contains("1/2 cup") {
            switch conditionSeverity {
            case .mild: return "1/3 cup, 1 time daily"
            case .moderate: return "1/2 cup, 1 time daily"
            case .severe: return "2/3 cup, 1 time daily"
            }
        } else if ageDosage.contains("1 cup") {
            switch conditionSeverity {
            case .mild: return "3/4 cup, 1-2 times daily"
            case .moderate: return "1 cup, 1-2 times daily"
            case .severe: return "1 1/4 cups, 1-2 times daily"
            }
        }
        
        return ageDosage
    }
    
    private func applySeverityToCupDosage(_ dosage: String) -> String {
        // Extract cup amounts and apply severity
        if dosage.contains("1-2 cups") {
            switch conditionSeverity {
            case .mild: return "0.7-1.4 cups daily"
            case .moderate: return "1-2 cups daily"
            case .severe: return "1.3-2.6 cups daily"
            }
        } else if dosage.contains("1-3 cups") {
            switch conditionSeverity {
            case .mild: return "0.7-2.1 cups daily"
            case .moderate: return "1-3 cups daily"
            case .severe: return "1.3-3.9 cups daily"
            }
        } else if dosage.contains("2-4 cups") {
            switch conditionSeverity {
            case .mild: return "1.4-2.8 cups daily"
            case .moderate: return "2-4 cups daily"
            case .severe: return "2.6-5.2 cups daily"
            }
        } else if dosage.contains("1 cup") && !dosage.contains("1-2") {
            switch conditionSeverity {
            case .mild: return "0.7 cups daily"
            case .moderate: return "1 cup daily"
            case .severe: return "1.3 cups daily"
            }
        } else if dosage.contains("2 cups") {
            switch conditionSeverity {
            case .mild: return "1.4 cups daily"
            case .moderate: return "2 cups daily"
            case .severe: return "2.6 cups daily"
            }
        }
        
        return dosage
    }
    
    private func applySeverityToBedtimeDosage(_ dosage: String) -> String {
        // Handle bedtime-specific dosages
        if dosage.contains("1-2 cups before bedtime") {
            switch conditionSeverity {
            case .mild: return "0.7-1.4 cups before bedtime"
            case .moderate: return "1-2 cups before bedtime"
            case .severe: return "1.3-2.6 cups before bedtime"
            }
        } else if dosage.contains("1 cup before bedtime") {
            switch conditionSeverity {
            case .mild: return "0.7 cups before bedtime"
            case .moderate: return "1 cup before bedtime"
            case .severe: return "1.3 cups before bedtime"
            }
        }
        
        return dosage
    }
    
    private var safetyWarnings: [String] {
        guard let healthProfile = healthProfile else { return [] }
        return healthProfile.checkHerbSafety(for: herb)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Result header
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Recommended Dosage")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Based on your profile")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // Dosage result
                    VStack(spacing: 16) {
                        Text(calculatedDosage)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("for \(herb.englishName)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.1))
                    )
                    
                    // Profile summary
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Your Profile", icon: "person.fill")
                        
                        VStack(spacing: 12) {
                            ProfileRow(title: "Age", value: "\(age) years")
                            if let healthProfile = healthProfile {
                                ProfileRow(title: "Weight", value: formatWeight(healthProfile.weight, unit: healthProfile.weightUnit))
                            } else {
                                ProfileRow(title: "Weight", value: formatWeight(Double(weight) ?? 0, unit: .kg))
                            }
                            ProfileRow(title: "Condition", value: condition.isEmpty ? "General wellness" : condition)
                            ProfileRow(title: "Severity", value: "\(conditionSeverity.displayName) (\(conditionSeverity.description))")
                        }
                    }
                    
                    // Safety warnings
                    if !safetyWarnings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Safety Warnings", icon: "exclamationmark.triangle.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(safetyWarnings, id: \.self) { warning in
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.orange)
                                        
                                        Text(warning)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                    }
                    
                    // Important notes
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Important Notes", icon: "info.circle.fill")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• This is a general recommendation")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("• Start with smaller amounts and increase gradually")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("• Consult healthcare provider for specific conditions")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("• Discontinue if adverse reactions occur")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Notification Options
                    NotificationOptionsSection(herb: herb, dosage: calculatedDosage)
                    
                    // Save dosage button
                    VStack(spacing: 16) {
                        Button(action: saveDosageResult) {
                            HStack(spacing: 8) {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Save Dosage")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if let healthProfile = healthProfile, healthProfile.getSavedDosage(for: herb.id) != nil {
                            Text("Dosage saved! It will appear in herb details.")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(20)
            }
            .navigationTitle("Dosage Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveDosageResult() {
        print("saveDosageResult() called")
        print("herb.id: \(herb.id)")
        print("herb.englishName: \(herb.englishName)")
        print("calculatedDosage: \(calculatedDosage)")
        print("age: \(age)")
        print("weight: \(weight)")
        print("condition: \(condition)")
        print("conditionSeverity: \(conditionSeverity.rawValue)")
        
        guard let healthProfile = healthProfile else { 
            print("healthProfile is nil!")
            return 
        }
        
        let dosageResult = DosageResult(
            herbId: herb.id,
            herbName: herb.englishName,
            calculatedDosage: calculatedDosage,
            age: Int(age) ?? 0,
            weight: Double(weight) ?? 0,
            condition: condition.isEmpty ? "General wellness" : condition,
            conditionSeverity: conditionSeverity.rawValue,
            isFromHealthProfile: true
        )
        
        print("Created DosageResult: \(dosageResult.herbName) - \(dosageResult.calculatedDosage)")
        healthProfile.saveDosageResult(dosageResult)
        print("Called healthProfile.saveDosageResult()")
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Notification Options Section
struct NotificationOptionsSection: View {
    let herb: Herb
    let dosage: String
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var showingNotificationAlert = false
    @State private var notificationAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Reminders", icon: "bell.fill")
            
            if notificationsEnabled {
                VStack(spacing: 12) {
                    NotificationOptionCard(
                        title: "Dosage Reminder",
                        description: "Get reminded to take your \(herb.englishName)",
                        icon: "clock.fill",
                        color: .green
                    ) {
                        scheduleDosageReminder()
                    }
                    
                    NotificationOptionCard(
                        title: "Preparation Reminder",
                        description: "Reminder to prepare your remedy",
                        icon: "leaf.fill",
                        color: .blue
                    ) {
                        schedulePreparationReminder()
                    }
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bell.slash.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        Text("Notifications are disabled")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Text("Enable notifications in Settings to get dosage and preparation reminders")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .alert("Notification", isPresented: $showingNotificationAlert) {
            Button("OK") { }
        } message: {
            Text(notificationAlertMessage)
        }
    }
    
    private func scheduleDosageReminder() {
        NotificationService.shared.scheduleDosageReminder(herbName: herb.englishName, frequency: dosage)
        notificationAlertMessage = "Dosage reminder scheduled! You'll be notified in 2 hours."
        showingNotificationAlert = true
    }
    
    private func schedulePreparationReminder() {
        NotificationService.shared.schedulePreparationReminder(herbName: herb.englishName, preparationTime: "1 hour before dosage")
        notificationAlertMessage = "Preparation reminder scheduled! You'll be notified in 1 hour."
        showingNotificationAlert = true
    }
}

struct NotificationOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Timing Recommendations View
struct TimingRecommendationsView: View {
    let herb: Herb
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Best times to take
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Best Times to Take", icon: "clock.fill")
                    
                    VStack(spacing: 12) {
                        TimingCard(
                            time: "Morning",
                            description: "Start your day with energy and focus",
                            icon: "sunrise.fill",
                            color: .orange
                        )
                        
                        TimingCard(
                            time: "Afternoon",
                            description: "Maintain energy and reduce stress",
                            icon: "sun.max.fill",
                            color: .yellow
                        )
                        
                        TimingCard(
                            time: "Evening",
                            description: "Relax and prepare for sleep",
                            icon: "moon.fill",
                            color: .blue
                        )
                        
                        TimingCard(
                            time: "Before Meals",
                            description: "Enhance digestion and absorption",
                            icon: "fork.knife",
                            color: .green
                        )
                    }
                }
                
                // Frequency recommendations
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Frequency Guidelines", icon: "repeat")
                    
                    VStack(spacing: 12) {
                        FrequencyCard(
                            frequency: "Daily",
                            description: "For general wellness and maintenance",
                            duration: "Ongoing",
                            color: .green
                        )
                        
                        FrequencyCard(
                            frequency: "2-3 times daily",
                            description: "For acute conditions or symptoms",
                            duration: "1-2 weeks",
                            color: .orange
                        )
                        
                        FrequencyCard(
                            frequency: "As needed",
                            description: "For occasional relief",
                            duration: "When symptoms occur",
                            color: .blue
                        )
                    }
                }
                
                // Seasonal considerations
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Seasonal Considerations", icon: "calendar")
                    
                    VStack(spacing: 12) {
                        SeasonalCard(
                            season: "Spring",
                            recommendation: "Detoxifying and energizing herbs",
                            icon: "leaf.fill",
                            color: .green
                        )
                        
                        SeasonalCard(
                            season: "Summer",
                            recommendation: "Cooling and hydrating herbs",
                            icon: "sun.max.fill",
                            color: .orange
                        )
                        
                        SeasonalCard(
                            season: "Autumn",
                            recommendation: "Strengthening and grounding herbs",
                            icon: "leaf",
                            color: .brown
                        )
                        
                        SeasonalCard(
                            season: "Winter",
                            recommendation: "Warming and immune-boosting herbs",
                            icon: "snowflake",
                            color: .blue
                        )
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Timing Card
struct TimingCard: View {
    let time: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Frequency Card
struct FrequencyCard: View {
    let frequency: String
    let description: String
    let duration: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(frequency)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(duration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Seasonal Card
struct SeasonalCard: View {
    let season: String
    let recommendation: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(season)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(recommendation)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Storage Instructions View
struct StorageInstructionsView: View {
    let herb: Herb
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Storage containers
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Storage Containers", icon: "archivebox.fill")
                    
                    VStack(spacing: 12) {
                        StorageCard(
                            container: "Glass Jars",
                            description: "Best for long-term storage, prevents light damage",
                            icon: "cylinder.fill",
                            color: .blue
                        )
                        
                        StorageCard(
                            container: "Ceramic Containers",
                            description: "Good for bulk storage, maintains temperature",
                            icon: "circle.fill",
                            color: .brown
                        )
                        
                        StorageCard(
                            container: "Stainless Steel",
                            description: "Durable and airtight, good for travel",
                            icon: "cube.fill",
                            color: .gray
                        )
                        
                        StorageCard(
                            container: "Paper Bags",
                            description: "Short-term storage, allows air circulation",
                            icon: "doc.fill",
                            color: .orange
                        )
                    }
                }
                
                // Storage conditions
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Storage Conditions", icon: "thermometer")
                    
                    VStack(spacing: 12) {
                        ConditionCard(
                            condition: "Temperature",
                            value: "15-25°C (59-77°F)",
                            description: "Keep in a cool, dry place",
                            icon: "thermometer",
                            color: .red
                        )
                        
                        ConditionCard(
                            condition: "Humidity",
                            value: "Below 60%",
                            description: "Avoid moisture to prevent mold",
                            icon: "drop.fill",
                            color: .blue
                        )
                        
                        ConditionCard(
                            condition: "Light",
                            value: "Dark place",
                            description: "Protect from direct sunlight",
                            icon: "sun.max.fill",
                            color: .yellow
                        )
                        
                        ConditionCard(
                            condition: "Air",
                            value: "Airtight container",
                            description: "Prevent oxidation and contamination",
                            icon: "wind",
                            color: .cyan
                        )
                    }
                }
                
                // Shelf life
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Shelf Life", icon: "calendar.badge.clock")
                    
                    VStack(spacing: 12) {
                        ShelfLifeCard(
                            type: "Dried Herbs",
                            duration: "1-2 years",
                            conditions: "Stored properly in airtight containers",
                            color: .green
                        )
                        
                        ShelfLifeCard(
                            type: "Fresh Herbs",
                            duration: "1-2 weeks",
                            conditions: "Refrigerated in damp paper towel",
                            color: .orange
                        )
                        
                        ShelfLifeCard(
                            type: "Prepared Tea",
                            duration: "24-48 hours",
                            conditions: "Refrigerated in sealed container",
                            color: .red
                        )
                        
                        ShelfLifeCard(
                            type: "Tinctures",
                            duration: "3-5 years",
                            conditions: "Stored in dark glass bottles",
                            color: .purple
                        )
                    }
                }
                
                // Storage tips
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Storage Tips", icon: "lightbulb.fill")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(storageTips(), id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                Text(tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    private func storageTips() -> [String] {
        return [
            "Label containers with herb name and date of storage",
            "Store different herbs separately to prevent cross-contamination",
            "Check for signs of mold, moisture, or unusual odors regularly",
            "Use oldest herbs first (first in, first out principle)",
            "Keep herbs away from strong-smelling substances",
            "Consider using silica gel packets for extra moisture protection",
            "Store prepared remedies in the refrigerator when possible",
            "Freeze fresh herbs in ice cube trays for longer preservation"
        ]
    }
}

// MARK: - Storage Card
struct StorageCard: View {
    let container: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(container)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Condition Card
struct ConditionCard: View {
    let condition: String
    let value: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Text(condition)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Shelf Life Card
struct ShelfLifeCard: View {
    let type: String
    let duration: String
    let conditions: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(type)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(duration)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(conditions)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preparation Health Profile Section
struct PreparationHealthProfileSection: View {
    let herb: Herb
    @ObservedObject var healthProfile: HealthProfileManager
    
    private var safetyWarnings: [String] {
        healthProfile.checkHerbSafety(for: herb)
    }
    
    private var personalizedDosage: String {
        healthProfile.getPersonalizedDosage(for: herb)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Personalized Preparation Info
            PersonalizedPreparationCard(herb: herb, healthProfile: healthProfile)
            
            // Safety Warnings for Preparation
            if !safetyWarnings.isEmpty {
                PreparationSafetyCard(warnings: safetyWarnings)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct PersonalizedPreparationCard: View {
    let herb: Herb
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Personalized for You")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Age-based adjustments
                if healthProfile.age < 18 {
                    PreparationAdjustmentRow(
                        icon: "person.2.fill",
                        title: "Youth Dosage",
                        description: "Reduce strength by 25-50% for safety"
                    )
                } else if healthProfile.age > 65 {
                    PreparationAdjustmentRow(
                        icon: "person.3.fill",
                        title: "Senior Dosage",
                        description: "Start with 75% of standard dose"
                    )
                }
                
                // Weight-based adjustments
                if healthProfile.weight < 50 {
                    PreparationAdjustmentRow(
                        icon: "scalemass.fill",
                        title: "Light Weight",
                        description: "Reduce dosage by 20%"
                    )
                } else if healthProfile.weight > 100 {
                    PreparationAdjustmentRow(
                        icon: "scalemass.fill",
                        title: "Heavy Weight",
                        description: "Standard dosage appropriate"
                    )
                }
                
                // Pregnancy/Nursing adjustments
                if healthProfile.isPregnant || healthProfile.isNursing {
                    PreparationAdjustmentRow(
                        icon: "figure.and.child.holdinghands",
                        title: "Pregnancy/Nursing",
                        description: "Consult healthcare provider before use"
                    )
                }
                
                // Medication interactions
                if !healthProfile.medications.isEmpty {
                    PreparationAdjustmentRow(
                        icon: "pills.fill",
                        title: "Medication Alert",
                        description: "Check for interactions with your medications"
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct PreparationAdjustmentRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PreparationSafetyCard: View {
    let warnings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.orange)
                
                Text("Preparation Safety")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(warnings, id: \.self) { warning in
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4))
                            .foregroundColor(.orange)
                        
                        Text(warning)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.1))
        )
    }
}

#Preview {
    HerbPreparationView(herb: Herb(
        id: "sample_herb",
        englishName: "Sample Herb",
        localNames: ["EN": "Sample"],
        scientificName: "Sample herbus",
        description: "A sample herb for preview purposes.",
        uses: ["Sample use"],
        category: "Herb",
        vitamins: ["A", "C"],
        nutrition: Nutrition(calories: 10, carbs: 2.0),
        ailments: ["Sample ailment"],
        locations: ["Sample location"],
        preparation: "Sample preparation method",
        dosage: "1 cup daily",
        precautions: "Sample precaution",
        honeyUsage: "Sample honey usage",
        continents: ["AF"],
        wikipediaUrl: "https://example.com"
    ))
} 