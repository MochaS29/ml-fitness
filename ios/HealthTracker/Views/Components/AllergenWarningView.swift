import SwiftUI

struct AllergenWarningView: View {
    let warning: AllergenWarning
    @Binding var isPresented: Bool
    let onProceed: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Warning Icon
            Image(systemName: warningIcon)
                .font(.system(size: 60))
                .foregroundColor(warningColor)
            
            // Title
            Text(warningTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Allergen List
            VStack(alignment: .leading, spacing: 12) {
                Text("Detected Allergens:")
                    .font(.headline)
                
                ForEach(warning.allergens, id: \.allergen) { allergenInfo in
                    AllergenDetailRow(allergenInfo: allergenInfo)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            
            // Warning Message
            Text(warning.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    onCancel()
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                
                if warning.severity != .severe {
                    Button(action: {
                        onProceed()
                        isPresented = false
                    }) {
                        Text("Proceed Anyway")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(proceedButtonColor)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
    
    private var warningIcon: String {
        switch warning.severity {
        case .mild:
            return "exclamationmark.circle"
        case .moderate:
            return "exclamationmark.triangle"
        case .severe:
            return "exclamationmark.octagon.fill"
        }
    }
    
    private var warningColor: Color {
        switch warning.severity {
        case .mild:
            return .yellow
        case .moderate:
            return .orange
        case .severe:
            return .red
        }
    }
    
    private var warningTitle: String {
        switch warning.severity {
        case .mild:
            return "Allergy Notice"
        case .moderate:
            return "Allergy Warning"
        case .severe:
            return "SEVERE ALLERGY WARNING"
        }
    }
    
    private var proceedButtonColor: Color {
        switch warning.severity {
        case .mild:
            return .yellow
        case .moderate:
            return .orange
        case .severe:
            return .red
        }
    }
}

// MARK: - Allergen Detail Row

struct AllergenDetailRow: View {
    let allergenInfo: AllergenInfo
    
    var body: some View {
        HStack {
            Text(allergenInfo.allergen.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(allergenInfo.allergen.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(allergenInfo.confidence.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Found in: \(allergenInfo.ingredientSource)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Inline Allergen Warning

struct InlineAllergenWarning: View {
    let allergens: [AllergenInfo]
    @State private var isExpanded = false
    
    var body: some View {
        if !allergens.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Contains allergens (\(allergens.count))")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(allergens, id: \.allergen) { info in
                            HStack {
                                Text(info.allergen.icon)
                                    .font(.caption)
                                Text(info.allergen.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Dietary Compliance Badge

struct DietaryComplianceBadge: View {
    let result: DietaryComplianceResult
    @State private var showingDetails = false
    
    var body: some View {
        if !result.isCompliant {
            Button(action: { showingDetails = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                    Text("Not \(violatedPreferences)")
                        .font(.caption)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
            .sheet(isPresented: $showingDetails) {
                DietaryViolationDetails(violations: result.violations)
            }
        }
    }
    
    private var violatedPreferences: String {
        result.violations.map { $0.preference.rawValue }.joined(separator: ", ")
    }
}

// MARK: - Dietary Violation Details

struct DietaryViolationDetails: View {
    @Environment(\.dismiss) private var dismiss
    let violations: [DietaryViolation]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(violations, id: \.preference) { violation in
                    Section(header: Text(violation.preference.rawValue)) {
                        ForEach(violation.violatingIngredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                                Text(ingredient)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dietary Violations")
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

#Preview {
    VStack {
        AllergenWarningView(
            warning: AllergenWarning(
                allergens: [
                    AllergenInfo(allergen: .peanuts, ingredientSource: "peanut butter", confidence: .certain),
                    AllergenInfo(allergen: .milk, ingredientSource: "whey protein", confidence: .likely)
                ],
                severity: .moderate,
                message: "This food contains allergens you've marked. Please review before consuming."
            ),
            isPresented: .constant(true),
            onProceed: {},
            onCancel: {}
        )
    }
}