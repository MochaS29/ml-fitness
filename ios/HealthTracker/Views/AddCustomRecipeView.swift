import SwiftUI
import PhotosUI
import CoreData

struct AddCustomRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var category = RecipeCategory.dinner
    @State private var prepTime = 15
    @State private var cookTime = 30
    @State private var servings = 4
    
    // Ingredients
    @State private var ingredients: [RecipeIngredient] = []
    @State private var currentIngredient = ""
    @State private var showingIngredientPicker = false
    
    // Instructions
    @State private var instructions: [String] = [""]
    
    // Nutrition (will be calculated from ingredients)
    @State private var calculatedNutrition = NutritionInfo(
        calories: 0, protein: 0, carbs: 0, fat: 0,
        fiber: 0, sugar: 0, sodium: 0
    )
    
    // Additional nutrients (manually entered at recipe level — vitamins, minerals)
    @State private var showingAdditionalNutrients = false
    @State private var additionalNutrients: [String: Double] = [:]

    // Tags
    @State private var tags: [String] = []
    @State private var currentTag = ""
    
    // Image
    @State private var selectedImage: PhotosPickerItem?
    @State private var recipeImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var isValid: Bool {
        !name.isEmpty && !ingredients.isEmpty && instructions.contains(where: { !$0.isEmpty })
    }
    
    var body: some View {
        NavigationView {
            formContent
                .navigationTitle("Add Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!isValid)
                )
        }
        .sheet(isPresented: $showingIngredientPicker) {
            IngredientPickerView { ingredient in
                ingredients.append(ingredient)
                calculateNutrition()
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraImagePicker(selectedImage: $recipeImage, sourceType: imageSourceType)
        }
        .confirmationDialog("Choose Image Source", isPresented: $showingImagePicker) {
            Button("Photo Library") {
                imageSourceType = .photoLibrary
                showingCamera = true
            }
            Button("Camera") {
                imageSourceType = .camera
                showingCamera = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var formContent: some View {
        Form {
            recipeInfoSection
            recipePhotoSection
            ingredientsSection
            instructionsSection
            tagsSection
            nutritionSection
            additionalNutrientsSection
        }
    }
    
    private var recipeInfoSection: some View {
        Section("Recipe Information") {
            TextField("Recipe Name", text: $name)
            
            Picker("Category", selection: $category) {
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Prep Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper("\(prepTime) min", value: $prepTime, in: 0...300, step: 5)
                }
                
                VStack(alignment: .leading) {
                    Text("Cook Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper("\(cookTime) min", value: $cookTime, in: 0...300, step: 5)
                }
            }
            
            Stepper("Servings: \(servings)", value: $servings, in: 1...20)
        }
    }
    
    private var recipePhotoSection: some View {
        Section("Recipe Photo") {
                    if let image = recipeImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }
                    
                    HStack {
                        // Photo Library
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("Choose Photo", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.mindfulTeal)
                        
                        // Camera
                        Button(action: {
                            imageSourceType = .camera
                            showingCamera = true
                        }) {
                            Label("Take Photo", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.mindfulTeal)
            }
            .onChange(of: selectedImage) { _, _ in
                Task {
                    if let data = try? await selectedImage?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        recipeImage = image
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        Section("Ingredients") {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ingredient.name)
                                    .font(.body)
                                Text("\(ingredient.amount, specifier: "%.2g") \(ingredient.unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(ingredient.calories)) cal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteIngredient)
                    
            Button(action: { showingIngredientPicker = true }) {
                Label("Add Ingredient", systemImage: "plus.circle")
                    .foregroundColor(.mindfulTeal)
            }
        }
    }
    
    private var instructionsSection: some View {
        Section("Instructions") {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            TextEditor(text: $instructions[index])
                                .frame(minHeight: 60)
                        }
                    }
                    .onDelete(perform: deleteInstruction)
                    
            Button(action: addInstruction) {
                Label("Add Step", systemImage: "plus.circle")
                    .foregroundColor(.mindfulTeal)
            }
        }
    }
    
    private var tagsSection: some View {
        Section("Tags") {
                    FlowLayout(items: tags) { tag in
                        TagChip(text: tag) {
                            tags.removeAll { $0 == tag }
                        }
                    }
                    
                    HStack {
                        TextField("Add tag", text: $currentTag)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            if !currentTag.isEmpty {
                                tags.append(currentTag)
                                currentTag = ""
                            }
                        }
                .disabled(currentTag.isEmpty)
            }
        }
    }
    
    private var nutritionSection: some View {
        Section("Nutrition (Calculated)") {
                    HStack {
                        NutritionLabel(value: Int(calculatedNutrition.calories), label: "Calories")
                        NutritionLabel(value: Int(calculatedNutrition.protein), label: "Protein", unit: "g")
                        NutritionLabel(value: Int(calculatedNutrition.carbs), label: "Carbs", unit: "g")
                        NutritionLabel(value: Int(calculatedNutrition.fat), label: "Fat", unit: "g")
                    }
                    
                    if let fiber = calculatedNutrition.fiber,
                       let sugar = calculatedNutrition.sugar,
                       let sodium = calculatedNutrition.sodium {
                        HStack {
                            NutritionLabel(value: Int(fiber), label: "Fiber", unit: "g")
                            NutritionLabel(value: Int(sugar), label: "Sugar", unit: "g")
                            NutritionLabel(value: Int(sodium), label: "Sodium", unit: "mg")
                            Spacer()
                        }
                    }
                    
            Text("Per serving")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var additionalNutrientsSection: some View {
        Section {
            Button(action: { showingAdditionalNutrients.toggle() }) {
                HStack {
                    Text("Additional Nutrients")
                    Spacer()
                    Image(systemName: showingAdditionalNutrients ? "chevron.up" : "chevron.down")
                }
            }

            if showingAdditionalNutrients {
                Group {
                    Text("Vitamins").font(.headline)
                    extraNutrientRow("Vitamin A", key: "vitamin_a", unit: "mcg")
                    extraNutrientRow("Vitamin C", key: "vitamin_c", unit: "mg")
                    extraNutrientRow("Vitamin D", key: "vitamin_d", unit: "mcg")
                    extraNutrientRow("Vitamin E", key: "vitamin_e", unit: "mg")
                    extraNutrientRow("Vitamin K", key: "vitamin_k", unit: "mcg")
                    extraNutrientRow("Thiamin (B1)", key: "thiamin", unit: "mg")
                    extraNutrientRow("Riboflavin (B2)", key: "riboflavin", unit: "mg")
                    extraNutrientRow("Niacin (B3)", key: "niacin", unit: "mg")
                    extraNutrientRow("Vitamin B6", key: "vitamin_b6", unit: "mg")
                    extraNutrientRow("Folate", key: "folate", unit: "mcg")
                }

                Group {
                    extraNutrientRow("Vitamin B12", key: "vitamin_b12", unit: "mcg")
                    extraNutrientRow("Biotin", key: "biotin", unit: "mcg")
                    extraNutrientRow("Pantothenic Acid", key: "pantothenic_acid", unit: "mg")
                }

                Group {
                    Text("Minerals").font(.headline)
                    extraNutrientRow("Calcium", key: "calcium", unit: "mg")
                    extraNutrientRow("Iron", key: "iron", unit: "mg")
                    extraNutrientRow("Magnesium", key: "magnesium", unit: "mg")
                    extraNutrientRow("Phosphorus", key: "phosphorus", unit: "mg")
                    extraNutrientRow("Potassium", key: "potassium", unit: "mg")
                    extraNutrientRow("Zinc", key: "zinc", unit: "mg")
                    extraNutrientRow("Copper", key: "copper", unit: "mg")
                    extraNutrientRow("Manganese", key: "manganese", unit: "mg")
                    extraNutrientRow("Selenium", key: "selenium", unit: "mcg")
                }
            }
        } footer: {
            Text("Per serving. Add what you know — leave the rest blank.")
        }
    }

    @ViewBuilder
    private func extraNutrientRow(_ label: String, key: String, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: extraBinding(for: key), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.decimalPad)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
    }

    private func extraBinding(for key: String) -> Binding<Double> {
        Binding<Double>(
            get: { additionalNutrients[key] ?? 0 },
            set: { additionalNutrients[key] = $0 }
        )
    }

    func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        calculateNutrition()
    }
    
    func addInstruction() {
        instructions.append("")
    }
    
    func deleteInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
    }
    
    func calculateNutrition() {
        var totalCalories = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0
        var totalFiber = 0.0
        var totalSugar = 0.0
        var totalSodium = 0.0
        
        for ingredient in ingredients {
            totalCalories += ingredient.calories
            totalProtein += ingredient.protein
            totalCarbs += ingredient.carbs
            totalFat += ingredient.fat
            totalFiber += ingredient.fiber ?? 0
            totalSugar += ingredient.sugar ?? 0
            totalSodium += ingredient.sodium ?? 0
        }
        
        // Calculate per serving
        let servingDivisor = Double(servings)
        calculatedNutrition = NutritionInfo(
            calories: totalCalories / servingDivisor,
            protein: totalProtein / servingDivisor,
            carbs: totalCarbs / servingDivisor,
            fat: totalFat / servingDivisor,
            fiber: totalFiber / servingDivisor,
            sugar: totalSugar / servingDivisor,
            sodium: totalSodium / servingDivisor
        )
    }
    
    private func saveImageToFileSystem(_ image: UIImage, recipeID: UUID) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let folder = docsURL.appendingPathComponent("recipe_photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let fileURL = folder.appendingPathComponent("\(recipeID.uuidString).jpg")
        try? data.write(to: fileURL)
    }

    func saveRecipe() {
        let customRecipe = CustomRecipe(context: viewContext)
        customRecipe.id = UUID()
        customRecipe.name = name
        customRecipe.category = category.rawValue
        customRecipe.prepTime = Int32(prepTime)
        customRecipe.cookTime = Int32(cookTime)
        customRecipe.servings = Int32(servings)
        customRecipe.calories = calculatedNutrition.calories
        customRecipe.protein = calculatedNutrition.protein
        customRecipe.carbs = calculatedNutrition.carbs
        customRecipe.fat = calculatedNutrition.fat
        customRecipe.fiber = calculatedNutrition.fiber ?? 0
        customRecipe.sugar = calculatedNutrition.sugar ?? 0
        customRecipe.sodium = calculatedNutrition.sodium ?? 0
        let extras = additionalNutrients.filter { $0.value > 0 }
        if !extras.isEmpty {
            customRecipe.additionalNutrients = extras
        }
        customRecipe.isUserCreated = true
        customRecipe.createdDate = Date()
        customRecipe.source = "User"
        customRecipe.tags = tags
        customRecipe.isFavorite = false
        
        // Convert ingredients to string array for storage
        customRecipe.ingredients = ingredients.map { 
            "\($0.amount) \($0.unit) \($0.name)"
        }
        
        // Filter out empty instructions
        customRecipe.instructions = instructions.filter { !$0.isEmpty }
        
        // Save image if available
        if let image = recipeImage, let recipeID = customRecipe.id {
            // Save to CoreData for thumbnails
            customRecipe.imageData = image.jpegData(compressionQuality: 0.8)
            // Also save to file system so ProfessionalRecipeDetailView can find it
            saveImageToFileSystem(image, recipeID: recipeID)
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving recipe: \(error)")
        }
    }
}

struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
}

struct NutritionLabel: View {
    let value: Int
    let label: String
    var unit: String = ""
    
    var body: some View {
        VStack {
            Text("\(value)\(unit)")
                .font(.headline)
                .foregroundColor(.mochaBrown)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TagChip: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.mindfulTeal.opacity(0.2))
        .foregroundColor(.mindfulTeal)
        .cornerRadius(15)
    }
}

struct FlowLayout<Item, ItemView: View>: View {
    let items: [Item]
    let content: (Item) -> ItemView
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
                content(items[index])
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}

struct IngredientPickerView: View {
    let onSelect: (RecipeIngredient) -> Void
    @Environment(\.presentationMode) var presentationMode

    // Search phase
    @State private var searchText = ""
    @State private var searchResults: [FoodItem] = []
    @State private var showingForm = false

    // Form fields
    @State private var name = ""
    @State private var amount = "100"
    @State private var selectedUnit = "g"
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var sugar = ""
    @State private var sodium = ""

    // Base (per-serving) values for proportional scaling
    @State private var baseAmount: Double = 100
    @State private var baseCalories: Double = 0
    @State private var baseProtein: Double = 0
    @State private var baseCarbs: Double = 0
    @State private var baseFat: Double = 0
    @State private var baseFiber: Double = 0
    @State private var baseSugar: Double? = nil
    @State private var baseSodium: Double? = nil
    @State private var fromDatabase = false

    private let commonUnits = ["g", "oz", "cup", "tbsp", "tsp", "ml", "L", "lb", "kg",
                                "piece", "clove", "slice", "can", "bunch", "pinch"]
    private var isValid: Bool { !name.isEmpty && (Double(amount) ?? 0) > 0 }

    var body: some View {
        NavigationView {
            Group {
                if showingForm {
                    formView
                } else {
                    searchListView
                }
            }
            .navigationTitle(showingForm ? "Add Ingredient" : "Select Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(showingForm ? "Back" : "Cancel") {
                        if showingForm { showingForm = false } else { presentationMode.wrappedValue.dismiss() }
                    }
                }
                if showingForm {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") { addIngredient() }
                            .fontWeight(.semibold)
                            .disabled(!isValid)
                    }
                }
            }
        }
    }

    // MARK: - Search phase

    private var searchListView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search foods (e.g. Chicken Breast)…", text: $searchText)
                    .autocorrectionDisabled()
                    .onChange(of: searchText) { _, q in
                        searchResults = q.count >= 2
                            ? LocalFoodDatabase.shared.searchFoods(q, limit: 40)
                            : LocalFoodDatabase.shared.getCommonFoods(limit: 20)
                    }
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            List {
                // Manual entry shortcut
                Button(action: { openManualForm() }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.mindfulTeal)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enter manually")
                                .foregroundColor(.primary)
                            Text("Type nutrition values yourself")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Search results or common foods
                let items = searchResults.isEmpty
                    ? LocalFoodDatabase.shared.getCommonFoods(limit: 20)
                    : searchResults
                let sectionTitle = searchResults.isEmpty ? "Common Foods" : "Results"

                Section(sectionTitle) {
                    ForEach(items) { food in
                        Button(action: { selectFood(food) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name)
                                        .foregroundColor(.primary)
                                    if let brand = food.brand {
                                        Text(brand)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(Int(food.calories)) cal")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.orange)
                                    Text("\(food.servingSize) \(food.servingUnit)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            searchResults = LocalFoodDatabase.shared.getCommonFoods(limit: 20)
        }
    }

    // MARK: - Form phase

    private var formView: some View {
        Form {
            Section("Ingredient") {
                TextField("Name", text: $name)
                HStack(spacing: 12) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .onChange(of: amount) { _, newVal in
                            guard fromDatabase, let newAmt = Double(newVal), newAmt > 0, baseAmount > 0 else { return }
                            let ratio = newAmt / baseAmount
                            calories = formatNutrient(baseCalories * ratio)
                            protein  = formatNutrient(baseProtein  * ratio)
                            carbs    = formatNutrient(baseCarbs    * ratio)
                            fat      = formatNutrient(baseFat      * ratio)
                            fiber    = formatNutrient(baseFiber    * ratio)
                            if let s = baseSugar  { sugar  = formatNutrient(s * ratio) }
                            if let s = baseSodium { sodium = formatNutrient(s * ratio) }
                        }
                    Divider().frame(height: 20)
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(commonUnits, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                }
            }

            if fromDatabase {
                Section {
                    nutritionRow("Calories", value: $calories, unit: "kcal")
                    nutritionRow("Protein",  value: $protein,  unit: "g")
                    nutritionRow("Carbs",    value: $carbs,    unit: "g")
                    nutritionRow("Fat",      value: $fat,      unit: "g")
                    nutritionRow("Fiber",    value: $fiber,    unit: "g")
                    nutritionRow("Sugar",    value: $sugar,    unit: "g")
                    nutritionRow("Sodium",   value: $sodium,   unit: "mg")
                } header: {
                    Text("Nutrition — auto-filled from database")
                } footer: {
                    Text("Values scale automatically with amount. Edit if needed.")
                }
            } else {
                Section {
                    nutritionRow("Calories", value: $calories, unit: "kcal")
                    nutritionRow("Protein",  value: $protein,  unit: "g")
                    nutritionRow("Carbs",    value: $carbs,    unit: "g")
                    nutritionRow("Fat",      value: $fat,      unit: "g")
                    nutritionRow("Fiber",    value: $fiber,    unit: "g")
                    nutritionRow("Sugar",    value: $sugar,    unit: "g")
                    nutritionRow("Sodium",   value: $sodium,   unit: "mg")
                } header: {
                    Text("Nutrition (optional)")
                } footer: {
                    Text("Leave blank if unknown — values default to 0.")
                }
            }
        }
    }

    // MARK: - Helpers

    private func nutritionRow(_ label: String, value: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 38, alignment: .leading)
        }
    }

    private func selectFood(_ food: FoodItem) {
        let servingAmt = Double(food.servingSize) ?? 100
        name         = food.name
        amount       = food.servingSize
        selectedUnit = food.servingUnit.isEmpty ? "g" : food.servingUnit
        fromDatabase = true

        // Store base values for proportional scaling
        baseAmount   = servingAmt
        baseCalories = food.calories
        baseProtein  = food.protein
        baseCarbs    = food.carbs
        baseFat      = food.fat
        baseFiber    = food.fiber
        baseSugar    = food.sugar
        baseSodium   = food.sodium

        calories = formatNutrient(food.calories)
        protein  = formatNutrient(food.protein)
        carbs    = formatNutrient(food.carbs)
        fat      = formatNutrient(food.fat)
        fiber    = formatNutrient(food.fiber)
        sugar    = food.sugar.map { formatNutrient($0) } ?? ""
        sodium   = food.sodium.map { formatNutrient($0) } ?? ""

        showingForm = true
    }

    private func openManualForm() {
        fromDatabase = false
        name = searchText  // pre-fill name from whatever was typed
        amount = "100"; selectedUnit = "g"
        calories = ""; protein = ""; carbs = ""; fat = ""
        fiber = ""; sugar = ""; sodium = ""
        showingForm = true
    }

    private func formatNutrient(_ value: Double) -> String {
        value == 0 ? "" : (value == Double(Int(value)) ? "\(Int(value))" : String(format: "%.1f", value))
    }

    private func addIngredient() {
        let ingredient = RecipeIngredient(
            name: name,
            amount: Double(amount) ?? 1,
            unit: selectedUnit,
            calories: Double(calories) ?? 0,
            protein:  Double(protein)  ?? 0,
            carbs:    Double(carbs)    ?? 0,
            fat:      Double(fat)      ?? 0,
            fiber:    fiber.isEmpty  ? nil : Double(fiber),
            sugar:    sugar.isEmpty  ? nil : Double(sugar),
            sodium:   sodium.isEmpty ? nil : Double(sodium)
        )
        onSelect(ingredient)
        presentationMode.wrappedValue.dismiss()
    }
}