import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var healthProfile = HealthProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Personal Health Profile Section
                    PersonalHealthProfileSection(healthProfile: healthProfile)
                    
                    // Unit Settings Section
                    UnitSettingsSection(healthProfile: healthProfile)
                    
                    // App Settings Section
                    AppSettingsSection()
                    
                    // Saved Dosages Section
                    SavedDosagesSection(healthProfile: healthProfile)
                    
                    // About Section
                    AboutSection()
                    
                    // Debug Section
                    DebugSection()
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Personal Health Profile Section
struct PersonalHealthProfileSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @State private var showingHealthProfile = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Personal Health Profile", icon: "heart.fill", color: .red)
            
            VStack(spacing: 12) {
                // Profile Summary Card
                Button(action: {
                    showingHealthProfile = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Health Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(healthProfile.hasProfile ? "Profile completed" : "Complete your profile")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Quick Stats
                if healthProfile.hasProfile {
                    HStack(spacing: 16) {
                        QuickStatCard(
                            title: "Age",
                            value: "\(healthProfile.age) years",
                            icon: "person.fill",
                            color: .blue
                        )
                        
                        QuickStatCard(
                            title: "Weight",
                            value: formatWeight(healthProfile.weight, unit: healthProfile.weightUnit),
                            icon: "scalemass.fill",
                            color: .green
                        )
                        
                        QuickStatCard(
                            title: "Conditions",
                            value: "\(healthProfile.healthConditions.count)",
                            icon: "heart.circle.fill",
                            color: .red
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showingHealthProfile) {
            HealthProfileDetailView(healthProfile: healthProfile)
        }
    }
}

// MARK: - Health Profile Detail View
struct HealthProfileDetailView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddCondition = false
    @State private var showingAddAllergy = false
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Information
                    BasicInfoSection(healthProfile: healthProfile)
                    
                    // Health Conditions
                    HealthConditionsSection(
                        healthProfile: healthProfile,
                        showingAddCondition: $showingAddCondition
                    )
                    
                    // Allergies & Sensitivities
                    AllergiesSection(
                        healthProfile: healthProfile,
                        showingAddAllergy: $showingAddAllergy
                    )
                    
                    // Current Medications
                    MedicationsSection(
                        healthProfile: healthProfile,
                        showingAddMedication: $showingAddMedication
                    )
                    
                    // Pregnancy & Nursing Status
                    PregnancyStatusSection(healthProfile: healthProfile)
                    
                    // Safety Warnings
                    SafetyWarningsSection(healthProfile: healthProfile)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Health Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddCondition) {
                AddHealthConditionView(healthProfile: healthProfile)
            }
            .sheet(isPresented: $showingAddAllergy) {
                AddAllergyView(healthProfile: healthProfile)
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView(healthProfile: healthProfile)
            }
        }
    }
}

// MARK: - Basic Info Section


struct BasicInfoSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @State private var showingAgeEditor = false
    @State private var showingWeightEditor = false
    @State private var showingHeightEditor = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Basic Information", icon: "person.fill", color: .blue)
            
            VStack(spacing: 12) {
                InfoRow(
                    title: "Age",
                    value: "\(healthProfile.age) years",
                    icon: "person.fill",
                    color: .blue
                ) {
                    showingAgeEditor = true
                }
                
                InfoRow(
                    title: "Weight",
                    value: formatWeight(healthProfile.weight, unit: healthProfile.weightUnit),
                    icon: "scalemass.fill",
                    color: .green
                ) {
                    showingWeightEditor = true
                }
                
                InfoRow(
                    title: "Height",
                    value: formatHeight(healthProfile.height, unit: healthProfile.heightUnit),
                    icon: "ruler.fill",
                    color: .orange
                ) {
                    showingHeightEditor = true
                }
            }
        }
        .sheet(isPresented: $showingAgeEditor) {
            EditAgeView(healthProfile: healthProfile)
        }
        .sheet(isPresented: $showingWeightEditor) {
            EditWeightView(healthProfile: healthProfile)
        }
        .sheet(isPresented: $showingHeightEditor) {
            EditHeightView(healthProfile: healthProfile)
        }
    }
}

// MARK: - Unit Settings Section
struct UnitSettingsSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Units", icon: "ruler", color: .purple)
            
            VStack(spacing: 12) {
                // Weight Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight Unit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Picker("Weight Unit", selection: $healthProfile.weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: healthProfile.weightUnit) { newUnit in
                        healthProfile.updateWeightUnit(newUnit)
                    }
                }
                
                // Height Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height Unit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Picker("Height Unit", selection: $healthProfile.heightUnit) {
                        ForEach(HeightUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: healthProfile.heightUnit) { newUnit in
                        healthProfile.updateHeightUnit(newUnit)
                    }
                }
            }
        }
    }
}

// MARK: - Health Conditions Section
struct HealthConditionsSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Binding var showingAddCondition: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SettingsSectionHeader(title: "Health Conditions", icon: "heart.circle.fill", color: .red)
                
                Spacer()
                
                Button(action: {
                    showingAddCondition = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            
            if healthProfile.healthConditions.isEmpty {
                EmptyStateView(
                    icon: "heart.circle",
                    title: "No Health Conditions",
                    message: "Add your health conditions to get personalized herb recommendations"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(healthProfile.healthConditions, id: \.self) { condition in
                        SettingsConditionCard(condition: condition) {
                            healthProfile.removeHealthCondition(condition)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Allergies Section
struct AllergiesSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Binding var showingAddAllergy: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SettingsSectionHeader(title: "Allergies & Sensitivities", icon: "exclamationmark.triangle.fill", color: .orange)
                
                Spacer()
                
                Button(action: {
                    showingAddAllergy = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            
            if healthProfile.allergies.isEmpty {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "No Allergies",
                    message: "Add your allergies to avoid potentially harmful herbs"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(healthProfile.allergies, id: \.self) { allergy in
                        AllergyCard(allergy: allergy) {
                            healthProfile.removeAllergy(allergy)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Medications Section
struct MedicationsSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Binding var showingAddMedication: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SettingsSectionHeader(title: "Current Medications", icon: "pills.fill", color: .purple)
                
                Spacer()
                
                Button(action: {
                    showingAddMedication = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            
            if healthProfile.medications.isEmpty {
                EmptyStateView(
                    icon: "pills",
                    title: "No Medications",
                    message: "Add your medications to check for herb interactions"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(healthProfile.medications, id: \.self) { medication in
                        MedicationCard(medication: medication) {
                            healthProfile.removeMedication(medication)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pregnancy Status Section
struct PregnancyStatusSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Pregnancy & Nursing", icon: "figure.and.child.holdinghands", color: .pink)
            
            VStack(spacing: 12) {
                Toggle("Pregnant", isOn: $healthProfile.isPregnant)
                    .toggleStyle(SwitchToggleStyle(tint: .pink))
                
                Toggle("Nursing", isOn: $healthProfile.isNursing)
                    .toggleStyle(SwitchToggleStyle(tint: .pink))
                
                if healthProfile.isPregnant || healthProfile.isNursing {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Some herbs may not be safe during pregnancy or nursing")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
            }
        }
    }
}

// MARK: - Safety Warnings Section
struct SafetyWarningsSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Safety Warnings", icon: "shield.fill", color: .red)
            
            VStack(spacing: 12) {
                if healthProfile.hasInteractions {
                    SafetyWarningCard(
                        title: "Medication Interactions",
                        message: "Some herbs may interact with your medications",
                        icon: "pills.fill",
                        color: .purple
                    )
                }
                
                if healthProfile.isPregnant || healthProfile.isNursing {
                    SafetyWarningCard(
                        title: "Pregnancy Safety",
                        message: "Some herbs are not recommended during pregnancy or nursing",
                        icon: "figure.and.child.holdinghands",
                        color: .pink
                    )
                }
                
                if !healthProfile.allergies.isEmpty {
                    SafetyWarningCard(
                        title: "Allergy Alert",
                        message: "Some herbs may contain allergens you're sensitive to",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                }
                
                if healthProfile.healthConditions.contains("Diabetes") {
                    SafetyWarningCard(
                        title: "Blood Sugar",
                        message: "Some herbs may affect blood sugar levels",
                        icon: "drop.fill",
                        color: .red
                    )
                }
                
                if healthProfile.healthConditions.contains("Hypertension") {
                    SafetyWarningCard(
                        title: "Blood Pressure",
                        message: "Some herbs may affect blood pressure",
                        icon: "heart.fill",
                        color: .red
                    )
                }
            }
        }
    }
}

// MARK: - App Settings Section
struct AppSettingsSection: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showingNotificationAlert = false
    @State private var notificationAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "App Settings", icon: "gear", color: .gray)
            
            VStack(spacing: 16) {
                // Notifications Setting
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Get reminders for herb preparation and dosage")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .onChange(of: notificationsEnabled) { newValue in
                                handleNotificationToggle(enabled: newValue)
                            }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                // Dark Mode Setting
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dark Mode")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Switch between light and dark appearance")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $darkModeEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .onChange(of: darkModeEnabled) { newValue in
                                handleDarkModeToggle(enabled: newValue)
                            }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                

            }
        }
        .alert("Notifications", isPresented: $showingNotificationAlert) {
            Button("OK") { }
        } message: {
            Text(notificationAlertMessage)
        }
    }
    
    private func handleNotificationToggle(enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            // Notifications are disabled
            notificationAlertMessage = "Notifications have been disabled. You can re-enable them anytime in Settings."
            showingNotificationAlert = true
        }
    }
    
    private func handleDarkModeToggle(enabled: Bool) {
        // Dark mode is handled by the app's color scheme
        // The @AppStorage will automatically update the app's appearance
    }
    

    
    private func requestNotificationPermission() {
        NotificationService.shared.requestPermission { granted in
            if granted {
                self.notificationAlertMessage = "Notifications enabled! You'll receive reminders for herb preparation and dosage."
                self.showingNotificationAlert = true
                
                // Schedule daily wellness reminder
                NotificationService.shared.scheduleDailyWellnessReminder()
            } else {
                self.notificationsEnabled = false
                self.notificationAlertMessage = "Notification permission denied. You can enable notifications in iOS Settings."
                self.showingNotificationAlert = true
            }
        }
    }
}

// MARK: - Saved Dosages Section
struct SavedDosagesSection: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @State private var showingClearConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Saved Dosages", icon: "bookmark.fill", color: .blue)
            
            if healthProfile.savedDosages.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No Saved Dosages")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Dosages calculated in the preparation guide will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(healthProfile.savedDosages) { dosage in
                        SavedDosageRow(dosage: dosage, healthProfile: healthProfile)
                    }
                    
                    Button(action: {
                        showingClearConfirmation = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Clear All Saved Dosages")
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
                }
            }
        }
        .alert("Clear All Dosages", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                healthProfile.clearAllSavedDosages()
            }
        } message: {
            Text("This will remove all saved dosages. This action cannot be undone.")
        }
    }
}

// MARK: - Saved Dosage Row
struct SavedDosageRow: View {
    let dosage: DosageResult
    @ObservedObject var healthProfile: HealthProfileManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dosage.herbName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(dosage.calculatedDosage)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("Calculated \(formatDate(dosage.dateCalculated))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                healthProfile.removeSavedDosage(for: dosage.id)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - About Section
struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "About", icon: "info.circle.fill", color: .blue)
            
            VStack(spacing: 12) {
                InfoRow(
                    title: "Version",
                    value: "1.0.0",
                    icon: "app.badge",
                    color: .blue
                ) {
                    // Version info
                }
                
                InfoRow(
                    title: "Data Source",
                    value: "Traditional Medicine Database",
                    icon: "database.fill",
                    color: .green
                ) {
                    // Data source info
                }
                
                Button(action: {
                    // Open privacy policy
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.blue)
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
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
    }
}

// MARK: - Supporting Views
struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
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

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct SettingsConditionCard: View {
    let condition: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "heart.circle.fill")
                .foregroundColor(.red)
            
            Text(condition)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct AllergyCard: View {
    let allergy: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(allergy)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct MedicationCard: View {
    let medication: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundColor(.purple)
            
            Text(medication)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct SafetyWarningCard: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Edit Basic Information Views
struct EditAgeView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var age = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Edit Age")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your age helps us provide personalized dosage recommendations")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Age input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    TextField("Enter your age", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(.system(size: 18))
                }
                
                // Age guidelines
                VStack(alignment: .leading, spacing: 12) {
                    Text("Age Guidelines")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        AgeGuidelineRow(age: "Under 18", description: "Reduced dosage (50-75% of adult dose)")
                        AgeGuidelineRow(age: "18-65", description: "Standard adult dosage")
                        AgeGuidelineRow(age: "Over 65", description: "Reduced dosage (75% of adult dose)")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Edit Age")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let ageInt = Int(age), ageInt > 0 && ageInt <= 120 {
                            healthProfile.updateBasicInfo(
                                age: ageInt,
                                weight: healthProfile.weight,
                                height: healthProfile.height
                            )
                            dismiss()
                        }
                    }
                    .disabled(age.isEmpty || Int(age) == nil || Int(age)! <= 0 || Int(age)! > 120)
                }
            }
            .onAppear {
                age = "\(healthProfile.age)"
            }
        }
    }
}

struct EditWeightView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var weight = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 16) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Edit Weight")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your weight helps us calculate personalized dosages")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (\(healthProfile.weightUnit.shortName))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    TextField("Enter your weight", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.system(size: 18))
                }
                
                // Weight guidelines
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight Guidelines")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if healthProfile.weightUnit == .kg {
                            WeightGuidelineRow(weight: "Under 50 kg", description: "Reduced dosage (80% of standard)")
                            WeightGuidelineRow(weight: "50-100 kg", description: "Standard dosage")
                            WeightGuidelineRow(weight: "Over 100 kg", description: "Standard dosage appropriate")
                        } else {
                            WeightGuidelineRow(weight: "Under 110 lb", description: "Reduced dosage (80% of standard)")
                            WeightGuidelineRow(weight: "110-220 lb", description: "Standard dosage")
                            WeightGuidelineRow(weight: "Over 220 lb", description: "Standard dosage appropriate")
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Edit Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let weightDouble = Double(weight), weightDouble > 0 {
                            let maxWeight = healthProfile.weightUnit == .kg ? 300.0 : 660.0
                            if weightDouble <= maxWeight {
                                healthProfile.updateBasicInfo(
                                    age: healthProfile.age,
                                    weight: weightDouble,
                                    height: healthProfile.height
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(weight.isEmpty || Double(weight) == nil || Double(weight)! <= 0 || Double(weight)! > (healthProfile.weightUnit == .kg ? 300.0 : 660.0))
                }
            }
            .onAppear {
                weight = String(format: "%.1f", healthProfile.weight)
            }
        }
    }
}

struct EditHeightView: View {
    @ObservedObject var healthProfile: HealthProfileManager
    @Environment(\.dismiss) private var dismiss
    @State private var height = ""
    @State private var feet = ""
    @State private var inches = ""
    
    private var isHeightInputInvalid: Bool {
        if healthProfile.heightUnit == .cm {
            return height.isEmpty || Double(height) == nil || Double(height)! <= 0 || Double(height)! > 250
        } else {
            return feet.isEmpty || inches.isEmpty || 
                   Int(feet) == nil || Double(inches) == nil ||
                   Int(feet)! < 0 || Int(feet)! > 8 || 
                   Double(inches)! < 0 || Double(inches)! >= 12
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 16) {
                    Image(systemName: "ruler.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Edit Height")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your height helps us calculate BMI and provide better recommendations")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Height input
                if healthProfile.heightUnit == .cm {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height (cm)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter your height", text: $height)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .font(.system(size: 18))
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Height (feet & inches)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Feet")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Feet", text: $feet)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 18))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Inches")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Inches", text: $inches)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                }
                
                // BMI info
                VStack(alignment: .leading, spacing: 12) {
                    Text("BMI Information")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BMIGuidelineRow(bmi: "Under 18.5", category: "Underweight", color: .blue)
                        BMIGuidelineRow(bmi: "18.5-24.9", category: "Normal", color: .green)
                        BMIGuidelineRow(bmi: "25-29.9", category: "Overweight", color: .orange)
                        BMIGuidelineRow(bmi: "30+", category: "Obese", color: .red)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Edit Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if healthProfile.heightUnit == .cm {
                            if let heightDouble = Double(height), heightDouble > 0 && heightDouble <= 250 {
                                healthProfile.updateBasicInfo(
                                    age: healthProfile.age,
                                    weight: healthProfile.weight,
                                    height: heightDouble
                                )
                                dismiss()
                            }
                        } else {
                            if let feetInt = Int(feet), let inchesDouble = Double(inches),
                               feetInt >= 0 && feetInt <= 8, inchesDouble >= 0 && inchesDouble < 12 {
                                let totalInches = Double(feetInt * 12) + inchesDouble
                                healthProfile.updateBasicInfo(
                                    age: healthProfile.age,
                                    weight: healthProfile.weight,
                                    height: totalInches
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(isHeightInputInvalid)
                }
            }
            .onAppear {
                if healthProfile.heightUnit == .cm {
                    height = "\(Int(healthProfile.height))"
                } else {
                    let totalInches = healthProfile.height
                    let feetInt = Int(totalInches / 12)
                    let inchesDouble = totalInches.truncatingRemainder(dividingBy: 12)
                    feet = "\(feetInt)"
                    inches = String(format: "%.1f", inchesDouble)
                }
            }
        }
    }
}

// MARK: - Supporting Views for Edit Forms
struct AgeGuidelineRow: View {
    let age: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(age)
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

struct WeightGuidelineRow: View {
    let weight: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(weight)
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

struct BMIGuidelineRow: View {
    let bmi: String
    let category: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bmi)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(category)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Debug Section
struct DebugSection: View {
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Debug Information", icon: "info.circle.fill", color: .orange)
            
            VStack(spacing: 12) {
                // Data Info Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Source Information")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(dataService.getDataInfo())
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                // Refresh Button
                Button(action: {
                    dataService.refreshData()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Refresh Data from GitHub")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                                       // Test Connection Button
                       Button(action: {
                           dataService.testConnection()
                       }) {
                           HStack {
                               Image(systemName: "network")
                                   .font(.system(size: 16, weight: .medium))

                               Text("Test Connection")
                                   .font(.system(size: 16, weight: .medium))
                           }
                           .foregroundColor(.white)
                           .frame(maxWidth: .infinity)
                           .padding(16)
                           .background(
                               RoundedRectangle(cornerRadius: 12)
                                   .fill(Color.orange)
                           )
                       }
                       .buttonStyle(PlainButtonStyle())

                       // Clear Cache Button
                       Button(action: {
                           dataService.clearCache()
                       }) {
                           HStack {
                               Image(systemName: "trash")
                                   .font(.system(size: 16, weight: .medium))

                               Text("Clear Cache")
                                   .font(.system(size: 16, weight: .medium))
                           }
                           .foregroundColor(.white)
                           .frame(maxWidth: .infinity)
                           .padding(16)
                           .background(
                               RoundedRectangle(cornerRadius: 12)
                                   .fill(Color.red)
                           )
                       }
                       .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    SettingsView()
}