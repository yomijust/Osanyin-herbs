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
                    color: .blue,
                    showInfo: false
                )
                
                QuickInfoCard(
                    icon: "thermometer",
                    title: "Temperature",
                    value: preparationTemperature(for: herb.category),
                    color: .orange,
                    showInfo: false
                )
                
                QuickInfoCard(
                    icon: "drop.fill",
                    title: "Water Ratio (i)",
                    value: waterRatio(for: herb.category),
                    color: .cyan,
                    showInfo: true
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
    let showInfo: Bool
    
    @State private var showingInfo = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
                if showInfo {
                    Button(action: {
                        showingInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            Text(title.replacingOccurrences(of: " (i)", with: ""))
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
        .sheet(isPresented: $showingInfo) {
            WaterRatioInfoView()
        }
    }
}

// MARK: - Water Ratio Info View
struct WaterRatioInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.cyan)
                            
                            Text("Water Ratio Explained")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Understanding the 1:8 ratio and other herbal preparation ratios")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Main Explanation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What Does 1:8 Water Ratio Mean?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("When you see \"1:8 water ratio\" in the preparation instructions, it means:")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Text("1.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                Text("Measure your herb first (e.g., 1 tablespoon)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("2.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                Text("Add 8 times that amount of water (e.g., 8 tablespoons = 1/2 cup)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("3.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                Text("This ensures the proper concentration for optimal results")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.leading, 10)
                        
                        // Gold Standard Note
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.yellow)
                                
                                Text("Gold Standard")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Text("The 1:8 ratio is a gold standard in herbal preparation, providing the right balance of effectiveness, safety, and palatability for most herbal remedies.")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(.leading, 24)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    }
                    
                    // Examples Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Practical Examples")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ExampleCard(
                                title: "By Volume (Cups)",
                                examples: [
                                    "1 cup herb + 8 cups water",
                                    "1/2 cup herb + 4 cups water",
                                    "1/4 cup herb + 2 cups water"
                                ]
                            )
                            
                            ExampleCard(
                                title: "By Weight (Grams)",
                                examples: [
                                    "10 grams herb + 80 grams water",
                                    "5 grams herb + 40 grams water",
                                    "20 grams herb + 160 grams water"
                                ]
                            )
                        }
                    }
                    
                    // Why This Matters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why This Ratio Matters")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            BenefitRow(
                                icon: "leaf.fill",
                                title: "Extraction Efficiency",
                                description: "Optimal concentration for most herbal preparations"
                            )
                            
                            BenefitRow(
                                icon: "shield.fill",
                                title: "Safety",
                                description: "Prevents over-concentration and reduces risk of adverse effects"
                            )
                            
                            BenefitRow(
                                icon: "heart.fill",
                                title: "Palatability",
                                description: "Pleasant flavor without being overwhelming"
                            )
                        }
                    }
                }
                .padding(20)
            }
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

// MARK: - Example Card
struct ExampleCard: View {
    let title: String
    let examples: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(examples, id: \.self) { example in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.blue)
                        
                        Text(example)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.leading, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
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
                // Ingredients Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Ingredients", icon: "leaf.fill")
                    
                    ForEach(ingredientsList(for: herb.category), id: \.self) { ingredient in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                                .padding(.top, 6)
                            
                            Text(ingredient)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                
                // Detailed Preparation Instructions
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Detailed Preparation Instructions", icon: "cup.and.saucer.fill")
                    
                    ForEach(detailedPreparationSteps(for: herb.category), id: \.self) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(detailedPreparationSteps(for: herb.category).firstIndex(of: step)! + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Color.blue))
                            
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
    
    // MARK: - Ingredients List
    private func ingredientsList(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
            return [
                "1-2 teaspoons dried herbs (or 2-4 tablespoons fresh herbs)",
                "1 cup filtered water or spring water",
                "Optional: honey, lemon, or natural sweetener to taste"
            ]
        case "root":
            return [
                "1 tablespoon dried root (or 2-3 tablespoons fresh root)",
                "2 cups filtered water or spring water",
                "Optional: honey, cinnamon, or ginger for flavor"
            ]
        case "bark":
            return [
                "10-15 grams dried bark (or 20-30 grams fresh bark)",
                "2-3 cups filtered water or spring water",
                "Optional: honey or maple syrup for sweetness"
            ]
        case "tonic":
            return [
                "1-2 tablespoons dried tonic herbs (traditional aphrodisiac blends may include Tongkat Ali, Maca Root, Ginseng, Tribulus Terrestris)",
                "2 cups filtered water or spring water",
                "Optional: honey, lemon, or apple cider vinegar",
                "Optional: palm wine (for traditional Nigerian preparations like Mu Oko Le)"
            ]
        case "mixed tonic":
            return [
                "1 tablespoon each of 2-3 different herbs",
                "3 cups filtered water or spring water",
                "Optional: honey, lemon, or ginger for balance"
            ]
        case "refresher":
            return [
                "1-2 teaspoons dried refreshing herbs",
                "1 cup filtered water or spring water",
                "Optional: mint leaves, lemon, or cucumber slices"
            ]
        case "spice":
            return [
                "1/2-1 teaspoon dried spice",
                "1 cup filtered water or spring water",
                "Optional: honey, milk, or coconut milk"
            ]
        default:
            return [
                "1-2 teaspoons dried herbs",
                "1 cup filtered water or spring water",
                "Optional: honey or natural sweetener to taste"
            ]
        }
    }
    

    
    private func detailedPreparationSteps(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
            return [
                "GATHER YOUR EQUIPMENT: Start by collecting all necessary tools - a clean glass or ceramic teapot (avoid metal as it can affect taste), a fine mesh strainer with very small holes, measuring spoons (1 teaspoon and 1 tablespoon), a kitchen timer, a clean cloth or paper towels, and fresh filtered water. Make sure everything is clean and dry before starting",
                "PREPARE YOUR WORKSPACE: Choose a clean, well-lit area near your stove. Clear the counter of any clutter and ensure you have enough space to work comfortably. Have a clean towel ready for any spills, and make sure your teapot and strainer are easily accessible",
                "MEASURE YOUR HERBS PRECISELY: Use 1-2 teaspoons of dried herbs per cup of water. For a single serving, use 1 teaspoon; for stronger tea or multiple servings, use 2 teaspoons. If using fresh herbs, use 2-3 times the amount (2-4 tablespoons per cup). Always measure herbs before adding water to ensure accuracy",
                "SELECT THE RIGHT WATER: Use fresh, filtered water or spring water. Avoid tap water if it has a strong chlorine taste or odor. The quality of water directly affects the taste and effectiveness of your herbal tea. If using tap water, let it run for 30 seconds to clear any standing water",
                "HEAT WATER TO THE CORRECT TEMPERATURE: For delicate herbs (like chamomile, mint, or lavender), heat water to 80-85°C (175-185°F) - you'll see small bubbles forming but not a rolling boil. For tougher herbs (like rosemary or sage), use 90-95°C (195-205°F). Use a thermometer if available, or watch for the right bubble size",
                "PRE-WARM YOUR TEAPOT: Pour a small amount of hot water into your teapot, swirl it around to warm the entire surface, then pour it out. This prevents the teapot from absorbing heat from your brewing water, ensuring consistent temperature throughout the steeping process",
                "ADD HERBS TO THE TEAPOT: Gently place your measured herbs into the pre-warmed teapot. Don't pack them down - let them settle naturally. If using loose herbs, you can place them directly in the pot; if using tea bags, place them in the pot",
                "POUR WATER OVER HERBS: Slowly and carefully pour the hot water over the herbs, ensuring all herbs are completely submerged. Pour in a circular motion to distribute the herbs evenly. The water should cover the herbs by at least 1/2 inch",
                "COVER IMMEDIATELY: Put the lid on your teapot right away to prevent volatile oils (the beneficial compounds) from escaping into the air. This is crucial for maintaining the therapeutic properties and flavor of your herbs",
                "SET THE TIMER: Set your kitchen timer for the appropriate steeping time: 5-7 minutes for delicate herbs, 7-10 minutes for medium-strength herbs, or 10-15 minutes for strong herbs. Never exceed 15 minutes as over-steeping can make tea bitter",
                "MONITOR THE STEEPING: During steeping, resist the urge to lift the lid or stir the herbs. The tea needs to steep undisturbed to extract the proper balance of compounds. You can gently swirl the pot once or twice if needed, but don't open the lid",
                "PREPARE YOUR SERVING VESSEL: While the tea is steeping, prepare your cup or mug. Warm it with hot water if desired, then empty it. Have your strainer ready and positioned over the cup",
                "STRAIN THE TEA: After the timer goes off, carefully pour the tea through your fine mesh strainer into your prepared cup. Hold the strainer close to the cup to prevent splashing. Gently press any remaining liquid from the herbs with the back of a spoon",
                "SERVE IMMEDIATELY: Drink your tea while it's still hot or warm for the best flavor and therapeutic benefits. The optimal drinking temperature is 60-70°C (140-160°F) - hot enough to be comforting but not so hot it burns your mouth",
                "CLEAN UP PROPERLY: Rinse your teapot, strainer, and utensils with hot water immediately after use. Don't use soap unless necessary, as it can leave residues that affect future brews. Let everything air dry completely before storing"
            ]
        case "root":
            return [
                "GATHER YOUR EQUIPMENT: Collect a heavy-bottomed pot (stainless steel or enameled cast iron), a fine mesh strainer, measuring spoons, a kitchen scale (optional but recommended), a wooden spoon, a kitchen timer, and clean filtered water. Heavy-bottomed pots prevent scorching during long cooking times",
                "PREPARE YOUR WORKSPACE: Choose a well-ventilated area near your stove. Root preparations can take 20-30 minutes, so ensure you have time to monitor the process. Have a clean towel and paper towels ready for any spills or cleanup",
                "INSPECT AND CLEAN ROOTS: Examine your roots for any signs of mold, discoloration, or unusual odors. Rinse them thoroughly under cold running water, using a soft brush if needed to remove dirt. Pat them dry with a clean towel",
                "PREPARE ROOTS FOR COOKING: If roots are whole, cut them into uniform pieces (1/2 to 1 inch) to ensure even cooking. Smaller pieces cook faster and more evenly. Remove any damaged or discolored parts",
                "MEASURE INGREDIENTS PRECISELY: Use 1 tablespoon of dried root per 2 cups of water. For fresh roots, use 2-3 tablespoons per 2 cups. Weigh roots if possible for the most accurate measurements, as root density can vary significantly",
                "SELECT HIGH-QUALITY WATER: Use filtered water or spring water. Root preparations are often consumed for their therapeutic benefits, so water quality is crucial. Avoid hard water if possible, as minerals can affect extraction",
                "HEAT WATER TO BOILING: Bring water to a full rolling boil (100°C/212°F). Roots are dense and require high heat to break down their cell walls and release beneficial compounds. Use a pot large enough to hold all ingredients comfortably",
                "ADD ROOTS TO BOILING WATER: Carefully add the prepared root pieces to the boiling water. Be cautious of steam and splashing. Stir gently to ensure all roots are submerged and not sticking to the bottom of the pot",
                "REDUCE HEAT TO SIMMER: Immediately reduce heat to medium-low to maintain a gentle simmer. You should see small bubbles rising to the surface, but not a rolling boil. This gentle heat prevents scorching while allowing proper extraction",
                "COVER PARTIALLY: Place the lid on the pot but leave a small gap (about 1/4 inch) to allow steam to escape. This prevents the pot from boiling over while maintaining the proper cooking temperature",
                "MONITOR COOKING PROCESS: Check the pot every 5 minutes to ensure the water level remains adequate. Roots can absorb significant amounts of water. If the water level drops too low, add more hot water to maintain the original level",
                "COOK FOR THE FULL TIME: Simmer roots for 15-20 minutes for most varieties. Some tougher roots may need up to 30 minutes. Set a timer and don't rush the process - proper extraction requires time",
                "TEST FOR DONENESS: After the minimum cooking time, test a piece of root. It should be soft and easily pierced with a fork. If still hard, continue cooking for 5-10 more minutes",
                "REMOVE FROM HEAT: Once cooking is complete, turn off the heat and let the pot sit covered for 5 minutes. This allows the liquid to settle and any remaining compounds to be released",
                "STRAIN THOROUGHLY: Pour the liquid through a fine mesh strainer into a clean container. Gently press the root pieces with the back of a spoon to extract any remaining liquid. Be careful not to break up the roots too much",
                "COOL TO DRINKING TEMPERATURE: Let the preparation cool to 60-70°C (140-160°F) before serving. Root preparations are often served warm rather than hot to preserve delicate compounds",
                "SERVE AND STORE: Serve immediately for best flavor and benefits. Store any remaining preparation in the refrigerator for up to 48 hours. Reheat gently before serving, but don't boil again"
            ]
        case "bark":
            return [
                "GATHER YOUR EQUIPMENT: Collect a large pot with a tight-fitting lid, a kitchen scale (essential for bark preparations), a fine mesh strainer, a wooden spoon, measuring cups, a kitchen timer, and clean filtered water. Bark preparations require precise measurements and long cooking times",
                "PREPARE YOUR WORKSPACE: Choose a well-ventilated area as bark preparations can produce strong aromas. Ensure you have at least 30-45 minutes for the complete process. Have paper towels and a clean towel ready for cleanup",
                "INSPECT AND CLEAN BARK: Examine bark pieces for any signs of mold, insect damage, or unusual odors. Rinse bark thoroughly under cold water to remove dust and debris. Pat dry with a clean towel",
                "WEIGH BARK PRECISELY: Use a kitchen scale to measure 5-10 grams of bark per 3 cups of water. Bark density varies greatly, so volume measurements are unreliable. Weighing ensures consistent results and proper dosing",
                "SELECT APPROPRIATE BARK PIECES: Choose bark pieces that are uniform in size (1-2 inches) for even cooking. Avoid very small pieces that can pass through strainers or very large pieces that take too long to cook",
                "PREPARE HIGH-QUALITY WATER: Use filtered water or spring water. Bark preparations are often used for their therapeutic properties, so water quality directly affects effectiveness. Avoid hard water if possible",
                "HEAT WATER TO BOILING: Bring water to a full rolling boil (100°C/212°F). Bark is very dense and requires high heat to break down its structure and release beneficial compounds",
                "ADD BARK TO BOILING WATER: Carefully add the weighed bark pieces to the boiling water. Stir gently to ensure all pieces are submerged and not floating on the surface",
                "REDUCE TO LOW SIMMER: Immediately reduce heat to low to maintain a very gentle simmer. You should see occasional small bubbles, but not a rolling boil. This gentle heat prevents scorching during the long cooking time",
                "COVER COMPLETELY: Place the lid on the pot and keep it covered throughout the cooking process. This maintains consistent temperature and prevents excessive evaporation",
                "MONITOR WATER LEVEL: Check the water level every 10 minutes. Bark preparations can reduce significantly as water evaporates. If the water level drops below the bark pieces, add more hot water to maintain the original level",
                "COOK FOR EXTENDED TIME: Simmer bark for 20-30 minutes. This extended time is necessary because bark is very dense and requires time to break down and release its compounds. Set a timer and don't rush the process",
                "TEST BARK SOFTNESS: After 20 minutes, test a piece of bark. It should be soft and easily broken apart. If still hard, continue cooking for 10 more minutes",
                "REMOVE FROM HEAT: Once cooking is complete, turn off the heat and let the pot sit covered for 10 minutes. This allows the liquid to settle and any remaining compounds to be released",
                "STRAIN CAREFULLY: Pour the liquid through a fine mesh strainer into a clean container. Gently press the bark pieces to extract any remaining liquid, but be careful not to break them up too much",
                "COOL COMPLETELY: Let the preparation cool to room temperature before serving. Bark preparations are typically served at room temperature rather than hot to preserve their therapeutic properties",
                "SERVE AND STORE: Serve at room temperature for best results. Store in the refrigerator for up to 72 hours. Bark preparations have excellent keeping qualities due to their high tannin content"
            ]
        case "tonic":
            return [
                "GATHER YOUR EQUIPMENT: Collect a clean glass jar with a tight-fitting lid (mason jar or similar), measuring spoons, a fine mesh strainer, a wooden spoon, a kitchen timer, and room temperature or cold filtered water. Glass containers are essential for tonic preparations, especially for traditional aphrodisiac blends like Mu Oko Le",
                "PREPARE YOUR WORKSPACE: Choose a clean, cool area away from direct sunlight. Tonic preparations are often made at room temperature and can be sensitive to light and heat. Ensure all surfaces are clean and dry. For traditional aphrodisiac tonics, some practitioners prefer to prepare them during specific times of day",
                "STERILIZE YOUR CONTAINER: Wash your glass jar thoroughly with hot soapy water, then rinse with boiling water to sterilize. Let it air dry completely. Cleanliness is crucial for tonic preparations as they're often consumed over time. Traditional aphrodisiac tonics require extra care to maintain their potency",
                "INSPECT AND PREPARE HERBS: Examine your tonic herbs for freshness and quality. They should have a pleasant aroma and no signs of mold or discoloration. If using fresh herbs, wash them gently and pat dry. For traditional aphrodisiac herbs like those in Mu Oko Le, ensure they are sourced from reputable suppliers",
                "MEASURE HERBS PRECISELY: Use 1-2 tablespoons of dried tonic herb per 2 cups of water. For fresh herbs, use 2-3 tablespoons per 2 cups. Tonic herbs are often delicate, so precise measurement is important for proper balance. Traditional aphrodisiac blends may require specific ratios for optimal effectiveness",
                "SELECT THE RIGHT WATER: Use room temperature or cold filtered water. Never use hot water for tonic preparations as it can destroy delicate compounds. Spring water or filtered water is ideal. Some traditional aphrodisiac preparations use specific water sources or add palm wine for enhanced potency",
                "ADD HERBS TO CONTAINER: Gently place your measured herbs into the clean glass jar. Don't pack them down - let them settle naturally. If using multiple herbs, layer them evenly. For traditional aphrodisiac blends, the order of layering can be important for proper interaction between herbs",
                "POUR WATER OVER HERBS: Slowly pour room temperature or cold water over the herbs, ensuring they are completely submerged. Leave about 1/2 inch of space at the top of the jar for expansion. For traditional aphrodisiac tonics, some practitioners add honey or palm wine at this stage",
                "SEAL THE CONTAINER: Put the lid on the jar and seal it tightly. This prevents contamination and maintains the proper environment for the tonic to develop. Traditional aphrodisiac tonics often require specific storage conditions to maintain their potency",
                "SHAKE GENTLY: Gently shake the jar to mix the herbs and water evenly. Don't shake too vigorously as this can damage delicate herbs. A gentle swirl is sufficient. For traditional aphrodisiac blends, this mixing is crucial for proper herb interaction",
                "SET THE TIMER: Set your timer for 15-20 minutes for traditional aphrodisiac tonics like Mu Oko Le. This extended time allows for proper extraction of testosterone-boosting compounds and aphrodisiac properties. Regular tonics may only need 3-8 minutes",
                "MONITOR THE INFUSION: During the infusion time, you can gently shake the jar once or twice to ensure even distribution. Don't open the jar during this time. Traditional aphrodisiac tonics may develop a characteristic aroma during infusion",
                "PREPARE YOUR STRAINING SETUP: While the tonic is infusing, prepare your strainer and serving glass. Warm the serving glass slightly if you prefer, but don't use hot water. Traditional aphrodisiac tonics are often served in specific vessels",
                "STRAIN THE TONIC: After the timer goes off, carefully pour the tonic through your fine mesh strainer into the serving glass. Hold the strainer close to prevent splashing. Traditional aphrodisiac tonics may have more sediment due to their complex herb blends",
                "ADD SWEETENER IF DESIRED: Many tonics benefit from a small amount of honey or natural sweetener. Add just a small amount and taste - you can always add more if needed. Traditional aphrodisiac tonics often include honey for its natural energy-boosting properties",
                "SERVE AT ROOM TEMPERATURE: Drink your tonic at room temperature or slightly chilled. Don't heat it up - tonics work best when served at comfortable temperatures. Traditional aphrodisiac tonics are typically consumed in the morning or early evening for optimal results",
                "CLEAN UP AND STORE: Rinse your jar and strainer immediately with warm water. Store any remaining tonic in the refrigerator for up to 12 hours. Tonic preparations are best consumed fresh. Traditional aphrodisiac tonics should be used within the recommended timeframe to maintain their potency"
            ]
        case "mixed tonic":
            return [
                "GATHER YOUR EQUIPMENT: Collect a large clean glass jar with a tight-fitting lid, measuring spoons, a kitchen scale (recommended for precise blending), a fine mesh strainer, a wooden spoon, a kitchen timer, and room temperature filtered water. Mixed tonics require careful attention to ingredient ratios",
                "PREPARE YOUR WORKSPACE: Choose a clean, well-lit area where you can work methodically. Mixed tonics involve multiple ingredients, so organization is key. Have paper and pen ready to note your measurements",
                "STERILIZE YOUR CONTAINER: Wash your glass jar thoroughly with hot soapy water, then sterilize with boiling water. Let it air dry completely. Mixed tonics often contain multiple herbs, so cleanliness is essential",
                "INSPECT ALL INGREDIENTS: Examine each herb in your blend for quality and freshness. Check for any signs of mold, unusual odors, or discoloration. Ensure all herbs are compatible and safe to combine",
                "MEASURE EACH INGREDIENT: Use 1-2 teaspoons of mixed tonic blend per cup of water. If blending your own, measure each herb individually according to your recipe. Use a scale for the most accurate measurements",
                "BLEND INGREDIENTS CAREFULLY: If creating your own blend, mix the herbs gently in a clean bowl before adding to water. Ensure even distribution of all ingredients. Don't crush or grind herbs unless specifically required",
                "SELECT HIGH-QUALITY WATER: Use room temperature or cold filtered water. Mixed tonics are often delicate and can be affected by water quality. Avoid hard water or water with strong mineral content",
                "ADD BLEND TO CONTAINER: Gently place your mixed herb blend into the clean glass jar. Layer the herbs evenly if they're not pre-mixed. Don't pack them down - let them settle naturally",
                "POUR WATER OVER BLEND: Slowly pour room temperature or cold water over the herb blend, ensuring all ingredients are completely submerged. Leave about 1/2 inch of space at the top",
                "SEAL THE CONTAINER: Put the lid on the jar and seal it tightly. This creates the proper environment for the herbs to work together and prevents contamination",
                "SHAKE TO MIX: Gently shake the jar to mix all ingredients evenly. This is important for mixed tonics as you want all herbs to interact properly. Shake for about 30 seconds",
                "SET EXTENDED TIMER: Set your timer for 8-12 minutes. Mixed tonics need more time than single herbs because all ingredients need time to blend and work together",
                "MONITOR THE INFUSION: During the infusion, gently shake the jar 2-3 times to ensure even distribution and proper blending of all ingredients. Don't open the jar during this time",
                "PREPARE STRAINING EQUIPMENT: While the tonic is infusing, prepare your strainer and serving vessel. Mixed tonics may have more particles, so ensure your strainer is fine enough",
                "STRAIN THOROUGHLY: Carefully pour the mixed tonic through your fine mesh strainer. Mixed tonics can have more sediment, so strain slowly and carefully to catch all particles",
                "ADD SWEETENER GRADUALLY: Mixed tonics often benefit from sweeteners. Add honey or natural sweetener gradually, tasting as you go to achieve the perfect balance",
                "SERVE AND STORE: Serve at room temperature for best results. Store in the refrigerator for up to 24 hours. Mixed tonics may separate during storage, so shake gently before serving"
            ]
        case "refresher":
            return [
                "GATHER YOUR EQUIPMENT: Collect a large clean glass jar with a tight-fitting lid, measuring spoons, a fine mesh strainer, fresh herbs (not dried), a kitchen timer, and cold filtered water. Refreshers use fresh herbs and cold water for a unique preparation method",
                "PREPARE YOUR WORKSPACE: Choose a clean, cool area away from direct sunlight. Refreshers are made with cold water and fresh herbs, so a cool environment is ideal. Ensure all surfaces are clean",
                "STERILIZE YOUR CONTAINER: Wash your glass jar thoroughly with hot soapy water, then rinse with cold water. Let it air dry completely. Fresh herbs can spoil easily, so cleanliness is crucial",
                "SELECT FRESH HERBS: Choose fresh, vibrant herbs with no signs of wilting, discoloration, or mold. Fresh herbs should have a bright color and pleasant aroma. Avoid herbs that look tired or have brown spots",
                "WASH FRESH HERBS THOROUGHLY: Rinse fresh herbs under cold running water to remove dirt, insects, and any chemical residues. Be gentle but thorough. Pat them dry with a clean towel",
                "MEASURE FRESH HERBS: Use 1-2 tablespoons of fresh herbs per cup of water. Fresh herbs need more volume than dried herbs because they still contain water. Adjust based on herb size and density",
                "PREPARE COLD WATER: Use cold, filtered water or spring water. Never use hot water for refreshers as it would cook the fresh herbs and destroy their refreshing properties",
                "ADD FRESH HERBS TO CONTAINER: Gently place your clean, fresh herbs into the glass jar. Don't pack them down - let them settle naturally. Fresh herbs are delicate and should be handled carefully",
                "POUR COLD WATER OVER HERBS: Slowly pour cold water over the fresh herbs, ensuring they are completely submerged. Leave about 1 inch of space at the top for expansion",
                "SEAL THE CONTAINER: Put the lid on the jar and seal it tightly. This prevents contamination and maintains the cold environment needed for the refresher to develop properly",
                "SHAKE GENTLY: Gently shake the jar to mix the herbs and water. Fresh herbs are delicate, so use a gentle motion. Don't shake too vigorously as this can damage the herbs",
                "SET ROOM TEMPERATURE TIMER: Set your timer for 2-4 hours at room temperature. This initial infusion allows the herbs to release their flavors and beneficial compounds",
                "MONITOR THE INFUSION: During the room temperature infusion, you can gently shake the jar once or twice. Check that the herbs remain submerged and haven't floated to the top",
                "TRANSFER TO REFRIGERATOR: After the room temperature infusion, place the jar in the refrigerator for an additional 2-4 hours. This cold infusion enhances the refreshing qualities",
                "PREPARE FOR SERVING: While the refresher is chilling, prepare your serving glasses and garnishes. Refreshers are often served with ice, lemon slices, or fresh herb sprigs",
                "STRAIN AND SERVE: Carefully pour the refresher through your fine mesh strainer into serving glasses. Add ice cubes, lemon slices, or fresh herb garnishes as desired",
                "SERVE IMMEDIATELY: Serve the refresher cold for the best experience. Store any remaining refresher in the refrigerator for up to 24 hours, but it's best consumed fresh"
            ]
        case "spice":
            return [
                "GATHER YOUR EQUIPMENT: Collect a heavy-bottomed pot, a fine mesh strainer, measuring spoons, a wooden spoon, a kitchen timer, and filtered water. Spices can be strong, so precise measurements and proper equipment are essential",
                "PREPARE YOUR WORKSPACE: Choose a well-ventilated area as spice preparations can produce strong aromas. Ensure you have enough space to work comfortably and that your stove is easily accessible",
                "INSPECT AND PREPARE SPICES: Examine your spices for freshness and quality. They should have a strong, pleasant aroma and no signs of mold or unusual odors. If using whole spices, consider toasting them first",
                "TOAST WHOLE SPICES (OPTIONAL): If using whole spices, toast them in a dry pan over low heat for 1-2 minutes until they become fragrant. This enhances their flavor and aroma. Be careful not to burn them",
                "MEASURE SPICES PRECISELY: Use 1/2-1 teaspoon of ground spice per cup of water, or 1-2 whole spices per cup. Spices are potent, so start with less and adjust to taste. Use a scale for the most accurate measurements",
                "SELECT HIGH-QUALITY WATER: Use filtered water or spring water. Spice preparations rely heavily on flavor, so water quality directly affects the final taste. Avoid hard water if possible",
                "HEAT WATER TO BOILING: Bring water to a full rolling boil (100°C/212°F). Spices require high heat to release their essential oils and flavors properly",
                "ADD SPICES TO BOILING WATER: Carefully add your prepared spices to the boiling water. Stir gently to ensure they are evenly distributed and not clumping together",
                "REDUCE HEAT TO SIMMER: Immediately reduce heat to medium-low to maintain a gentle simmer. You should see small bubbles rising to the surface, but not a rolling boil",
                "COVER PARTIALLY: Place the lid on the pot but leave a small gap (about 1/4 inch) to allow steam to escape. This prevents the pot from boiling over while maintaining proper temperature",
                "STIR OCCASIONALLY: Gently stir the spice mixture every 2-3 minutes to prevent spices from settling and burning on the bottom of the pot. Use a wooden spoon to avoid scratching the pot",
                "COOK FOR APPROPRIATE TIME: Simmer spices for 10-15 minutes. This time allows the spices to release their flavors and beneficial compounds without becoming bitter",
                "MONITOR THE PROCESS: Watch for any signs of burning or scorching. If you notice a burnt smell, reduce the heat immediately and stir more frequently",
                "TEST FOR FLAVOR: After 10 minutes, taste a small amount to check the flavor. If it's too mild, continue cooking for 5 more minutes. If it's too strong, you can dilute with more water",
                "REMOVE FROM HEAT: Once the desired flavor is achieved, turn off the heat and let the pot sit covered for 5 minutes. This allows the flavors to meld and settle",
                "STRAIN CAREFULLY: Pour the liquid through a fine mesh strainer into a clean container. If using whole spices, gently press them to extract any remaining liquid",
                "COOL TO DRINKING TEMPERATURE: Let the preparation cool to 60-70°C (140-160°F) before serving. Spice preparations can be harsh if served too hot",
                "SERVE AND STORE: Serve warm for best flavor. Store in the refrigerator for up to 24 hours. Spice preparations keep well due to their natural preservative properties"
            ]
        default:
            return [
                "GATHER YOUR EQUIPMENT: Collect appropriate containers (glass or ceramic), measuring tools, strainers, and clean filtered water. Different herbs require different equipment, so check specific requirements for your herb type",
                "PREPARE YOUR WORKSPACE: Choose a clean, well-lit area appropriate for your herb type. Some herbs need heat, others need cold, so ensure your workspace matches the requirements",
                "INSPECT YOUR HERBS: Examine your herbs for quality, freshness, and any signs of damage or contamination. Quality herbs are essential for effective preparations",
                "MEASURE INGREDIENTS: Use the recommended measurements for your specific herb type. Some herbs need more, some need less - follow the guidelines carefully",
                "SELECT APPROPRIATE WATER: Choose water quality and temperature based on your herb type. Some herbs need hot water, others need cold or room temperature water",
                "PREPARE ACCORDING TO TYPE: Follow the specific preparation method for your herb category. Each type has unique requirements for optimal results",
                "MONITOR THE PROCESS: Pay attention to timing, temperature, and any specific requirements for your herb type. Don't rush the process",
                "STRAIN AND SERVE: Use appropriate straining methods for your herb type. Some herbs need fine straining, others can be served with particles",
                "SERVE AT OPTIMAL TEMPERATURE: Serve your preparation at the recommended temperature for your herb type. Temperature affects both taste and effectiveness",
                "STORE PROPERLY: Follow storage recommendations for your specific herb type. Most preparations need refrigeration and have limited shelf life"
            ]
        }
    }
    
    private func preparationTips(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
            return [
                "Use fresh herbs when you can! Fresh herbs are like fresh flowers - they smell better and work better. If you can't get fresh herbs, dried herbs are okay too, but keep them in airtight containers (like a sealed jar) so they stay fresh",
                "Don't make the water too hot! Think of herbs like delicate flowers - if you pour boiling water on them, they get hurt. Use gentle heat, like a warm bath, not a hot shower",
                "Always cover your teapot! This is like keeping a secret - you don't want the good parts (called volatile oils) to escape into the air. It's like keeping the lid on a cookie jar so the cookies stay fresh",
                "Use glass or ceramic containers! Metal containers can change the taste of your herbs, like how metal spoons can taste funny. Glass and ceramic are like good friends - they don't change anything",
                "Warm up your teapot first! This is like warming up your hands before putting on gloves. A warm teapot keeps your tea at the right temperature longer",
                "You can make your tea stronger or milder! If you want stronger tea, let it sit longer (like 10 minutes). If you want milder tea, let it sit for less time (like 5 minutes). It's like cooking pasta - longer cooking makes it softer",
                "Use clean water! Tap water can have chemicals that change how your herbs work. Filtered water or spring water is like giving your herbs a clean bath",
                "Store your tea in the refrigerator! Just like milk goes bad if you leave it out, tea goes bad too. Put it in the fridge and drink it within 24 hours (that's one whole day)"
            ]
        case "root":
            return [
                "Clean your roots really well! Roots grow in the ground, so they can have dirt on them. Wash them like you wash your hands - really thoroughly! Dirt can make you sick, so clean roots are important",
                "Cut roots into small pieces! Big pieces take longer to work, like how big ice cubes take longer to melt than small ones. Small, uniform pieces work better and faster",
                "Use a thick pot! Heavy-bottomed pots are like thick books - they don't get too hot too quickly. This prevents burning, which is like how you don't want to burn your toast",
                "Simmer gently! Don't let the water boil too hard. It's like the difference between a gentle rain and a storm - gentle is better for roots",
                "Watch the water level! Roots can drink up water like plants do. Check every few minutes and add more hot water if needed. It's like making sure your plants have enough water",
                "Press gently when straining! Roots can hold onto liquid like a sponge. Gently pressing helps get all the good stuff out, but don't press too hard - just gently!",
                "Let it cool before drinking! Very hot liquids can burn your mouth, like how hot soup can burn your tongue. Let it cool to a comfortable temperature first",
                "Roots last longer! You can store root tea in the refrigerator for up to 48 hours (that's two whole days). This is longer than other herbs because roots are tougher"
            ]
        case "bark":
            return [
                "Rinse your bark really well! Bark can have dust and dirt on it from being stored. Wash it like you wash vegetables before eating them",
                "Weigh your bark, don't measure by volume! Bark density varies greatly - some bark is light and fluffy, some is heavy and dense. Using a kitchen scale is like measuring flour for baking - it's much more accurate than using spoons",
                "Use bigger pieces when you can! Bigger pieces of bark work more slowly and evenly, like how big ice cubes melt more slowly than small ones",
                "Don't rush the process! Bark is like a thick book - it takes time to open up and share its secrets. Give it the full time it needs",
                "Watch the water carefully! Bark preparations can get smaller as water evaporates, like how a puddle gets smaller on a hot day. Add more hot water if needed",
                "Be patient! Bark extracts are like slow-cooked food - they need time to develop their full flavor and benefits. Don't try to hurry them",
                "Strain really well! Bark can leave little pieces that aren't nice to drink. Strain thoroughly to get a smooth drink, like filtering sand out of water",
                "Cool completely before serving! Bark preparations are often served at room temperature, not hot. This is different from regular tea - it's like the difference between hot soup and room temperature juice",
                "Bark lasts a long time! You can store bark tea for up to 72 hours (that's three whole days). This is longer than other herbs because bark is very stable"
            ]
        case "tonic":
            return [
                "Use room temperature or cold water! Tonics are like delicate flowers - hot water can hurt them. Think of it like the difference between a gentle breeze and a strong wind",
                "Clean your containers really well! Tonics are often drunk over time, so cleanliness is very important. Wash your jar like you wash dishes - really thoroughly!",
                "Shake gently! This helps mix everything together evenly, like how you stir paint to mix the colors. Don't shake too hard - just a gentle shake",
                "Add honey if you want! Many tonics taste better with a little sweetness, like how lemonade tastes better with sugar. Honey is like a natural sweetener",
                "Serve at room temperature! Extreme temperatures can change how tonics work. Room temperature is like the perfect temperature - not too hot, not too cold",
                "Drink them fresh! Tonics are most effective when they're fresh, like how fresh fruit tastes better than old fruit. Drink within 12 hours for best results",
                "Use good quality herbs! The quality of your herbs directly affects how well they work. It's like the difference between fresh vegetables and old vegetables",
                "Consider adding citrus! Vitamin C from citrus fruits can help your body absorb the tonic better. It's like how vitamin C helps you absorb iron from spinach"
            ]
        case "mixed tonic":
            return [
                "Make sure all herbs work together! Some herbs can fight with each other, like how some people don't get along. Check that all herbs in your blend are compatible",
                "Measure carefully! Mixed tonics need precise amounts, like how a recipe needs exact measurements. Too much or too little can change how it works",
                "Give it enough time! All herbs need time to work together, like how a team needs time to coordinate. Don't rush the process",
                "Shake gently during preparation! This ensures all ingredients mix well, like how you stir different colors of paint together",
                "Add sweeteners slowly! Taste as you go to get the perfect balance, like how you add salt to food gradually. You can always add more, but you can't take it away",
                "Serve at room temperature! Mixed tonics work best at body temperature, like how your body is comfortable at room temperature",
                "Store properly and shake before serving! Ingredients can settle during storage, like how sand settles in water. Give it a gentle shake before drinking",
                "Watch for any reactions! Mixed tonics have multiple ingredients, so pay attention to how your body feels. If something doesn't feel right, stop using it"
            ]
        case "refresher":
            return [
                "Use clean water! Impurities in water can change the refreshing quality, like how dirty water doesn't taste as good as clean water",
                "Wash fresh herbs really well! Fresh herbs can have dirt, insects, or chemicals on them. Wash them like you wash fresh vegetables",
                "Don't let them sit too long! Cold infusions can develop off-flavors or spoil, like how milk goes bad if you leave it out too long",
                "Add citrus, mint, or honey! These can make your refresher taste even better and add extra benefits. It's like adding toppings to ice cream",
                "Store in the refrigerator right away! Cold infusions must stay cold, like how ice cream must stay in the freezer",
                "Drink within 24 hours! Refreshers are best when they're fresh, like how fresh juice tastes better than old juice",
                "Use glass containers! Plastic can change the taste, like how plastic containers can make food taste funny",
                "Shake before serving! This redistributes any ingredients that might have settled, like how you stir a drink before taking another sip"
            ]
        case "spice":
            return [
                "Toast whole spices first! If you're using whole spices, warm them in a dry pan for 1-2 minutes until they smell nice. This is like warming up before exercise - it helps them work better",
                "Use whole spices when possible! Whole spices keep their flavor longer than ground spices, like how whole apples stay fresh longer than cut apples",
                "Don't over-boil! Too much heat can make spices bitter and harsh, like how overcooked food tastes bad",
                "Add a pinch of salt! Salt brings out the natural flavors of spices, like how salt makes food taste better",
                "Stir occasionally! This prevents spices from settling and burning, like how you stir soup to keep it from sticking to the bottom",
                "Use a thick pot! Heavy-bottomed pots prevent scorching, like how a thick book doesn't get damaged as easily as a thin one",
                "Let it cool before drinking! Very hot spice preparations can be harsh, like how very hot soup can burn your mouth",
                "Store in the refrigerator! Spice preparations keep well for up to 24 hours, like how cooked food keeps in the fridge"
            ]
        default:
            return [
                "Always use clean water! Water quality affects how your herbs work, like how clean water makes better coffee than dirty water",
                "Follow the recommended amounts! Too much or too little can change how effective your preparation is, like how too much or too little salt changes how food tastes",
                "Store properly! Most preparations should go in the refrigerator and be consumed quickly, like how fresh food needs to be stored properly",
                "Ask a doctor if you're unsure! Especially if you have health conditions or take medications, like how you ask a teacher if you're not sure about homework",
                "Use the right containers! Glass or ceramic are best for most preparations, like how glass bottles keep drinks tasting better than plastic",
                "Watch the timing! Different herbs need different amounts of time, like how different foods need different cooking times",
                "Start with small amounts! Test how your body reacts before using more, like how you taste a small bite before eating a whole meal",
                "Keep everything clean! Hygiene is very important for herbal remedies, like how you wash your hands before cooking"
            ]
        }
    }
    
    private func safetyNotes(for category: String) -> [String] {
        switch category.lowercased() {
        case "herb":
        return [
                "Start with small amounts! Just like you taste a small bite of new food before eating a whole meal, try a small amount of herb tea first to see how your body reacts. Some people can be allergic to certain herbs, like how some people are allergic to peanuts",
                "Don't use too much! More is not always better with herbs. It's like how you don't want to eat too much candy - a little is good, but too much can make you feel sick",
                "Stop if you feel bad! If you feel nauseous, dizzy, or get a skin rash, stop using the herb immediately. It's like how you stop eating if something tastes bad or makes you feel sick",
                "Ask a doctor first! If you're pregnant, nursing, or taking medications, ask your doctor before using herbs. Herbs can interact with medicines, like how some foods can interact with medicines",
                "Keep away from children! Herbal preparations are not toys and should be kept out of reach of children, just like you keep cleaning supplies away from children",
                "Store herbs properly! Keep dried herbs in a cool, dry place away from sunlight, like how you store books to keep them from getting damaged",
                "Check the dates! Old herbs lose their power and can go bad, like how old food loses its taste and can make you sick. Check the expiration date on dried herbs",
                "Never use spoiled herbs! If herbs have mold, strange smells, or look discolored, don't use them. It's like how you wouldn't eat food that looks or smells bad"
            ]
        case "root":
            return [
                "Clean roots really well! Roots grow in the ground and can have dirt and germs on them. Wash them thoroughly, like how you wash your hands really well after playing outside",
                "Start with small amounts! Roots are often stronger than leaves or flowers, like how a big tree is stronger than a small flower. Start with less to see how your body reacts",
                "Don't use too much! Roots can have strong effects, so follow the recommended amounts carefully. It's like how you don't want to eat too much spicy food",
                "Stop if you feel sick! If you get an upset stomach, nausea, or any other bad feeling, stop using the root preparation immediately. It's like how you stop eating if something makes you feel bad",
                "Ask a doctor if you have health problems! If you have liver or kidney problems, ask your doctor before using roots. Some roots can affect these organs",
                "Keep away from children! Root preparations can be very strong and are not suitable for children, like how you don't give children strong medicine",
                "Store in the refrigerator! After preparing root tea, put it in the refrigerator because roots can spoil more quickly than other herbs",
                "Never use bad roots! If roots show signs of rot, mold, or strange smells, don't use them. It's like how you wouldn't eat vegetables that are rotting"
            ]
        case "bark":
            return [
                "Rinse bark really well! Bark can have dirt, dust, and other things on it from being stored. Wash it thoroughly, like how you wash vegetables before eating them",
                "Weigh your bark accurately! Bark density varies a lot, so always use a kitchen scale. It's like how you weigh ingredients for baking instead of guessing with cups and spoons",
                "Start with small amounts! Bark preparations can be very strong, like how a thick tree trunk is stronger than a thin branch. Start with less to test how your body reacts",
                "Don't use too much! Bark extracts are often concentrated and powerful, so follow the recommended weight amounts carefully. It's like how you don't want to use too much strong soap",
                "Stop if you feel bad! If you get digestive problems, nausea, or allergic reactions, stop using the bark preparation immediately. It's like how you stop using something if it makes you feel sick",
                "Ask a doctor if you have stomach problems! If you have gastrointestinal conditions, ask your doctor before using bark preparations. Some bark can irritate the stomach",
                "Keep away from children! Bark preparations can be harsh and are not suitable for children, like how you don't give children strong cleaning products",
                "Store properly! Put bark preparations in the refrigerator because they can develop off-flavors if not stored properly",
                "Never use bad bark! If bark shows signs of mold, strange smells, or insect damage, don't use it. It's like how you wouldn't use wood that's rotting or has bugs in it"
            ]
        case "tonic":
            return [
                "Start with small amounts! Tonics can have effects that build up over time, like how saving money builds up over time. Start with less to see how your body reacts. Traditional aphrodisiac tonics like Mu Oko Le work gradually to support male health",
                "Don't use too much! Tonics are meant for gentle, long-term use, not for strong, quick effects. It's like how you drink water regularly, not all at once. Traditional aphrodisiac tonics require consistent use for optimal testosterone support",
                "Stop if you feel strange! If you experience any bad reactions or unusual symptoms, stop using the tonic immediately. It's like how you stop doing something if it makes you feel weird. Traditional aphrodisiac tonics should not cause adverse effects when used properly",
                "Ask a doctor if you have health problems! If you have chronic health conditions, ask your doctor before using tonics. Some tonics can affect ongoing health problems. Traditional aphrodisiac tonics may interact with heart conditions or blood pressure medications",
                "Keep away from children! Tonics are not suitable for young children, like how you don't give children adult medicine. Traditional aphrodisiac tonics are specifically formulated for adult male health and should never be given to children",
                "Store in the refrigerator! Put tonics in the refrigerator and use them within the recommended time frame, like how you store fresh juice. Traditional aphrodisiac tonics lose potency quickly and should be consumed fresh",
                "Watch for changes! Pay attention to any changes in your health while using tonics, like how you notice if something makes you feel different. Traditional aphrodisiac tonics may show gradual improvements in energy and vitality",
                "Never use spoiled tonics! If tonics show signs of spoilage or strange smells, don't use them. It's like how you wouldn't drink juice that smells bad. Traditional aphrodisiac tonics can spoil quickly due to their complex herb blends",
                "Use at optimal times! Traditional aphrodisiac tonics like Mu Oko Le are most effective when taken in the morning or early evening, like how you time meals for optimal digestion and energy",
                "Monitor hormone levels! If using traditional aphrodisiac tonics for testosterone support, consider monitoring your hormone levels with a healthcare provider to ensure safe and effective use"
            ]
        case "mixed tonic":
            return [
                "Start with small amounts! Mixed tonics have several herbs working together, like how a team has several players. Start with less to see how your body reacts to the combination",
                "Don't use too much! Multiple herbs can have effects that work together (synergistic effects), so follow the recommended amounts carefully. It's like how you don't want to mix too many different foods at once",
                "Stop if you have bad reactions! If you experience any bad reactions or allergic symptoms, stop using the mixed tonic immediately. It's like how you stop eating if something in a mixed dish makes you sick",
                "Ask a doctor if you have health problems! If you have multiple health conditions or take medications, ask your doctor before using mixed tonics. Multiple herbs can interact with multiple medicines",
                "Keep away from children! Mixed tonics can be complex and strong, and are not suitable for children, like how you don't give children complex adult medicine",
                "Store properly and shake before use! Ingredients can separate during storage, like how oil and water separate. Give it a gentle shake before using",
                "Watch for interactions! Pay attention to how the different herbs in the blend work together and how your body reacts to the combination",
                "Never use spoiled mixed tonics! If mixed tonics show signs of spoilage, strange smells, or separation, don't use them. It's like how you wouldn't eat a mixed dish that looks or smells bad"
            ]
        case "refresher":
            return [
                "Use only fresh, clean herbs! Spoiled herbs can cause food poisoning, like how spoiled food can make you sick. Only use herbs that look and smell fresh",
                "Wash herbs really well! Fresh herbs can have dirt, insects, and chemicals on them. Wash them thoroughly, like how you wash fresh vegetables really well",
                "Store in the refrigerator right away! Cold infusions must stay cold, like how ice cream must stay in the freezer. Put them in the refrigerator immediately after making them",
                "Drink within 24 hours! Cold infusions can spoil quickly, like how fresh juice can go bad quickly. Drink them within one day for best safety",
                "Stop if you feel sick! If you experience any digestive upset or unusual symptoms, stop using the refresher immediately. It's like how you stop eating if something makes your stomach hurt",
                "Ask a doctor if you have immune problems! If you have immune system issues, ask your doctor before using cold infusions. Some people with weak immune systems need to be extra careful",
                "Keep away from children! Cold infusions can look appealing (like juice) but may not be safe for children, like how you don't give children adult drinks",
                "Never use spoiled refreshers! If refreshers show signs of spoilage, strange smells, or cloudiness, don't use them. It's like how you wouldn't drink juice that looks cloudy or smells bad"
            ]
        case "spice":
            return [
                "Start with small amounts! Spices can be irritating to sensitive people, like how some people can't handle spicy food. Start with less to see how your body reacts",
                "Don't use too much! Spices can cause digestive upset, like how too much spicy food can give you a stomachache. Follow the recommended amounts carefully",
                "Stop if you feel bad! If you experience heartburn, nausea, or other digestive problems, stop using the spice preparation immediately. It's like how you stop eating spicy food if it hurts your stomach",
                "Ask a doctor if you have stomach problems! If you have gastrointestinal conditions, ask your doctor before using spice preparations. Some spices can irritate sensitive stomachs",
                "Keep away from children! Spice preparations can be too strong for children, like how you don't give children very spicy food",
                "Store properly! Put spice preparations in the refrigerator because they can develop off-flavors if not stored properly, like how you store cooked food",
                "Never use spoiled spices! If spices show signs of mold, strange smells, or insect damage, don't use them. It's like how you wouldn't use spices that look or smell bad",
                "Be careful with hot spices! If you have a sensitive stomach or acid reflux, be extra careful with hot spices, like how you might avoid very spicy food if you have a sensitive stomach"
            ]
        default:
            return [
                "Start with small amounts! Everyone reacts differently to herbs, like how some people like spicy food and others don't. Start with less to see how your body reacts",
                "Don't use too much! Herbal remedies are powerful and should be treated with respect, like how you respect fire because it's powerful. Follow the recommended amounts carefully",
                "Stop if you feel bad! If you experience bad reactions like nausea, dizziness, or skin irritation, stop using the herb immediately. It's like how you stop doing something if it makes you feel sick",
                "Ask a doctor if you're unsure! If you're pregnant, nursing, or taking medications, ask your doctor before using herbs. Herbs can interact with medicines, like how some foods can interact with medicines",
                "Keep away from children! Herbal preparations are not suitable for unsupervised use by children, like how you don't let children use adult tools without supervision",
                "Store properly! Follow the storage recommendations carefully because improper storage can lead to spoilage, like how you store food properly to keep it from going bad",
                "Check for spoilage! Before using herbs, check for signs of spoilage like mold, strange smells, or discoloration. It's like how you check food before eating it",
                "Never use contaminated herbs! If herbs show signs of contamination or spoilage, don't use them. It's like how you wouldn't eat food that's contaminated or spoiled"
            ]
        }
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
    
    // MARK: - Preparation Ratio Helper Functions
    private func getHerbToWaterRatio() -> String {
        switch herb.category.lowercased() {
        case "herb":
            return "1 teaspoon : 1 cup water"
        case "root":
            return "1 tablespoon : 2 cups water"
        case "bark":
            return "1 tablespoon : 3 cups water"
        case "tonic":
            return "1-2 tablespoons : 2 cups water (traditional aphrodisiac tonics)"
        case "mixed tonic":
            return "1-2 teaspoons : 1 cup water"
        default:
            return "1 teaspoon : 1 cup water"
        }
    }
    
    private func getSteepingTime() -> String {
        switch herb.category.lowercased() {
        case "herb":
            return "5-10 minutes"
        case "root":
            return "15-20 minutes"
        case "bark":
            return "20-30 minutes"
        case "tonic":
            return "15-20 minutes (traditional aphrodisiac tonics like Mu Oko Le)"
        case "mixed tonic":
            return "8-12 minutes"
        default:
            return "5-10 minutes"
        }
    }
    
    private func getWaterTemperature() -> String {
        switch herb.category.lowercased() {
        case "herb":
            return "80-95°C (175-205°F)"
        case "root":
            return "95-100°C (205-212°F)"
        case "bark":
            return "100°C (212°F) - boiling"
        case "tonic":
            return "80-90°C (175-195°F) (traditional aphrodisiac tonics)"
        case "mixed tonic":
            return "85-95°C (185-205°F)"
        default:
            return "80-95°C (175-205°F)"
        }
    }
    
    private func getStorageDuration() -> String {
        switch herb.category.lowercased() {
        case "herb":
            return "24-48 hours"
        case "root":
            return "48-72 hours"
        case "bark":
            return "72-96 hours"
        case "tonic":
            return "6-12 hours (traditional aphrodisiac tonics lose potency quickly)"
        case "mixed tonic":
            return "24-48 hours"
        default:
            return "24-48 hours"
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
                
                // Recommended Preparation Ratios
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Recommended Ratios", icon: "scalemass.fill")
                    
                    VStack(spacing: 12) {
                        PreparationRatioCard(
                            title: "Herb-to-Water Ratio",
                            ratio: getHerbToWaterRatio(),
                            description: "Optimal ratio for \(herb.category.lowercased())",
                            icon: "leaf.fill",
                            color: .green,
                            showInfo: true
                        )
                        
                        PreparationRatioCard(
                            title: "Steeping Time",
                            ratio: getSteepingTime(),
                            description: "Optimal extraction time",
                            icon: "clock.fill",
                            color: .blue,
                            showInfo: false
                        )
                        
                        PreparationRatioCard(
                            title: "Water Temperature",
                            ratio: getWaterTemperature(),
                            description: "Ideal temperature for extraction",
                            icon: "thermometer",
                            color: .orange,
                            showInfo: false
                        )
                        
                        PreparationRatioCard(
                            title: "Storage Duration",
                            ratio: getStorageDuration(),
                            description: "Refrigerated after preparation",
                            icon: "refrigerator.fill",
                            color: .purple,
                            showInfo: false
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

// MARK: - Preparation Ratio Card
struct PreparationRatioCard: View {
    let title: String
    let ratio: String
    let description: String
    let icon: String
    let color: Color
    let showInfo: Bool
    
    @State private var showingInfo = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    
                    if showInfo {
                        Button(action: {
                            showingInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
                
                Text(ratio)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .sheet(isPresented: $showingInfo) {
            WaterRatioInfoView()
        }
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