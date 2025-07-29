import Foundation

// MARK: - Formatting Functions
func formatWeight(_ weight: Double, unit: WeightUnit) -> String {
    switch unit {
    case .kg:
        return String(format: "%.1f kg", weight)
    case .lb:
        return String(format: "%.1f lb", weight)
    }
}

func formatHeight(_ height: Double, unit: HeightUnit) -> String {
    switch unit {
    case .cm:
        return String(format: "%.0f cm", height)
    case .ft:
        let feet = Int(height / 12)
        let inches = height.truncatingRemainder(dividingBy: 12)
        return String(format: "%d' %.1f\"", feet, inches)
    }
} 