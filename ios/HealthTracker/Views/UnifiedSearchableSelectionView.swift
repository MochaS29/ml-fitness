import SwiftUI

// MARK: - Generic Searchable Selection View
struct SearchableSelectionView<Item: Identifiable>: View where Item: Searchable {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedItem: Item?

    let title: String
    let items: [Item]
    let recentItems: [Item]
    let favoriteItems: [Item]
    let onSelect: (Item) -> Void
    let onCreateNew: ((String) -> Void)?

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.searchableText.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search \(title.lowercased())...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Content
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Create New Option
                        if !searchText.isEmpty && onCreateNew != nil {
                            Button(action: {
                                onCreateNew?(searchText)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Create \"\(searchText)\"")
                                            .foregroundColor(.primary)
                                        Text("Add as custom \(title.lowercased())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemBackground))
                            }

                            Divider()
                        }

                        // Favorites Section
                        if !favoriteItems.isEmpty && searchText.isEmpty {
                            SectionHeader(title: "Favorites")

                            ForEach(favoriteItems.filter { item in
                                searchText.isEmpty || item.searchableText.localizedCaseInsensitiveContains(searchText)
                            }) { item in
                                ItemRow(item: item, showFavorite: true) {
                                    onSelect(item)
                                    dismiss()
                                }
                            }

                            Divider().padding(.vertical, 8)
                        }

                        // Recent Section
                        if !recentItems.isEmpty && searchText.isEmpty {
                            SectionHeader(title: "Recent")

                            ForEach(recentItems.prefix(5)) { item in
                                ItemRow(item: item, showFavorite: false) {
                                    onSelect(item)
                                    dismiss()
                                }
                            }

                            Divider().padding(.vertical, 8)
                        }

                        // All Items / Search Results
                        SectionHeader(title: searchText.isEmpty ? "All \(title)" : "Search Results")

                        if filteredItems.isEmpty {
                            EmptySearchView(searchText: searchText, itemType: title)
                        } else {
                            ForEach(filteredItems) { item in
                                ItemRow(item: item, showFavorite: false) {
                                    onSelect(item)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Select \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
}

private struct ItemRow<Item: Identifiable & Searchable>: View {
    let item: Item
    let showFavorite: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayName)
                        .foregroundColor(.primary)

                    if let subtitle = item.displaySubtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if showFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)

        Divider()
            .padding(.leading)
    }
}

private struct EmptySearchView: View {
    let searchText: String
    let itemType: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No \(itemType.lowercased()) found")
                .font(.headline)

            Text("No results for \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Protocols
protocol Searchable {
    var searchableText: String { get }
    var displayName: String { get }
    var displaySubtitle: String? { get }
}

// MARK: - Supplement Selection
struct SupplementSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = SupplementSelectionViewModel()

    let onSelect: (Supplement) -> Void
    let onCreateNew: ((String) -> Void)?

    var body: some View {
        SearchableSelectionView(
            title: "Supplement",
            items: viewModel.allSupplements,
            recentItems: viewModel.recentSupplements,
            favoriteItems: viewModel.favoriteSupplements,
            onSelect: onSelect,
            onCreateNew: onCreateNew
        )
        .onAppear {
            viewModel.loadSupplements()
        }
    }
}

// Make Supplement conform to Searchable
extension Supplement: Searchable {
    var searchableText: String {
        "\(brand) \(name) \(category)"
    }

    var displayName: String {
        name
    }

    var displaySubtitle: String? {
        "\(brand) • \(servingSize)"
    }
}

// MARK: - Food Selection
struct FoodSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = FoodSelectionViewModel()

    let mealType: MealType
    let onSelect: (FoodItemModel) -> Void
    let onCreateNew: ((String) -> Void)?

    var body: some View {
        SearchableSelectionView(
            title: "Food",
            items: viewModel.allFoods,
            recentItems: viewModel.recentFoods,
            favoriteItems: viewModel.favoriteFoods,
            onSelect: onSelect,
            onCreateNew: onCreateNew
        )
        .onAppear {
            viewModel.loadFoods(for: mealType)
        }
    }
}

// Food conformance
struct FoodItemModel: Identifiable, Searchable {
    let id: String
    let name: String
    let brand: String?
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: String
    let barcode: String?

    var searchableText: String {
        "\(name) \(brand ?? "")"
    }

    var displayName: String {
        name
    }

    var displaySubtitle: String? {
        if let brand = brand, !brand.isEmpty {
            return "\(brand) • \(Int(calories)) cal • \(servingSize)"
        }
        return "\(Int(calories)) cal • \(servingSize)"
    }
}

// MARK: - Exercise Selection
struct ExerciseSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ExerciseSelectionViewModel()

    let onSelect: (ExerciseTemplate) -> Void
    let onCreateNew: ((String) -> Void)?

    var body: some View {
        SearchableSelectionView(
            title: "Exercise",
            items: viewModel.allExercises,
            recentItems: viewModel.recentExercises,
            favoriteItems: viewModel.favoriteExercises,
            onSelect: onSelect,
            onCreateNew: onCreateNew
        )
        .onAppear {
            viewModel.loadExercises()
        }
    }
}

// Exercise conformance
struct ExerciseTemplate: Identifiable, Searchable {
    let id: String
    let name: String
    let category: String
    let caloriesPerMinute: Double
    let defaultDuration: Int
    let metValue: Double

    var searchableText: String {
        "\(name) \(category)"
    }

    var displayName: String {
        name
    }

    var displaySubtitle: String? {
        "\(category) • ~\(Int(caloriesPerMinute * Double(defaultDuration))) cal for \(defaultDuration) min"
    }
}

// MARK: - View Models
class SupplementSelectionViewModel: ObservableObject {
    @Published var allSupplements: [Supplement] = []
    @Published var recentSupplements: [Supplement] = []
    @Published var favoriteSupplements: [Supplement] = []

    func loadSupplements() {
        // Load from SupplementDatabase
        let database = SupplementDatabase.shared

        // Get all supplements
        allSupplements = database.mensMultivitamins +
                        database.womensMultivitamins +
                        database.popularSupplements

        // Get user's recent supplements (would come from Core Data)
        recentSupplements = Array(allSupplements.filter {
            ["one-a-day-womens-personal", "superbelly-probiotic", "magnesium-citrate-personal"].contains($0.id)
        })

        // Get favorites (would come from UserDefaults or Core Data)
        favoriteSupplements = Array(allSupplements.filter {
            ["one-a-day-womens-personal", "estrosmart"].contains($0.id)
        })
    }
}

class FoodSelectionViewModel: ObservableObject {
    @Published var allFoods: [FoodItemModel] = []
    @Published var recentFoods: [FoodItemModel] = []
    @Published var favoriteFoods: [FoodItemModel] = []

    func loadFoods(for mealType: MealType) {
        // This would load from FoodDatabase and Core Data
        // For now, using sample data
        allFoods = [
            FoodItemModel(id: "1", name: "Apple", brand: nil, calories: 95, protein: 0.5, carbs: 25, fat: 0.3, servingSize: "1 medium", barcode: nil),
            FoodItemModel(id: "2", name: "Greek Yogurt", brand: "Chobani", calories: 100, protein: 18, carbs: 6, fat: 0, servingSize: "1 cup", barcode: "818290014122"),
            FoodItemModel(id: "3", name: "Chicken Breast", brand: nil, calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: "100g", barcode: nil),
            FoodItemModel(id: "4", name: "Brown Rice", brand: nil, calories: 216, protein: 5, carbs: 45, fat: 1.8, servingSize: "1 cup cooked", barcode: nil),
            FoodItemModel(id: "5", name: "Protein Bar", brand: "Quest", calories: 200, protein: 20, carbs: 21, fat: 9, servingSize: "1 bar", barcode: "888849008506")
        ]

        recentFoods = Array(allFoods.prefix(3))
        favoriteFoods = [allFoods[1], allFoods[2]]
    }
}

class ExerciseSelectionViewModel: ObservableObject {
    @Published var allExercises: [ExerciseTemplate] = []
    @Published var recentExercises: [ExerciseTemplate] = []
    @Published var favoriteExercises: [ExerciseTemplate] = []

    func loadExercises() {
        // Load from ExerciseDatabase
        allExercises = [
            ExerciseTemplate(id: "1", name: "Running", category: "Cardio", caloriesPerMinute: 10, defaultDuration: 30, metValue: 8.0),
            ExerciseTemplate(id: "2", name: "Walking", category: "Cardio", caloriesPerMinute: 4, defaultDuration: 30, metValue: 3.5),
            ExerciseTemplate(id: "3", name: "Cycling", category: "Cardio", caloriesPerMinute: 8, defaultDuration: 30, metValue: 6.0),
            ExerciseTemplate(id: "4", name: "Swimming", category: "Cardio", caloriesPerMinute: 11, defaultDuration: 30, metValue: 8.0),
            ExerciseTemplate(id: "5", name: "Weight Training", category: "Strength", caloriesPerMinute: 6, defaultDuration: 45, metValue: 5.0),
            ExerciseTemplate(id: "6", name: "Yoga", category: "Flexibility", caloriesPerMinute: 3, defaultDuration: 60, metValue: 2.5),
            ExerciseTemplate(id: "7", name: "Pilates", category: "Strength", caloriesPerMinute: 4, defaultDuration: 45, metValue: 3.0),
            ExerciseTemplate(id: "8", name: "HIIT", category: "Cardio", caloriesPerMinute: 12, defaultDuration: 20, metValue: 8.5)
        ]

        recentExercises = Array(allExercises.prefix(3))
        favoriteExercises = [allExercises[0], allExercises[4]]
    }
}

// MealType is already defined in Models/Types.swift