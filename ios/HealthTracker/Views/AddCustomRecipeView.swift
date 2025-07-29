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
        if let image = recipeImage {
            // Compress image to reduce storage size
            customRecipe.imageData = image.jpegData(compressionQuality: 0.8)
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

// Placeholder for ingredient picker
struct IngredientPickerView: View {
    let onSelect: (RecipeIngredient) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Ingredient Picker - To be implemented")
                .navigationTitle("Select Ingredient")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}