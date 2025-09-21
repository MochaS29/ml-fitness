import SwiftUI
import Charts

// MARK: - Nutrient Intake Status
enum NutrientIntakeStatus {
    case deficient
    case low
    case optimal
    case high
    case excessive
}

struct EnhancedSupplementTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var selectedTab = 0
    @State private var showingPresetSupplements = false
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.startOfDay(for: Date()) as NSDate),
        animation: .default)
    private var todaysSupplements: FetchedResults<SupplementEntry>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Progress").tag(0)
                    Text("Supplements").tag(1)
                    Text("Analysis").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                switch selectedTab {
                case 0:
                    NutrientProgressView(supplements: Array(todaysSupplements))
                case 1:
                    SupplementListView(
                        showingScanner: $showingScanner,
                        showingManualEntry: $showingManualEntry,
                        showingPresetSupplements: $showingPresetSupplements
                    )
                case 2:
                    NutrientAnalysisView(supplements: Array(todaysSupplements))
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Supplement Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingScanner = true }) {
                            Label("Scan Label", systemImage: "camera.viewfinder")
                        }
                        
                        Button(action: { showingManualEntry = true }) {
                            Label("Manual Entry", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showingPresetSupplements = true }) {
                            Label("Common Supplements", systemImage: "pills")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView(scannedImage: .constant(nil))
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualSupplementEntryView()
            }
            .sheet(isPresented: $showingPresetSupplements) {
                PresetSupplementsView()
            }
        }
    }
}

// MARK: - Nutrient Progress View
struct NutrientProgressView: View {
    let supplements: [SupplementEntry]
    @EnvironmentObject var profileManager: UserProfileManager
    
    var nutrientTotals: [String: Double] {
        var totals: [String: Double] = [:]
        
        for supplement in supplements {
            if let nutrients = supplement.nutrients {
                for (nutrientId, amount) in nutrients {
                    totals[nutrientId, default: 0] += amount
                }
            }
        }
        
        return totals
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Overview")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(supplements.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Supplements")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(nutrientTotals.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Nutrients Tracked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Nutrient Progress Bars
                VStack(alignment: .leading, spacing: 15) {
                    Text("Nutrient Progress")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(sortedNutrientProgress(), id: \.nutrientId) { progress in
                        NutrientProgressBar(progress: progress)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    func sortedNutrientProgress() -> [NutrientProgress] {
        guard let profile = profileManager.currentProfile else { return [] }
        
        let allNutrients = RDADatabase.shared.getAllNutrients()
        var progressList: [NutrientProgress] = []
        
        for nutrient in allNutrients {
            let consumed = nutrientTotals[nutrient.nutrientId] ?? 0
            if let rda = RDADatabase.shared.getRDA(for: nutrient.nutrientId, profile: profile) {
                let percentage = (consumed / rda.amount) * 100
                progressList.append(NutrientProgress(
                    nutrientId: nutrient.nutrientId,
                    name: nutrient.name,
                    consumed: consumed,
                    rda: rda.amount,
                    unit: rda.unit,
                    percentage: min(percentage, 150), // Cap at 150% for display
                    upperLimit: rda.upperLimit
                ))
            }
        }
        
        // Sort by percentage consumed (highest first)
        return progressList.sorted { $0.percentage > $1.percentage }
    }
}

struct NutrientProgress: Identifiable {
    let nutrientId: String
    let name: String
    let consumed: Double
    let rda: Double
    let unit: NutrientUnit
    let percentage: Double
    let upperLimit: Double?
    
    var id: String { nutrientId }
    
    var status: NutrientStatus {
        if percentage < 50 {
            return .deficient(severity: .moderate)
        } else if percentage < 90 {
            return .deficient(severity: .mild)
        } else if let limit = upperLimit, consumed > limit * 1.5 {
            return .potentiallyHarmful
        } else if let limit = upperLimit, consumed > limit {
            return .excessive(concern: .slightlyHigh)
        } else {
            return .adequate
        }
    }
}

struct NutrientProgressBar: View {
    let progress: NutrientProgress
    
    var progressColor: Color {
        switch progress.status {
        case .deficient: return .red
        case .adequate: return .green
        case .excessive: return .orange
        case .potentiallyHarmful: return .purple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progress.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(progress.consumed))\(progress.unit.symbol) / \(Int(progress.rda))\(progress.unit.symbol)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: min(geometry.size.width * (progress.percentage / 100), geometry.size.width), height: 8)
                    
                    // Upper limit marker if applicable
                    if let upperLimit = progress.upperLimit {
                        let upperLimitPosition = geometry.size.width * (upperLimit / progress.rda / 1.5)
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 2, height: 12)
                            .position(x: min(upperLimitPosition, geometry.size.width - 1), y: 6)
                    }
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(Int(progress.percentage))% of RDA")
                    .font(.caption2)
                    .foregroundColor(progressColor)
                
                if case .excessive = progress.status {
                    Text("• Exceeds safe upper limit")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Preset Supplements View
struct PresetSupplementsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let presetSupplements = [
        PresetSupplement(
            name: "Complete Multivitamin",
            brand: "Daily Essentials",
            nutrients: [
                "vitamin_a": 900,    // mcg
                "vitamin_c": 90,     // mg
                "vitamin_d": 600,    // IU
                "vitamin_e": 15,     // mg
                "vitamin_k": 120,    // mcg
                "thiamin": 1.2,      // mg
                "riboflavin": 1.3,   // mg
                "niacin": 16,        // mg
                "vitamin_b6": 1.3,   // mg
                "folate": 400,       // mcg
                "vitamin_b12": 2.4,  // mcg
                "biotin": 30,        // mcg
                "pantothenic_acid": 5, // mg
                "calcium": 200,      // mg
                "iron": 8,           // mg
                "phosphorus": 100,   // mg
                "iodine": 150,       // mcg
                "magnesium": 100,    // mg
                "zinc": 11,          // mg
                "selenium": 55,      // mcg
                "copper": 0.9,       // mg
                "manganese": 2.3,    // mg
                "chromium": 35,      // mcg
                "molybdenum": 45     // mcg
            ]
        ),
        PresetSupplement(
            name: "Omega-3 Fish Oil",
            brand: "Ocean Health",
            nutrients: [
                "omega_3": 1000     // mg (EPA + DHA)
            ]
        ),
        PresetSupplement(
            name: "Basic Collagen",
            brand: "Beauty Boost",
            nutrients: [
                "collagen": 10000   // mg (10g)
            ]
        ),
        PresetSupplement(
            name: "Enhanced Collagen Complex",
            brand: "Premium Beauty",
            nutrients: [
                "collagen": 10000,  // mg
                "vitamin_c": 100,   // mg
                "biotin": 2500,     // mcg
                "zinc": 5           // mg
            ]
        ),
        PresetSupplement(
            name: "Magnesium Glycinate",
            brand: "Sleep Support",
            nutrients: [
                "magnesium": 400    // mg
            ]
        ),
        PresetSupplement(
            name: "Probiotic Complex",
            brand: "Gut Health",
            nutrients: [:] // Probiotics don't have RDA values
        )
    ]
    
    var body: some View {
        NavigationView {
            List(presetSupplements) { supplement in
                VStack(alignment: .leading, spacing: 8) {
                    Text(supplement.name)
                        .font(.headline)
                    
                    if !supplement.brand.isEmpty {
                        Text(supplement.brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !supplement.nutrients.isEmpty {
                        Text("\(supplement.nutrients.count) nutrients")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    addPresetSupplement(supplement)
                }
            }
            .navigationTitle("Common Supplements")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func addPresetSupplement(_ preset: PresetSupplement) {
        let newSupplement = SupplementEntry(context: viewContext)
        newSupplement.id = UUID()
        newSupplement.name = preset.name
        newSupplement.brand = preset.brand.isEmpty ? nil : preset.brand
        newSupplement.servingSize = "1"
        newSupplement.servingUnit = "serving"
        newSupplement.timestamp = Date()
        newSupplement.date = Date()

        // Set nutrients dictionary directly - Core Data will handle the transformation
        if !preset.nutrients.isEmpty {
            newSupplement.nutrients = preset.nutrients
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving preset supplement: \(error.localizedDescription)")
            // Show detailed error info for debugging
            if let nsError = error as NSError? {
                print("Core Data Error Code: \(nsError.code)")
                print("Core Data Error Domain: \(nsError.domain)")
                print("Core Data Error Info: \(nsError.userInfo)")
            }
        }
    }
}

struct PresetSupplement: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let nutrients: [String: Double]
}

// MARK: - Nutrient Analysis View
struct NutrientAnalysisView: View {
    let supplements: [SupplementEntry]
    @EnvironmentObject var profileManager: UserProfileManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let profile = profileManager.currentProfile {
                    // Profile summary
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Analysis for \(profile.name)")
                            .font(.headline)
                        Text("\(profile.gender.rawValue.capitalized), \(profile.age) years")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Recommendations
                    RecommendationsView(supplements: supplements, profile: profile)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct RecommendationsView: View {
    let supplements: [SupplementEntry]
    let profile: UserProfile
    
    var analyses: [NutrientAnalysis] {
        let calculator = RDACalculator()
        var intakes: [NutrientIntake] = []
        
        for supplement in supplements {
            if let nutrients = supplement.nutrients {
                for (nutrientId, amount) in nutrients {
                    // Determine unit based on nutrient
                    let unit: NutrientUnit = {
                        switch nutrientId {
                        case "vitamin_a", "vitamin_k", "folate", "vitamin_b12", "biotin", "iodine", "selenium", "chromium", "molybdenum":
                            return .mcg
                        case "vitamin_d":
                            return .iu
                        default:
                            return .mg
                        }
                    }()
                    
                    intakes.append(NutrientIntake(nutrientId: nutrientId, amount: amount, unit: unit))
                }
            }
        }
        
        return calculator.analyzeIntake(intakes, for: profile)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recommendations")
                .font(.headline)
            
            if analyses.isEmpty {
                Text("No nutrients tracked today")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(analyses.filter { $0.recommendation != nil }, id: \.nutrientId) { analysis in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(analysis.nutrientName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(analysis.status.symbol)
                        }
                        
                        if let recommendation = analysis.recommendation {
                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                    .background(backgroundColorForStatus(analysis.status))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    func backgroundColorForStatus(_ status: NutrientStatus) -> Color {
        switch status {
        case .deficient, .potentiallyHarmful:
            return Color.red.opacity(0.1)
        case .excessive:
            return Color.orange.opacity(0.1)
        case .adequate:
            return Color.green.opacity(0.1)
        }
    }
}

// MARK: - Supplement List View
struct SupplementListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showingScanner: Bool
    @Binding var showingManualEntry: Bool
    @Binding var showingPresetSupplements: Bool
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        animation: .default)
    private var supplements: FetchedResults<SupplementEntry>
    
    var todaysSupplements: [SupplementEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return supplements.filter { supplement in
            guard let timestamp = supplement.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    var previousSupplements: [SupplementEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return supplements.filter { supplement in
            guard let timestamp = supplement.timestamp else { return false }
            return !calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    var body: some View {
        List {
            if todaysSupplements.isEmpty && previousSupplements.isEmpty {
                EmptySupplementsPrompt(
                    showingScanner: $showingScanner,
                    showingManualEntry: $showingManualEntry,
                    showingPresetSupplements: $showingPresetSupplements
                )
            } else {
                if !todaysSupplements.isEmpty {
                    Section("Today") {
                        ForEach(todaysSupplements) { supplement in
                            EnhancedSupplementRow(supplement: supplement)
                        }
                        .onDelete { offsets in
                            deleteSupplements(from: todaysSupplements, at: offsets)
                        }
                    }
                }
                
                if !previousSupplements.isEmpty {
                    Section("Previous Days") {
                        ForEach(previousSupplements) { supplement in
                            EnhancedSupplementRow(supplement: supplement)
                        }
                        .onDelete { offsets in
                            deleteSupplements(from: previousSupplements, at: offsets)
                        }
                    }
                }
            }
        }
    }
    
    func deleteSupplements(from array: [SupplementEntry], at offsets: IndexSet) {
        withAnimation {
            offsets.map { array[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct EmptySupplementsPrompt: View {
    @Binding var showingScanner: Bool
    @Binding var showingManualEntry: Bool
    @Binding var showingPresetSupplements: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "pills")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No supplements tracked")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(spacing: 12) {
                Button(action: { showingPresetSupplements = true }) {
                    Label("Choose from Common Supplements", systemImage: "list.bullet")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { showingScanner = true }) {
                    Label("Scan Supplement Label", systemImage: "camera")
                }
                .buttonStyle(.bordered)
                
                Button(action: { showingManualEntry = true }) {
                    Label("Manual Entry", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EnhancedSupplementRow: View {
    let supplement: SupplementEntry
    
    var nutrientSummary: String {
        guard let nutrients = supplement.nutrients, !nutrients.isEmpty else {
            return "No nutrients tracked"
        }
        
        let count = nutrients.count
        if count <= 3 {
            return nutrients.keys.map { key in
                RDADatabase.shared.getAllNutrients().first { $0.nutrientId == key }?.name ?? key
            }.joined(separator: ", ")
        } else {
            return "\(count) nutrients"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(supplement.name ?? "Unknown Supplement")
                    .font(.headline)
                
                Spacer()
                
                if let timestamp = supplement.timestamp {
                    Text(timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let brand = supplement.brand {
                Text(brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(nutrientSummary)
                .font(.caption)
                .foregroundColor(.blue)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

// #Preview {
//     EnhancedSupplementTrackingView()
//         .environmentObject(UserProfileManager())
// }