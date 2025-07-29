import SwiftUI
import Charts

struct EnhancedMacroTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = EnhancedMacroTrackingViewModel()
    @State private var selectedTab = 0
    @State private var showingFoodEntry = false
    @State private var showingSupplementEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Vitamins").tag(1)
                    Text("Minerals").tag(2)
                    Text("Details").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    switch selectedTab {
                    case 0:
                        overviewTab
                    case 1:
                        vitaminsTab
                    case 2:
                        mineralsTab
                    case 3:
                        detailsTab
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Nutrition Tracking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingFoodEntry = true }) {
                            Label("Add Food", systemImage: "fork.knife")
                        }
                        
                        Button(action: { showingSupplementEntry = true }) {
                            Label("Add Supplement", systemImage: "pills")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFoodEntry) {
                FoodTrackingView()
            }
            .sheet(isPresented: $showingSupplementEntry) {
                ManualSupplementEntryView()
            }
            .onAppear {
                viewModel.loadData(context: viewContext)
            }
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 20) {
            // Macro Summary Card
            VStack(spacing: 15) {
                Text("Today's Macros")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    MacroCircle(
                        title: "Protein",
                        value: viewModel.totalProtein,
                        goal: viewModel.proteinGoal,
                        color: .blue
                    )
                    
                    MacroCircle(
                        title: "Carbs",
                        value: viewModel.totalCarbs,
                        goal: viewModel.carbsGoal,
                        color: .green
                    )
                    
                    MacroCircle(
                        title: "Fats",
                        value: viewModel.totalFat,
                        goal: viewModel.fatGoal,
                        color: .orange
                    )
                }
                
                // Calorie Summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(Int(viewModel.totalCalories)) / \(viewModel.calorieGoal)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    ProgressView(value: viewModel.totalCalories, total: Double(viewModel.calorieGoal))
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 150)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            // Micronutrient Summary
            VStack(alignment: .leading, spacing: 10) {
                Text("Key Micronutrients")
                    .font(.headline)
                
                ForEach(viewModel.topMicronutrients, id: \.name) { nutrient in
                    HStack {
                        Text(nutrient.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(nutrient.percentage)% RDA")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(colorForPercentage(nutrient.percentage))
                        
                        ProgressView(value: Double(nutrient.percentage), total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 80)
                    }
                }
                
                if viewModel.supplementContribution > 0 {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.purple)
                        Text("Supplements contributing \(Int(viewModel.supplementContribution))% of micronutrients")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 5)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Vitamins Tab
    private var vitaminsTab: some View {
        VStack(spacing: 15) {
            ForEach(viewModel.vitaminProgress, id: \.name) { vitamin in
                NutrientProgressCard(
                    nutrient: vitamin,
                    showSources: true
                )
            }
        }
        .padding()
    }
    
    // MARK: - Minerals Tab
    private var mineralsTab: some View {
        VStack(spacing: 15) {
            ForEach(viewModel.mineralProgress, id: \.name) { mineral in
                NutrientProgressCard(
                    nutrient: mineral,
                    showSources: true
                )
            }
        }
        .padding()
    }
    
    // MARK: - Details Tab
    private var detailsTab: some View {
        VStack(spacing: 20) {
            // Food Sources
            VStack(alignment: .leading, spacing: 10) {
                Text("Food Sources")
                    .font(.headline)
                
                ForEach(viewModel.foodSources, id: \.name) { food in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .font(.subheadline)
                            Text("\(Int(food.calories)) cal • P: \(Int(food.protein))g • C: \(Int(food.carbs))g • F: \(Int(food.fat))g")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(food.time, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            // Supplement Sources
            if !viewModel.supplementSources.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Supplement Sources")
                        .font(.headline)
                    
                    ForEach(viewModel.supplementSources, id: \.name) { supplement in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(supplement.name)
                                    .font(.subheadline)
                                Text("\(supplement.nutrientCount) nutrients")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "pills.fill")
                                .foregroundColor(.purple)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    func colorForPercentage(_ percentage: Int) -> Color {
        if percentage < 50 {
            return .red
        } else if percentage < 90 {
            return .orange
        } else if percentage <= 110 {
            return .green
        } else {
            return .blue
        }
    }
}

// MARK: - Supporting Views

struct MacroCircle: View {
    let title: String
    let value: Double
    let goal: Double
    let color: Color
    
    var percentage: Double {
        guard goal > 0 else { return 0 }
        return (value / goal) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: min(percentage / 100, 1))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(Int(value))g")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(Int(percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct NutrientProgressCard: View {
    let nutrient: NutrientProgressData
    let showSources: Bool
    
    var progressColor: Color {
        if nutrient.percentage < 50 {
            return .red
        } else if nutrient.percentage < 90 {
            return .orange
        } else if nutrient.percentage <= 110 {
            return .green
        } else if nutrient.percentage > 150 && nutrient.hasUpperLimit {
            return .purple
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(nutrient.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(nutrient.percentage)% RDA")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(
                            width: min(geometry.size.width * (Double(nutrient.percentage) / 100), geometry.size.width),
                            height: 10
                        )
                    
                    // Upper limit marker
                    if nutrient.hasUpperLimit && nutrient.upperLimitPercentage > 0 {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 2, height: 14)
                            .position(
                                x: min(geometry.size.width * (Double(nutrient.upperLimitPercentage) / 150), geometry.size.width - 1),
                                y: 7
                            )
                    }
                }
            }
            .frame(height: 10)
            
            // Amount and sources
            HStack {
                Text("\(nutrient.amount, specifier: "%.1f")\(nutrient.unit) / \(nutrient.rda, specifier: "%.1f")\(nutrient.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if showSources && !nutrient.sources.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(nutrient.sources, id: \.self) { source in
                            Image(systemName: source == "supplement" ? "pills.fill" : "fork.knife")
                                .font(.caption2)
                                .foregroundColor(source == "supplement" ? .purple : .green)
                        }
                    }
                }
            }
            
            if nutrient.hasUpperLimit && nutrient.percentage > nutrient.upperLimitPercentage {
                Text("⚠️ Exceeds safe upper limit")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - View Model

class EnhancedMacroTrackingViewModel: ObservableObject {
    @Published var totalCalories: Double = 0
    @Published var totalProtein: Double = 0
    @Published var totalCarbs: Double = 0
    @Published var totalFat: Double = 0
    
    @Published var calorieGoal = 2000
    @Published var proteinGoal = 150.0
    @Published var carbsGoal = 225.0
    @Published var fatGoal = 65.0
    
    @Published var topMicronutrients: [(name: String, percentage: Int)] = []
    @Published var vitaminProgress: [NutrientProgressData] = []
    @Published var mineralProgress: [NutrientProgressData] = []
    @Published var foodSources: [(name: String, calories: Double, protein: Double, carbs: Double, fat: Double, time: Date)] = []
    @Published var supplementSources: [(name: String, nutrientCount: Int)] = []
    @Published var supplementContribution: Double = 0
    
    func loadData(context: NSManagedObjectContext) {
        // Fetch today's food entries
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        foodRequest.predicate = NSPredicate(format: "timestamp >= %@", startOfDay as NSDate)
        
        // Fetch today's supplements
        let supplements = PersistenceController.shared.fetchTodaysSupplements(context: context)
        
        do {
            let foodEntries = try context.fetch(foodRequest)
            
            // Calculate food nutrition
            var foodNutrition = NutritionInfo()
            foodSources = []
            
            for entry in foodEntries {
                if let nutrition = entry.nutrition {
                    foodNutrition = foodNutrition + nutrition
                    foodSources.append((
                        name: entry.name ?? "Unknown",
                        calories: nutrition.calories,
                        protein: nutrition.protein,
                        carbs: nutrition.carbs,
                        fat: nutrition.fat,
                        time: entry.timestamp ?? Date()
                    ))
                }
            }
            
            // Calculate supplement nutrition
            let supplementNutrition = NutritionInfo.fromSupplements(supplements)
            supplementSources = supplements.map { supplement in
                (name: supplement.name ?? "Unknown",
                 nutrientCount: supplement.nutrients?.count ?? 0)
            }
            
            // Combine food and supplement nutrition
            let totalNutrition = foodNutrition.combined(with: supplementNutrition)
            
            // Update macros
            totalCalories = totalNutrition.calories
            totalProtein = totalNutrition.protein
            totalCarbs = totalNutrition.carbs
            totalFat = totalNutrition.fat
            
            // Calculate micronutrient progress
            calculateMicronutrientProgress(foodNutrition: foodNutrition, supplementNutrition: supplementNutrition)
            
        } catch {
            print("Error loading nutrition data: \(error)")
        }
    }
    
    private func calculateMicronutrientProgress(foodNutrition: NutritionInfo, supplementNutrition: NutritionInfo) {
        // This would calculate progress for all vitamins and minerals
        // For now, showing a simplified version
        
        topMicronutrients = [
            (name: "Vitamin C", percentage: calculatePercentage(foodNutrition.vitaminC, supplementNutrition.vitaminC, rda: 90)),
            (name: "Iron", percentage: calculatePercentage(foodNutrition.iron, supplementNutrition.iron, rda: 8)),
            (name: "Calcium", percentage: calculatePercentage(foodNutrition.calcium, supplementNutrition.calcium, rda: 1000)),
            (name: "Vitamin D", percentage: calculatePercentage(foodNutrition.vitaminD, supplementNutrition.vitaminD, rda: 600))
        ]
        
        // Calculate supplement contribution
        let totalMicronutrients = (supplementNutrition.vitaminC ?? 0) + (supplementNutrition.iron ?? 0) +
                                 (supplementNutrition.calcium ?? 0) + (supplementNutrition.vitaminD ?? 0)
        let foodMicronutrients = (foodNutrition.vitaminC ?? 0) + (foodNutrition.iron ?? 0) +
                                (foodNutrition.calcium ?? 0) + (foodNutrition.vitaminD ?? 0)
        
        if totalMicronutrients + foodMicronutrients > 0 {
            supplementContribution = (totalMicronutrients / (totalMicronutrients + foodMicronutrients)) * 100
        }
    }
    
    private func calculatePercentage(_ foodAmount: Double?, _ supplementAmount: Double?, rda: Double) -> Int {
        let total = (foodAmount ?? 0) + (supplementAmount ?? 0)
        return Int((total / rda) * 100)
    }
}

struct NutrientProgressData {
    let name: String
    let amount: Double
    let rda: Double
    let unit: String
    let percentage: Int
    let sources: [String]
    let hasUpperLimit: Bool
    let upperLimitPercentage: Int
}