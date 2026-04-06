import SwiftUI
import PhotosUI
import CoreData

struct ProfessionalRecipeDetailView: View {
    let recipe: RecipeModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var checkedIngredients: Set<UUID> = []
    @State private var showingShareSheet = false
    @State private var allergenWarning: AllergenWarning? = nil
    @State private var localImage: UIImage? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showingPhotoPicker = false
    @State private var showingMealPicker = false
    @State private var loggedSuccess = false

    private let tabTitles = ["Ingredients", "Steps", "Nutrition"]
    private let activeGreen = Color(red: 0.18, green: 0.65, blue: 0.35)

    var difficultyLevel: String {
        let total = recipe.prepTime + recipe.cookTime
        if total <= 20 { return "Easy" }
        if total <= 45 { return "Medium" }
        return "Hard"
    }

    var difficultyColor: Color {
        switch difficultyLevel {
        case "Easy":   return activeGreen
        case "Medium": return .orange
        default:       return .red
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 0) {
                        // Allergen warning
                        if let warning = allergenWarning {
                            AllergenWarningBanner(warning: warning)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        // Stats row
                        statsCard
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        // Macros row
                        if let nutrition = recipe.nutrition {
                            macrosCard(nutrition: nutrition)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                        }

                        // Tab bar
                        tabBarView
                            .padding(.top, 20)

                        // Tab content
                        if selectedTab == 0 {
                            ingredientsContent
                        } else if selectedTab == 1 {
                            stepsContent
                        } else {
                            nutritionContent
                        }

                        Spacer(minLength: 90)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }

            // Sticky Log This Meal button
            VStack(spacing: 0) {
                Divider()
                Button(action: { showingMealPicker = true }) {
                    HStack(spacing: 8) {
                        if loggedSuccess {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Added to Diary!")
                        } else {
                            Text("+ Log This Meal")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(loggedSuccess ? activeGreen : recipe.category.headerColor)
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .disabled(loggedSuccess)
            }
            .confirmationDialog("Add to Diary", isPresented: $showingMealPicker, titleVisibility: .visible) {
                Button("Breakfast") { logMeal(as: .breakfast) }
                Button("Lunch")     { logMeal(as: .lunch) }
                Button("Dinner")    { logMeal(as: .dinner) }
                Button("Snack")     { logMeal(as: .snack) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Which meal should \(recipe.name) be added to?")
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [recipe.name])
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, _ in
            Task {
                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    saveRecipePhoto(image)
                }
            }
        }
        .onAppear {
            checkAllergens()
            loadRecipePhoto()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Nav bar row
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Text(recipe.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: 200)
                Spacer()
                HStack(spacing: 10) {
                    FavoriteButton(recipe: recipe)
                        .colorScheme(.dark)
                    Menu {
                        Button(action: { showingShareSheet = true }) {
                            Label("Share Recipe", systemImage: "square.and.arrow.up")
                        }
                        Button(action: {
                            let text = "\(recipe.name)\n\nIngredients:\n" +
                                recipe.ingredients.map { "• \($0.name)" }.joined(separator: "\n")
                            UIPasteboard.general.string = text
                        }) {
                            Label("Copy Ingredients", systemImage: "doc.on.doc")
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)

            // Photo area
            if let image = localImage {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                    HStack(spacing: 8) {
                        // Replace photo
                        Button(action: { showingPhotoPicker = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.45))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }
                        // Remove photo
                        Button(action: { deleteRecipePhoto() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.45))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(10)
                }
            } else {
                Button(action: { showingPhotoPicker = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                        Text("Add a photo")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }

            // Category badge
            Text(recipe.category.rawValue.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))
                .kerning(1.5)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            // Recipe name
            Text(recipe.name)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)

            // Tag pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let displayTags = recipe.tags.filter { tag in
                        let lower = tag.lowercased()
                        return !["breakfast","lunch","dinner","snack","snacks","dessert",
                                 "appetizer","beverage","salad","soup","side dish"].contains(lower)
                    }
                    ForEach(displayTags.prefix(4), id: \.self) { tag in
                        tagPill(tag.capitalized)
                    }
                    tagPill("\(recipe.totalTime) min total")
                    if let kcal = recipe.nutrition {
                        tagPill("\(Int(kcal.calories)) cal")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .background(recipe.category.headerColor.ignoresSafeArea(edges: .top))
    }

    // MARK: - Stats Card (4 columns)

    private var statsCard: some View {
        HStack(spacing: 0) {
            statColumn(label: "PREP", value: "\(recipe.prepTime)m")
            cardDivider
            statColumn(label: "COOK", value: "\(recipe.cookTime)m")
            cardDivider
            statColumn(label: "SERVES", value: "\(recipe.servings)")
            cardDivider
            VStack(spacing: 4) {
                Text(difficultyLevel)
                    .font(.title3.weight(.bold))
                    .foregroundColor(difficultyColor)
                Text("LEVEL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(UIColor.separator))
            .frame(width: 1, height: 36)
    }

    // MARK: - Macros Card (colored underline bars)

    private func macrosCard(nutrition: NutritionInfo) -> some View {
        HStack(spacing: 0) {
            macroColumn(label: "Protein", value: "\(Int(nutrition.protein))g",
                        color: activeGreen)
            cardDivider
            macroColumn(label: "Carbs", value: "\(Int(nutrition.carbs))g",
                        color: .orange)
            cardDivider
            macroColumn(label: "Fat", value: "\(Int(nutrition.fat))g",
                        color: .red)
            if let fiber = nutrition.fiber {
                cardDivider
                macroColumn(label: "Fibre", value: "\(Int(fiber))g",
                            color: activeGreen)
            }
        }
        .padding(.vertical, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
    }

    private func macroColumn(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .cornerRadius(2)
                .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Bar

    private var tabBarView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                    Button(action: { selectedTab = index }) {
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.subheadline.weight(selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? activeGreen : .secondary)
                                .padding(.top, 12)
                            Rectangle()
                                .fill(selectedTab == index ? activeGreen : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)

            Divider()
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Ingredients Tab

    private var ingredientsContent: some View {
        let allOther = recipe.ingredients.allSatisfy { $0.category == .other }
        return VStack(alignment: .leading, spacing: 0) {
            if recipe.ingredients.isEmpty {
                Text("No ingredients listed.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            } else if allOther {
                // Flat list — meal plan recipes have no category breakdown
                VStack(spacing: 0) {
                    ForEach(Array(recipe.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        HStack(spacing: 8) {
                            Text(ingredient.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(ingredientAmountString(ingredient))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if index < recipe.ingredients.count - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(14)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            } else {
                // Grouped by grocery category
                let grouped = Dictionary(grouping: recipe.ingredients) { $0.category }
                let sortedKeys = grouped.keys.sorted { $0.rawValue < $1.rawValue }

                ForEach(sortedKeys, id: \.self) { category in
                    let items = grouped[category] ?? []
                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(category.rawValue.uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                                .kerning(1.2)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                            ForEach(Array(items.enumerated()), id: \.element.id) { index, ingredient in
                                HStack(spacing: 8) {
                                    Text(ingredient.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(ingredientAmountString(ingredient))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)

                                if index < items.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    private func ingredientAmountString(_ ingredient: IngredientModel) -> String {
        let amount = ingredient.amount
        let amountStr: String
        if amount == 0 { return "" }
        if amount == Double(Int(amount)) {
            amountStr = "\(Int(amount))"
        } else {
            amountStr = String(format: "%.1f", amount)
        }
        let unit = ingredient.unit.displayName(amount: amount)
        return unit.isEmpty ? amountStr : "\(amountStr) \(unit)"
    }

    // MARK: - Steps Tab

    private var stepsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if recipe.instructions.isEmpty {
                Text("No steps available.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(24)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(recipe.category.headerColor)
                                .frame(width: 32, height: 32)
                            Text("\(index + 1)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 2)

                        Text(step)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if index < recipe.instructions.count - 1 {
                        Divider().padding(.leading, 62)
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Nutrition Tab

    private var nutritionContent: some View {
        VStack {
            if let nutrition = recipe.nutrition {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    nutritionTiles(nutrition: nutrition)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            } else {
                Text("No nutrition data available.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
        }
    }

    @ViewBuilder
    private func nutritionTiles(nutrition: NutritionInfo) -> some View {
        nutritionTile(label: "Calories",      value: "\(Int(nutrition.calories))",   color: activeGreen)
        nutritionTile(label: "Protein",       value: "\(Int(nutrition.protein))g",   color: activeGreen)
        nutritionTile(label: "Carbohydrates", value: "\(Int(nutrition.carbs))g",     color: .orange)
        nutritionTile(label: "Fat",           value: "\(Int(nutrition.fat))g",       color: .red)
        if let fiber = nutrition.fiber {
            nutritionTile(label: "Fibre",  value: "\(Int(fiber))g",  color: activeGreen)
        }
        if let sugar = nutrition.sugar {
            nutritionTile(label: "Sugar",  value: "\(Int(sugar))g",  color: Color.purple)
        }
        if let sodium = nutrition.sodium {
            nutritionTile(label: "Sodium", value: "\(Int(sodium))mg", color: Color.gray)
        }
    }

    private func nutritionTile(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .cornerRadius(2)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func tagPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.18))
            .cornerRadius(20)
    }

    // MARK: - Photo persistence (Documents/recipe_photos/<uuid>.jpg)

    private var recipePhotoURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("recipe_photos", isDirectory: true)
            .appendingPathComponent("\(recipe.id.uuidString).jpg")
    }

    private func loadRecipePhoto() {
        guard let url = recipePhotoURL,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return }
        localImage = image
    }

    private func deleteRecipePhoto() {
        if let url = recipePhotoURL {
            try? FileManager.default.removeItem(at: url)
        }
        localImage = nil
    }

    private func saveRecipePhoto(_ image: UIImage) {
        guard let url = recipePhotoURL else { return }
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url, options: .atomic)
        }
        localImage = image
    }

    private func logMeal(as mealType: MealType) {
        let nutrition = recipe.nutrition
        UnifiedDataManager.shared.addFoodEntry(
            name: recipe.name,
            calories: nutrition?.calories ?? 0,
            protein: nutrition?.protein ?? 0,
            carbs: nutrition?.carbs ?? 0,
            fat: nutrition?.fat ?? 0,
            fiber: nutrition?.fiber ?? 0,
            sugar: nutrition?.sugar ?? 0,
            sodium: nutrition?.sodium ?? 0,
            servingSize: "\(recipe.servings)",
            servingUnit: "serving",
            mealType: mealType
        )
        withAnimation {
            loggedSuccess = true
        }
        // Reset button after 2.5 seconds so it can be logged again
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { loggedSuccess = false }
        }
    }

    private func checkAllergens() {
        guard let profile = UserProfileManager().currentProfile,
              !profile.foodPreferences.allergies.isEmpty else { return }
        let detected = AllergenDetectionService.shared.checkFoodForAllergens(
            recipe.name,
            ingredients: recipe.ingredients.map(\.name),
            userProfile: profile
        )
        allergenWarning = AllergenDetectionService.shared.generateAllergenWarning(allergens: detected)
    }
}

// MARK: - Recipe Category Visual Helpers

extension RecipeCategory {
    /// Deep, rich solid color used for the detail view header and CTA button
    var headerColor: Color {
        switch self {
        case .breakfast:  return Color(red: 0.58, green: 0.32, blue: 0.04)  // deep amber
        case .lunch:      return Color(red: 0.08, green: 0.36, blue: 0.26)  // forest teal
        case .dinner:     return Color(red: 0.16, green: 0.10, blue: 0.38)  // dark indigo
        case .snack:      return Color(red: 0.55, green: 0.20, blue: 0.10)  // dark terracotta
        case .dessert:    return Color(red: 0.48, green: 0.08, blue: 0.28)  // deep burgundy
        case .appetizer:  return Color(red: 0.05, green: 0.30, blue: 0.38)  // dark teal
        case .beverage:   return Color(red: 0.28, green: 0.14, blue: 0.05)  // espresso
        case .salad:      return Color(red: 0.10, green: 0.36, blue: 0.14)  // dark green
        case .soup:       return Color(red: 0.48, green: 0.18, blue: 0.04)  // dark rust
        case .sideDish:   return Color(red: 0.20, green: 0.35, blue: 0.10)  // olive
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .breakfast:  return [Color(red: 0.95, green: 0.55, blue: 0.12), Color(red: 0.98, green: 0.75, blue: 0.25)]
        case .lunch:      return [Color(red: 0.15, green: 0.62, blue: 0.48), Color(red: 0.32, green: 0.80, blue: 0.60)]
        case .dinner:     return [Color(red: 0.28, green: 0.18, blue: 0.55), Color(red: 0.48, green: 0.30, blue: 0.68)]
        case .snack:      return [Color(red: 0.90, green: 0.38, blue: 0.28), Color(red: 0.98, green: 0.60, blue: 0.38)]
        case .dessert:    return [Color(red: 0.82, green: 0.28, blue: 0.52), Color(red: 0.96, green: 0.52, blue: 0.68)]
        case .appetizer:  return [Color(red: 0.10, green: 0.52, blue: 0.65), Color(red: 0.25, green: 0.72, blue: 0.78)]
        case .beverage:   return [Color(red: 0.45, green: 0.30, blue: 0.18), Color(red: 0.68, green: 0.48, blue: 0.28)]
        case .salad:      return [Color(red: 0.22, green: 0.65, blue: 0.28), Color(red: 0.45, green: 0.82, blue: 0.35)]
        case .soup:       return [Color(red: 0.78, green: 0.32, blue: 0.08), Color(red: 0.92, green: 0.55, blue: 0.18)]
        case .sideDish:   return [Color(red: 0.28, green: 0.58, blue: 0.28), Color(red: 0.45, green: 0.75, blue: 0.38)]
        }
    }

    var placeholderIcon: String {
        switch self {
        case .breakfast:  return "cup.and.saucer.fill"
        case .lunch:      return "leaf.fill"
        case .dinner:     return "fork.knife"
        case .snack:      return "bag.fill"
        case .dessert:    return "birthday.cake.fill"
        case .appetizer:  return "fork.knife.circle.fill"
        case .beverage:   return "drop.fill"
        case .salad:      return "leaf.circle.fill"
        case .soup:       return "flame.fill"
        case .sideDish:   return "circle.grid.2x2.fill"
        }
    }
}

struct RecipeImagePlaceholder: View {
    var category: RecipeCategory = .dinner
    var height: CGFloat = 120

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [category.headerColor, category.headerColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: category.placeholderIcon)
                .font(.system(size: height * 0.42))
                .foregroundColor(.white.opacity(0.12))
        }
        .frame(height: height)
    }
}

// MARK: - Allergen Warning Banner

struct AllergenWarningBanner: View {
    let warning: AllergenWarning

    private var bannerColor: Color {
        switch warning.severity {
        case .severe:   return .red
        case .moderate: return .orange
        case .mild:     return .yellow
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: warning.severity == .severe
                  ? "exclamationmark.triangle.fill"
                  : "exclamationmark.circle.fill")
                .foregroundColor(bannerColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(warning.severity == .severe ? "Severe Allergen Warning" : "Allergen Notice")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                let names = warning.allergens.map { $0.allergen.rawValue }.joined(separator: ", ")
                Text("Contains: \(names)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(bannerColor.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(bannerColor.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

struct StarRatingView: View {
    let rating: Int
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(index <= rating ? .yellow : .gray)
            }
        }
    }
}

struct FavoriteButton: View {
    let recipe: RecipeModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite = false

    var body: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundColor(isFavorite ? .red : .blue)
        }
        .onAppear { checkIfFavorite() }
    }

    private func checkIfFavorite() {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %@", recipe.id.uuidString)
        request.fetchLimit = 1
        do {
            let favorites = try viewContext.fetch(request)
            isFavorite = !favorites.isEmpty
        } catch {
            print("Error checking favorite status: \(error)")
        }
    }

    private func toggleFavorite() {
        if isFavorite {
            let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
            request.predicate = NSPredicate(format: "recipeId == %@", recipe.id.uuidString)
            do {
                let favorites = try viewContext.fetch(request)
                favorites.forEach { viewContext.delete($0) }
                try viewContext.save()
                isFavorite = false
            } catch {
                print("Error removing favorite: \(error)")
            }
        } else {
            let favorite = FavoriteRecipe(context: viewContext)
            favorite.id = UUID()
            favorite.recipeId = recipe.id.uuidString
            favorite.recipeName = recipe.name
            favorite.category = recipe.category.rawValue
            favorite.prepTime = Int32(recipe.prepTime)
            favorite.cookTime = Int32(recipe.cookTime)
            favorite.servings = Int32(recipe.servings)
            favorite.rating = Int32(recipe.rating)
            favorite.imageURL = recipe.imageURL
            favorite.source = recipe.source
            favorite.dateAdded = Date()
            do {
                try viewContext.save()
                isFavorite = true
            } catch {
                print("Error adding favorite: \(error)")
            }
        }
    }
}
