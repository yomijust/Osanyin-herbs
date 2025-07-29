import SwiftUI
import SafariServices
import WebKit

struct HerbDetailView: View {
    let herb: Herb
    @StateObject private var coreDataManager = CoreDataManager.shared
    @StateObject private var healthProfile = HealthProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPreparationGuide = false
    @State private var showingHealthWarnings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    CompactHeaderSection(herb: herb, coreDataManager: coreDataManager)
                    
                    // Health Profile Safety Section
                    if healthProfile.hasProfile {
                        HealthProfileSafetySection(herb: herb, healthProfile: healthProfile)
                    }
                    
                    // Quick Info Row
                    QuickInfoRow(herb: herb)
                    
                    // Main Content
                    VStack(spacing: 16) {
                        // Description Card
                        CompactInfoCard(
                            title: "Description",
                            icon: "text.quote",
                            content: herb.description,
                            color: .blue
                        )
                        
                        // Uses & Benefits
                        if !herb.uses.isEmpty {
                            CompactTagsCard(
                                title: "Uses & Benefits",
                                icon: "checkmark.circle.fill",
                                tags: herb.uses,
                                color: .green
                            )
                        }
                        
                        // Preparation & Dosage Row
                        HStack(spacing: 16) {
                            CompactInfoCard(
                                title: "Preparation",
                                icon: "cup.and.saucer.fill",
                                content: herb.preparation,
                                color: .purple
                            ) {
                                showingPreparationGuide = true
                            }
                            
                            CompactInfoCard(
                                title: "Standard Dosage",
                                icon: "clock.fill",
                                content: herb.dosage,
                                color: .orange
                            )
                        }
                        
                        // Nutrition & Vitamins
                        CompactNutritionCard(nutrition: herb.nutrition, vitamins: herb.vitamins)
                        
                        // Local Names & Locations
                        if !herb.localNames.isEmpty || !herb.locations.isEmpty {
                            HStack(spacing: 16) {
                                if !herb.localNames.isEmpty {
                                    CompactLocalNamesCard(localNames: herb.localNames)
                                }
                                
                                if !herb.locations.isEmpty {
                                    CompactTagsCard(
                                        title: "Locations",
                                        icon: "location.fill",
                                        tags: herb.locations,
                                        color: .indigo
                                    )
                                }
                            }
                        }
                        
                        // Ailments & Precautions
                        if !herb.ailments.isEmpty || !herb.precautions.isEmpty {
                            VStack(spacing: 16) {
                                if !herb.ailments.isEmpty {
                                    CompactTagsCard(
                                        title: "Ailments",
                                        icon: "cross.circle.fill",
                                        tags: herb.ailments,
                                        color: .red
                                    )
                                }
                                
                                if !herb.precautions.isEmpty {
                                    CompactWarningCard(content: herb.precautions)
                                }
                            }
                        }
                        
                        // Drug Interaction Checker
                        DrugInteractionCheckerCard(herb: herb)
                        
                        // Honey Usage
                        if !herb.honeyUsage.isEmpty {
                            CompactInfoCard(
                                title: "Honey Usage",
                                icon: "drop.fill",
                                content: herb.honeyUsage,
                                color: .yellow
                            )
                        }
                        
                        // Continents (Expanded)
                        CompactContinentsCard(continents: herb.continents)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                }
            }
            .sheet(isPresented: $showingPreparationGuide) {
                HerbPreparationView(herb: herb)
            }
        }
    }
}

// MARK: - Compact Header Section
struct CompactHeaderSection: View {
    let herb: Herb
    let coreDataManager: CoreDataManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Category Icon and Title
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(herb.englishName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(herb.scientificName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                    
                    // Wikipedia Link
                    if let url = URL(string: herb.wikipediaUrl) {
                        Button(action: {
                            let safariVC = SFSafariViewController(url: url)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(safariVC, animated: true)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Learn More")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                // Category Badge
                Text(herb.category)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(categoryColor.opacity(0.15))
                    )
                    .foregroundColor(categoryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
    }
    
    private var categoryColor: Color {
        switch herb.category.lowercased() {
        case "refresher":
            return .blue
        case "herb":
            return .green
        case "spice":
            return .orange
        default:
            return .gray
        }
    }
    
    private var categoryIcon: String {
        switch herb.category.lowercased() {
        case "refresher":
            return "drop.fill"
        case "herb":
            return "leaf.fill"
        case "spice":
            return "flame.fill"
        default:
            return "circle.fill"
        }
    }
}

// MARK: - Quick Info Row
struct QuickInfoRow: View {
    let herb: Herb
    
    var body: some View {
        HStack(spacing: 20) {
            QuickInfoItem(
                icon: "flame.fill",
                title: "Calories",
                value: "\(herb.nutrition.calories)",
                color: .orange
            )
            
            QuickInfoItem(
                icon: "leaf.fill",
                title: "Carbs",
                value: String(format: "%.1fg", herb.nutrition.carbs),
                color: .green
            )
            
            QuickInfoItem(
                icon: "globe",
                title: "Continents",
                value: "\(herb.continents.count)",
                color: .blue
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Quick Info Item
struct QuickInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Compact Info Card
struct CompactInfoCard: View {
    let title: String
    let icon: String
    let content: String
    let color: Color
    let action: (() -> Void)?
    
    init(title: String, icon: String, content: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.content = content
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                if action != nil {
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Compact Tags Card
struct CompactTagsCard: View {
    let title: String
    let icon: String
    let tags: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            FlowLayout(spacing: 6) {
                ForEach(tags.prefix(6), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.1))
                        )
                        .foregroundColor(color)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Modern Nutrition Card
struct CompactNutritionCard: View {
    let nutrition: Nutrition
    let vitamins: [String]
    @State private var showingVitaminDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with gradient background
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nutritional Profile")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Essential nutrients & vitamins")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !vitamins.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingVitaminDetails.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("\(vitamins.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "vitamin")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Nutrition Stats with modern cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NutritionStatCard(
                    value: "\(nutrition.calories)",
                    unit: "kcal",
                    label: "Calories",
                    icon: "flame.fill",
                    color: .orange
                )
                
                NutritionStatCard(
                    value: String(format: "%.1f", nutrition.carbs),
                    unit: "g",
                    label: "Carbs",
                    icon: "chart.bar.fill",
                    color: .green
                )
                
                if !vitamins.isEmpty {
                    NutritionStatCard(
                        value: "\(vitamins.count)",
                        unit: "",
                        label: "Vitamins",
                        icon: "vitamin",
                        color: .purple
                    )
                }
            }
            
            // Vitamin Details (Expandable)
            if !vitamins.isEmpty && showingVitaminDetails {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Vitamin Benefits")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(vitamins.count) vitamins")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(vitamins, id: \.self) { vitamin in
                            VitaminBenefitCard(vitamin: vitamin)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func vitaminDefinition(for vitamin: String) -> String {
        switch vitamin.uppercased() {
        case "A":
            return "Supports vision, immune system, and skin health"
        case "B1", "THIAMINE":
            return "Helps convert food into energy and supports nerve function"
        case "B2", "RIBOFLAVIN":
            return "Essential for energy production and cell growth"
        case "B6":
            return "Supports brain development and immune function"
        case "C":
            return "Antioxidant that boosts immunity and collagen production"
        case "D":
            return "Supports bone health and calcium absorption"
        case "E":
            return "Antioxidant that protects cells from damage"
        case "K":
            return "Essential for blood clotting and bone health"
        case "CALCIUM":
            return "Builds strong bones and teeth, supports muscle function"
        case "IRON":
            return "Carries oxygen in blood, prevents anemia"
        case "MAGNESIUM":
            return "Supports muscle and nerve function, bone health"
        case "ZINC":
            return "Boosts immune system and wound healing"
        case "FOLATE":
            return "Supports cell division and prevents birth defects"
        case "POTASSIUM":
            return "Regulates blood pressure and muscle contractions"
        case "PHOSPHORUS":
            return "Builds strong bones and teeth"
        case "SELENIUM":
            return "Antioxidant that supports thyroid function"
        case "COPPER":
            return "Helps form red blood cells and maintain nerve cells"
        case "MANGANESE":
            return "Supports bone formation and metabolism"
        case "CHROMIUM":
            return "Helps regulate blood sugar levels"
        default:
            return "Supports overall health and wellness"
        }
    }
}

// MARK: - Nutrition Stat Card
struct NutritionStatCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Vitamin Benefit Card
struct VitaminBenefitCard: View {
    let vitamin: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack {
                    Circle()
                        .fill(vitaminColor.opacity(0.15))
                        .frame(width: 24, height: 24)
                    
                    Text(vitamin)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(vitaminColor)
                }
                
                Spacer()
                
                Image(systemName: vitaminIcon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(vitaminColor)
            }
            
            Text(vitaminDefinition(for: vitamin))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: vitaminColor.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var vitaminColor: Color {
        switch vitamin.uppercased() {
        case "A": return .orange
        case "B1", "B2", "B6", "B12": return .blue
        case "C": return .green
        case "D": return .yellow
        case "E": return .purple
        case "K": return .red
        case "CALCIUM": return .gray
        case "IRON": return .red
        case "MAGNESIUM": return .green
        case "ZINC": return .blue
        default: return .purple
        }
    }
    
    private var vitaminIcon: String {
        switch vitamin.uppercased() {
        case "A": return "eye.fill"
        case "B1", "B2", "B6", "B12": return "bolt.fill"
        case "C": return "shield.fill"
        case "D": return "sun.max.fill"
        case "E": return "leaf.fill"
        case "K": return "drop.fill"
        case "CALCIUM": return "bone.fill"
        case "IRON": return "heart.fill"
        case "MAGNESIUM": return "bolt.circle.fill"
        case "ZINC": return "cross.fill"
        default: return "star.fill"
        }
    }
    
    private func vitaminDefinition(for vitamin: String) -> String {
        switch vitamin.uppercased() {
        case "A":
            return "Supports vision, immune system, and skin health"
        case "B1", "THIAMINE":
            return "Helps convert food into energy and supports nerve function"
        case "B2", "RIBOFLAVIN":
            return "Essential for energy production and cell growth"
        case "B6":
            return "Supports brain development and immune function"
        case "C":
            return "Antioxidant that boosts immunity and collagen production"
        case "D":
            return "Supports bone health and calcium absorption"
        case "E":
            return "Antioxidant that protects cells from damage"
        case "K":
            return "Essential for blood clotting and bone health"
        case "CALCIUM":
            return "Builds strong bones and teeth, supports muscle function"
        case "IRON":
            return "Carries oxygen in blood, prevents anemia"
        case "MAGNESIUM":
            return "Supports muscle and nerve function, bone health"
        case "ZINC":
            return "Boosts immune system and wound healing"
        case "FOLATE":
            return "Supports cell division and prevents birth defects"
        case "POTASSIUM":
            return "Regulates blood pressure and muscle contractions"
        case "PHOSPHORUS":
            return "Builds strong bones and teeth"
        case "SELENIUM":
            return "Antioxidant that supports thyroid function"
        case "COPPER":
            return "Helps form red blood cells and maintain nerve cells"
        case "MANGANESE":
            return "Supports bone formation and metabolism"
        case "CHROMIUM":
            return "Helps regulate blood sugar levels"
        default:
            return "Supports overall health and wellness"
        }
    }
}

// MARK: - Compact Local Names Card
struct CompactLocalNamesCard: View {
    let localNames: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Local Names")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 4) {
                ForEach(Array(localNames.prefix(3)), id: \.key) { country, name in
                    HStack {
                        Text(country)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Compact Warning Card
struct CompactWarningCard: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                
                Text("Precautions")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Compact Continents Card
struct CompactContinentsCard: View {
    let continents: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("Continents")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 8) {
                ForEach(continents.prefix(3), id: \.self) { continentCode in
                    if let continent = Continent(rawValue: continentCode) {
                        HStack(spacing: 4) {
                            Text(continent.emoji)
                                .font(.system(size: 16))
                            Text(continent.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.1))
                        )
                        .foregroundColor(.purple)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Compact Wikipedia Button
struct CompactWikipediaButton: View {
    let url: URL
    
    var body: some View {
        Button(action: {
            let safariVC = SFSafariViewController(url: url)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(safariVC, animated: true)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Learn More on Wikipedia")
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        let positions: [CGPoint]
        let size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentPosition = CGPoint.zero
            var lineHeight: CGFloat = 0
            var maxWidth = maxWidth
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentPosition.x + size.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(currentPosition)
                currentPosition.x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.positions = positions
            self.size = CGSize(width: maxWidth, height: currentPosition.y + lineHeight)
        }
    }
}

// MARK: - Health Profile Safety Section
struct HealthProfileSafetySection: View {
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
            // Personalized Dosage
            if personalizedDosage != herb.dosage {
                PersonalizedDosageCard(standardDosage: herb.dosage, herb: herb)
                    .id("dosage-\(herb.id)-\(healthProfile.getSavedDosage(for: herb.id)?.dateCalculated.timeIntervalSince1970 ?? 0)")
            }
            
            // Safety Warnings
            if !safetyWarnings.isEmpty {
                SafetyWarningsCard(warnings: safetyWarnings)
            }
            
            // Health Profile Summary
            HealthProfileSummaryCard(healthProfile: healthProfile)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct PersonalizedDosageCard: View {
    let standardDosage: String
    let herb: Herb
    @StateObject private var healthProfile = HealthProfileManager.shared
    @State private var showingDosageInfo = false
    @State private var showingDosageDetails = false
    
    private var dosage: String {
        let dosage = healthProfile.getPersonalizedDosage(for: herb)
        print("PersonalizedDosageCard for \(herb.englishName) getting dosage: \(dosage)")
        return dosage
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Personalized Dosage")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showingDosageInfo.toggle()
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text(dosage)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    // Show saved dosage indicator if available
                    if let savedDosage = healthProfile.getSavedDosage(for: herb.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("Saved dosage available")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                    
                    // View Details button if saved dosage exists
                    if healthProfile.getSavedDosage(for: herb.id) != nil {
                        Button(action: {
                            showingDosageDetails = true
                        }) {
                            Text("View Details")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Dosage Information Panel
            if showingDosageInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Dosage Information")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    if let savedDosage = healthProfile.getSavedDosage(for: herb.id) {
                        // Show saved dosage details
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Standard Dose:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(standardDosage)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Your Saved Dose:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(savedDosage.calculatedDosage)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Calculated for:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(savedDosage.age) years, \(formatWeight(savedDosage.weight, unit: .kg))")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Condition:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("\(savedDosage.condition) (\(savedDosage.conditionSeverity.capitalized))")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Calculated:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(formatDate(savedDosage.dateCalculated))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Text("This dosage was calculated based on your specific health profile and condition severity for optimal safety and effectiveness.")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    } else {
                        // Show basic personalized dosage info
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Standard Dose:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(standardDosage)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Your Dose:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(dosage)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Your dosage has been adjusted based on your age, weight, and health conditions for optimal safety and effectiveness.")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.05))
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.1))
        )
        .sheet(isPresented: $showingDosageDetails) {
            if let savedDosage = healthProfile.getSavedDosage(for: herb.id) {
                SavedDosageDetailView(dosageResult: savedDosage, herb: herb)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct SafetyWarningsCard: View {
    let warnings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.orange)
                
                Text("Safety Warnings")
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

struct HealthProfileSummaryCard: View {
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Health Profile Active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(healthProfile.age) years • \(formatWeight(healthProfile.weight, unit: healthProfile.weightUnit))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if healthProfile.isPregnant || healthProfile.isNursing {
                Image(systemName: "figure.and.child.holdinghands")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.pink)
            }
            
            if !healthProfile.medications.isEmpty {
                Image(systemName: "pills.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
            }
            
            if !healthProfile.allergies.isEmpty {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Saved Dosage Detail View
struct SavedDosageDetailView: View {
    let dosageResult: DosageResult
    let herb: Herb
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthProfile = HealthProfileManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Saved Dosage")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("for \(herb.englishName)")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // Dosage result
                    VStack(spacing: 16) {
                        Text(dosageResult.calculatedDosage)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                        
                        Text("Calculated on \(formatDate(dosageResult.dateCalculated))")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
                    // Calculation details
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Calculation Details", icon: "calculator.fill")
                        
                        VStack(spacing: 12) {
                            DetailRow(title: "Age", value: "\(dosageResult.age) years")
                            DetailRow(title: "Weight", value: formatWeight(dosageResult.weight, unit: .kg))
                            DetailRow(title: "Condition", value: dosageResult.condition)
                            DetailRow(title: "Severity", value: dosageResult.conditionSeverity.capitalized)
                            DetailRow(title: "Source", value: dosageResult.isFromHealthProfile ? "Health Profile" : "Custom Input")
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 16) {
                        Button(action: {
                            healthProfile.removeSavedDosage(for: herb.id)
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Remove Saved Dosage")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            // Navigate to preparation guide with these values
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Use in Preparation Guide")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Saved Dosage")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
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

// MARK: - Web-Based Drug Interaction Checker Card
struct DrugInteractionCheckerCard: View {
    let herb: Herb
    @StateObject private var healthProfile = HealthProfileManager.shared
    @State private var showingWebView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                HStack(spacing: 4) {
                    Text("Drug Interaction Checker")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                if healthProfile.medications.isEmpty {
                    Text("No medications")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        copyPromptToClipboard()
                        showingWebView = true
                    }) {
                        HStack(spacing: 4) {
                            Text("Check Online")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.purple)
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.purple)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if healthProfile.medications.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add your medications in Settings to check for interactions")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Navigate to settings
                    }) {
                        Text("Go to Settings")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current medications: \(healthProfile.medications.joined(separator: ", "))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tap 'Check Online' to open drug interactions checker and paste from clipboard into ChatGPT")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.purple)
                            
                            Text("AI-powered analysis")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.1))
        )
        .sheet(isPresented: $showingWebView) {
            DrugInteractionWebView(herb: herb, medications: healthProfile.medications)
        }
        .overlay(
            // Copy success overlay
            Group {
                if showingCopySuccess {
                    VStack {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                            
                            Text("Prompt copied to clipboard!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.8))
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 100)
                    .animation(.easeInOut(duration: 0.3), value: showingCopySuccess)
                }
            }
        )
    }
    
    private func copyPromptToClipboard() {
        let herbName = herb.englishName
        let medicationsList = healthProfile.medications.isEmpty ? "no medications listed" : healthProfile.medications.joined(separator: ", ")
        
        print("🔍 Debug: Herb name = \(herbName)")
        print("🔍 Debug: Medications count = \(healthProfile.medications.count)")
        print("🔍 Debug: Medications = \(healthProfile.medications)")
        
        let prompt = """
        Please analyze potential drug interactions between \(herbName) and the following medications: \(medicationsList).
        
        For each potential interaction, please provide:
        1. Severity level (Low, Moderate, High, or None)
        2. Mechanism of interaction
        3. Potential side effects
        4. Recommendations for safe use
        5. Whether to avoid, monitor, or if it's safe to use together
        
        Please format your response clearly and prioritize safety. If you're unsure about any interaction, recommend consulting with a healthcare professional.
        """
        
        print("📝 Generated prompt:")
        print(prompt)
        
        // Copy to clipboard
        UIPasteboard.general.string = prompt
        
        // Verify the copy worked
        if let copiedText = UIPasteboard.general.string {
            print("✅ Drug interaction prompt copied to clipboard successfully")
            print("📋 Copied text length: \(copiedText.count) characters")
            print("📋 First 100 characters: \(String(copiedText.prefix(100)))")
            
            // Show visual feedback
            DispatchQueue.main.async {
                showCopySuccessOverlay()
            }
        } else {
            print("❌ Failed to copy prompt to clipboard")
            
            // Try alternative clipboard method
            DispatchQueue.main.async {
                UIPasteboard.general.setValue(prompt, forPasteboardType: "public.utf8-plain-text")
                
                if let retryText = UIPasteboard.general.string {
                    print("✅ Retry successful - prompt copied to clipboard")
                    showCopySuccessOverlay()
                } else {
                    print("❌ All clipboard methods failed")
                }
            }
        }
    }
    
    @State private var showingCopySuccess = false
    
    private func showCopySuccessOverlay() {
        showingCopySuccess = true
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showingCopySuccess = false
        }
    }
}

// MARK: - Interaction Result View
struct InteractionResultView: View {
    let result: DrugInteractionResult
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.severity.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(severityColor)
                
                Text("\(result.severity.displayName) Risk")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(severityColor)
                
                Spacer()
                
                Button(action: {
                    showingDetails = true
                }) {
                    Text("Details")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if result.hasInteractions {
                Text("\(result.interactions.count) potential interaction(s) found")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            } else {
                Text("No known interactions detected")
                    .font(.system(size: 11))
                    .foregroundColor(.green)
            }
            
            // Show if using fallback
            if result.recommendations.contains("Error occurred while checking interactions") {
                HStack(spacing: 4) {
                    Image(systemName: "database")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("Using local database (ChatGPT unavailable)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingDetails) {
            DrugInteractionDetailView(result: result, herb: Herb(
                id: "preview",
                englishName: "Preview Herb",
                localNames: [:],
                scientificName: "Preview",
                description: "",
                uses: [],
                category: "",
                vitamins: [],
                nutrition: Nutrition(calories: 0, carbs: 0),
                ailments: [],
                locations: [],
                preparation: "",
                dosage: "",
                precautions: "",
                honeyUsage: "",
                continents: [],
                wikipediaUrl: ""
            ))
        }
    }
    
    private var severityColor: Color {
        switch result.severity {
        case .none: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Drug Interaction Detail View
struct DrugInteractionDetailView: View {
    let result: DrugInteractionResult
    let herb: Herb
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: result.severity.icon)
                            .font(.system(size: 60))
                            .foregroundColor(severityColor)
                        
                        Text("Drug Interaction Analysis")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("for \(herb.englishName)")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // Severity Summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Risk Level")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(result.severity.displayName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(severityColor)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(severityColor.opacity(0.1))
                        )
                    }
                    
                    // Interactions
                    if !result.interactions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Found Interactions")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            ForEach(result.interactions, id: \.medication) { interaction in
                                InteractionDetailCard(interaction: interaction)
                            }
                        }
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ForEach(result.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                        .padding(.top, 2)
                                    
                                    Text(recommendation)
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Interaction Details")
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
    
    private var severityColor: Color {
        switch result.severity {
        case .none: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Interaction Detail Card
struct InteractionDetailCard: View {
    let interaction: DrugInteraction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: severityIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(severityColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(interaction.herb) + \(interaction.medication)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(interaction.severity.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(severityColor)
                }
                
                Spacer()
            }
            
            Text(interaction.description)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            HStack {
                Text("Mechanism:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(interaction.mechanism)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Text("Recommendation:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(interaction.recommendation)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(severityColor.opacity(0.1))
        )
    }
    
    private var severityColor: Color {
        switch interaction.severity {
        case .none: return .green
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        }
    }
    
    private var severityIcon: String {
        switch interaction.severity {
        case .none: return "checkmark.circle.fill"
        case .low: return "exclamationmark.triangle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "xmark.octagon.fill"
        }
    }
}

// MARK: - Drug Interaction Web View
struct DrugInteractionWebView: View {
    let herb: Herb
    let medications: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var webView: WKWebView?
    
    var body: some View {
        NavigationView {
            ZStack {
                if let webView = webView {
                    WebViewRepresentable(webView: webView, herb: herb, medications: medications)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Loading ChatGPT...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("ChatGPT Drug Checker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if webView != nil {
                        HStack(spacing: 12) {
                            Button(action: {
                                webView?.goBack()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .disabled(!(webView?.canGoBack ?? false))
                            
                            Button(action: {
                                webView?.goForward()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .disabled(!(webView?.canGoForward ?? false))
                            
                            Button(action: {
                                webView?.reload()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            setupWebView()
        }
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        let delegate = WebViewDelegate(herb: herb, medications: medications)
        webView.navigationDelegate = delegate
        
        // Load ChatGPT.com
        if let url = URL(string: "https://chat.openai.com/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.webView = webView
    }
}

// MARK: - Web View Representable
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let herb: Herb
    let medications: [String]
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

// MARK: - Web View Delegate
class WebViewDelegate: NSObject, WKNavigationDelegate {
    let herb: Herb
    let medications: [String]
    
    init(herb: Herb, medications: [String]) {
        self.herb = herb
        self.medications = medications
        super.init()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Wait a bit for ChatGPT to fully load
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.injectChatGPTPrompt(webView: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error.localizedDescription)")
    }
    
    private func injectChatGPTPrompt(webView: WKWebView) {
        let herbName = herb.englishName
        let medicationsList = medications.joined(separator: ", ")
        
        // Create a comprehensive drug interaction prompt
        let prompt = """
        Please analyze potential drug interactions between \(herbName) and the following medications: \(medicationsList).
        
        For each potential interaction, please provide:
        1. Severity level (Low, Moderate, High, or None)
        2. Mechanism of interaction
        3. Potential side effects
        4. Recommendations for safe use
        5. Whether to avoid, monitor, or if it's safe to use together
        
        Please format your response clearly and prioritize safety. If you're unsure about any interaction, recommend consulting with a healthcare professional.
        """
        
        // Try to inject the prompt, but also show instructions if it fails
        let script = """
        // Try to find the ChatGPT textarea and populate it
        function findAndFillTextarea() {
            // Look for the main textarea in ChatGPT
            const textarea = document.querySelector('textarea[data-id="root"], textarea[placeholder*="Message"], textarea[placeholder*="Send a message"], textarea[placeholder*="Ask anything"], textarea[placeholder*="Message ChatGPT"]');
            
            if (textarea) {
                // Set the value
                textarea.value = `\(prompt)`;
                
                // Trigger input event to update ChatGPT's UI
                textarea.dispatchEvent(new Event('input', { bubbles: true }));
                textarea.dispatchEvent(new Event('change', { bubbles: true }));
                
                // Focus the textarea
                textarea.focus();
                
                console.log('ChatGPT prompt injected successfully');
                return true;
            }
            
            // Alternative selectors for different ChatGPT layouts
            const alternativeSelectors = [
                'div[contenteditable="true"]',
                'div[role="textbox"]',
                'div[data-testid="send-button"]',
                'div[contenteditable="true"][data-id="root"]'
            ];
            
            for (const selector of alternativeSelectors) {
                const element = document.querySelector(selector);
                if (element) {
                    element.textContent = `\(prompt)`;
                    element.dispatchEvent(new Event('input', { bubbles: true }));
                    console.log('ChatGPT prompt injected via alternative selector');
                    return true;
                }
            }
            
            console.log('ChatGPT textarea not found, retrying...');
            return false;
        }
        
        // Try multiple times with delays
        let attempts = 0;
        const maxAttempts = 3;
        
        function attemptInjection() {
            if (attempts >= maxAttempts) {
                console.log('Failed to inject prompt after ' + maxAttempts + ' attempts');
                // Show instructions to user
                showInstructions();
                return;
            }
            
            if (!findAndFillTextarea()) {
                attempts++;
                setTimeout(attemptInjection, 1000);
            }
        }
        
        function showInstructions() {
            // Create a floating instruction box
            const instructionBox = document.createElement('div');
            instructionBox.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #6366f1;
                color: white;
                padding: 16px;
                border-radius: 12px;
                max-width: 300px;
                z-index: 10000;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                font-size: 14px;
                line-height: 1.4;
            `;
            
            instructionBox.innerHTML = `
                <div style="font-weight: 600; margin-bottom: 8px;">📋 Prompt Copied!</div>
                <div style="margin-bottom: 12px;">The drug interaction prompt has been copied to your clipboard. Simply paste it into ChatGPT:</div>
                <div style="background: rgba(255,255,255,0.1); padding: 8px; border-radius: 6px; font-size: 12px; margin-bottom: 12px; word-break: break-word;">
                    \(prompt)
                </div>
                <div style="font-size: 12px; margin-bottom: 12px; opacity: 0.9;">
                    💡 Tip: Press Cmd+V (Mac) or Ctrl+V (Windows) to paste
                </div>
                <button onclick="this.parentElement.remove()" style="background: rgba(255,255,255,0.2); border: none; color: white; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 12px;">Got it!</button>
            `;
            
            document.body.appendChild(instructionBox);
            
            // Auto-remove after 30 seconds
            setTimeout(() => {
                if (instructionBox.parentElement) {
                    instructionBox.remove();
                }
            }, 30000);
        }
        
        attemptInjection();
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript injection error: \(error.localizedDescription)")
                // If JavaScript fails, we'll rely on the instruction box
            } else {
                print("JavaScript injection completed")
            }
        }
    }
}

#Preview {
    HerbDetailView(herb: Herb(
        id: "test",
        englishName: "Hibiscus Tea",
        localNames: ["NG": "Zobo", "SD": "Karkade"],
        scientificName: "Hibiscus sabdariffa",
        description: "A tangy herbal drink made from dried hibiscus petals, known for its refreshing taste and potential health benefits.",
        uses: ["Refreshment", "Blood pressure", "Antioxidant"],
        category: "Herb",
        vitamins: ["C", "B1"],
        nutrition: Nutrition(calories: 5, carbs: 1.2),
        ailments: ["Hypertension", "Fatigue"],
        locations: ["West Africa", "Tropics"],
        preparation: "Boil dried petals in water for 10-15 minutes",
        dosage: "1-2 cups daily",
        precautions: "Avoid during pregnancy",
        honeyUsage: "Common sweetener",
        continents: ["AF"],
        wikipediaUrl: "https://en.wikipedia.org/wiki/Hibiscus_tea"
    ))
} 