import SwiftUI
import CoreData

struct CopyFromPreviousDayView: View {
    let targetDate: Date
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = UnifiedDataManager.shared

    @State private var sourceDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var selectedMeals: Set<MealType> = []
    @State private var copySupplements = false
    @State private var showingConfirmation = false
    @State private var copiedCount = 0

    @State private var sourceFoodsByMeal: [MealType: [FoodEntry]] = [:]
    @State private var sourceSupplements: [SupplementEntry] = []

    private var availableMealTypes: [MealType] {
        MealType.allCases.filter { !(sourceFoodsByMeal[$0]?.isEmpty ?? true) }
    }

    private var totalSelectedCalories: Double {
        var total: Double = 0
        for meal in selectedMeals {
            total += (sourceFoodsByMeal[meal] ?? []).reduce(0) { $0 + $1.calories }
        }
        return total
    }

    private var totalSelectedItems: Int {
        var count = 0
        for meal in selectedMeals {
            count += sourceFoodsByMeal[meal]?.count ?? 0
        }
        if copySupplements {
            count += sourceSupplements.count
        }
        return count
    }

    private var targetDateHasEntries: Bool {
        let existingFood = dataManager.fetchFoodEntries(for: targetDate)
        let existingSupps = dataManager.fetchSupplementEntries(for: targetDate)
        return !existingFood.isEmpty || !existingSupps.isEmpty
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Copy From
                Section(header: Text("Copy From")) {
                    DatePicker("Source Date", selection: $sourceDate, in: ...Date(), displayedComponents: .date)

                    HStack(spacing: 12) {
                        quickDateButton("Yesterday", offset: -1)
                        quickDateButton("2 Days Ago", offset: -2)
                        quickDateButton("Last Week", offset: -7)
                    }
                }

                // MARK: - Copy To
                Section(header: Text("Copy To")) {
                    HStack {
                        Text("Target Date")
                        Spacer()
                        Text(dateFormatter.string(from: targetDate))
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Meals
                if !availableMealTypes.isEmpty {
                    Section(header: Text("Meals")) {
                        Toggle("Select All Meals", isOn: Binding(
                            get: { selectedMeals.count == availableMealTypes.count },
                            set: { selectAll in
                                if selectAll {
                                    selectedMeals = Set(availableMealTypes)
                                } else {
                                    selectedMeals.removeAll()
                                }
                            }
                        ))
                        .font(.subheadline.weight(.semibold))

                        ForEach(availableMealTypes, id: \.self) { mealType in
                            let foods = sourceFoodsByMeal[mealType] ?? []
                            let mealCals = Int(foods.reduce(0) { $0 + $1.calories })

                            DisclosureGroup {
                                ForEach(foods, id: \.objectID) { entry in
                                    HStack {
                                        Text(entry.name ?? "Unknown")
                                            .font(.caption)
                                        Spacer()
                                        Text("\(Int(entry.calories)) cal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } label: {
                                Toggle(isOn: Binding(
                                    get: { selectedMeals.contains(mealType) },
                                    set: { selected in
                                        if selected {
                                            selectedMeals.insert(mealType)
                                        } else {
                                            selectedMeals.remove(mealType)
                                        }
                                    }
                                )) {
                                    HStack {
                                        Text(mealType.rawValue)
                                        Spacer()
                                        Text("\(foods.count) items · \(mealCals) cal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: - Supplements
                if !sourceSupplements.isEmpty {
                    Section(header: Text("Supplements")) {
                        Toggle("Copy Supplements (\(sourceSupplements.count))", isOn: $copySupplements)

                        if copySupplements {
                            ForEach(sourceSupplements, id: \.objectID) { entry in
                                HStack {
                                    Text(entry.name ?? "Unknown")
                                        .font(.caption)
                                    Spacer()
                                    Text("\(entry.servingSize ?? "1") \(entry.servingUnit ?? "serving")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // MARK: - Empty State
                if availableMealTypes.isEmpty && sourceSupplements.isEmpty {
                    Section {
                        Text("No entries found for the selected date.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                // MARK: - Warning
                if targetDateHasEntries && totalSelectedItems > 0 {
                    Section {
                        Label("The target date already has entries. Copied items will be added alongside existing ones.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                // MARK: - Copy Button
                if totalSelectedItems > 0 {
                    Section {
                        Button(action: performCopy) {
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    Text("Copy \(totalSelectedItems) Items")
                                        .font(.headline)
                                    if totalSelectedCalories > 0 {
                                        Text("\(Int(totalSelectedCalories)) calories")
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .foregroundColor(.white)
                        .listRowBackground(Color(red: 139/255, green: 69/255, blue: 19/255))
                    }
                }
            }
            .navigationTitle("Copy Previous Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: sourceDate) {
                loadSourceData()
            }
            .onAppear {
                loadSourceData()
            }
            .alert("Items Copied", isPresented: $showingConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(copiedCount) items copied to \(dateFormatter.string(from: targetDate)).")
            }
        }
    }

    private func quickDateButton(_ label: String, offset: Int) -> some View {
        Button(label) {
            if let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
                sourceDate = date
            }
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(8)
    }

    private func loadSourceData() {
        selectedMeals.removeAll()
        copySupplements = false

        var foodsByMeal: [MealType: [FoodEntry]] = [:]
        for mealType in MealType.allCases {
            let entries = dataManager.fetchFoodEntries(for: sourceDate, mealType: mealType)
            if !entries.isEmpty {
                foodsByMeal[mealType] = entries
            }
        }
        sourceFoodsByMeal = foodsByMeal
        sourceSupplements = dataManager.fetchSupplementEntries(for: sourceDate)
    }

    private func performCopy() {
        var total = 0

        if !selectedMeals.isEmpty {
            total += dataManager.copyFoodEntries(from: sourceDate, to: targetDate, mealTypes: Array(selectedMeals))
        }

        if copySupplements {
            total += dataManager.copySupplementEntries(from: sourceDate, to: targetDate)
        }

        copiedCount = total
        showingConfirmation = true
    }
}
