import SwiftUI
import CoreData

struct ImportRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var recipeURL = ""
    @State private var isImporting = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var importedRecipe: CustomRecipe?
    @State private var showingSuccess = false
    
    private let importService = RecipeImportService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    
                    Text("Import Recipe from Web")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Paste a recipe URL from your favorite cooking website")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // URL Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recipe URL")
                        .font(.headline)
                    
                    TextField("https://www.example.com/recipe", text: $recipeURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    
                    if !recipeURL.isEmpty && !importService.canImport(url: recipeURL) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("This website may not be fully supported")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                
                // Supported Sites
                VStack(alignment: .leading, spacing: 12) {
                    Text("Supported Websites")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(supportedSites, id: \.self) { site in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text(site)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Import Button
                Button(action: importRecipe) {
                    if isImporting {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Importing...")
                        }
                    } else {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Import Recipe")
                        }
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color(red: 127/255, green: 176/255, blue: 105/255)
                        .opacity(recipeURL.isEmpty || isImporting ? 0.5 : 1.0)
                )
                .cornerRadius(12)
                .disabled(recipeURL.isEmpty || isImporting)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Import Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .sheet(item: $importedRecipe) { recipe in
                NavigationView {
                    RecipeImportSuccessView(recipe: recipe) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var supportedSites: [String] {
        [
            "AllRecipes",
            "Food Network",
            "Bon Appétit",
            "Serious Eats",
            "Epicurious",
            "Simply Recipes",
            "Cooking Light",
            "MyRecipes",
            "Food52",
            "The Kitchn",
            "Minimalist Baker",
            "Budget Bytes",
            "Skinnytaste",
            "Pinch of Yum",
            "Love & Lemons"
        ]
    }
    
    private func importRecipe() {
        guard !recipeURL.isEmpty else { return }
        
        isImporting = true
        
        Task {
            do {
                let recipe = try await importService.importRecipe(from: recipeURL, context: viewContext)
                
                await MainActor.run {
                    self.importedRecipe = recipe
                    self.isImporting = false
                    self.recipeURL = ""
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                    self.isImporting = false
                }
            }
        }
    }
}

struct RecipeImportSuccessView: View {
    let recipe: CustomRecipe
    let onDismiss: () -> Void
    
    @State private var showingRecipeDetail = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding(.top, 40)
            
            // Recipe Info
            VStack(spacing: 16) {
                Text("Recipe Imported Successfully!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(recipe.name ?? "Untitled Recipe")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Recipe Stats
                HStack(spacing: 20) {
                    VStack {
                        Image(systemName: "clock")
                            .font(.title3)
                            .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
                        Text("\(recipe.prepTime + recipe.cookTime) min")
                            .font(.caption)
                    }
                    
                    VStack {
                        Image(systemName: "person.2")
                            .font(.title3)
                            .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
                        Text("\(recipe.servings) servings")
                            .font(.caption)
                    }
                    
                    if recipe.calories > 0 {
                        VStack {
                            Image(systemName: "flame")
                                .font(.title3)
                                .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
                            Text("\(Int(recipe.calories)) cal")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { showingRecipeDetail = true }) {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("View Recipe")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(12)
                }
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 127/255, green: 176/255, blue: 105/255), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Success")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingRecipeDetail) {
            if let recipe = convertToRecipe(recipe) {
                NavigationView {
                    ProfessionalRecipeDetailView(recipe: recipe)
                        .navigationBarItems(
                            trailing: Button("Done") {
                                showingRecipeDetail = false
                            }
                        )
                }
            }
        }
    }
    
    private func convertToRecipe(_ customRecipe: CustomRecipe) -> RecipeModel? {
        guard let name = customRecipe.name,
              let categoryString = customRecipe.category,
              let category = RecipeCategory(rawValue: categoryString) else {
            return nil
        }
        
        // Parse ingredients from string array
        let ingredients: [IngredientModel] = (customRecipe.ingredients ?? []).map { ingredientString in
            // Simple parsing - in real app would be more sophisticated
            let components = ingredientString.components(separatedBy: " ")
            var amount = 1.0
            var unit = IngredientUnit.piece
            var name = ingredientString
            
            if components.count >= 3,
               let parsedAmount = Double(components[0]) {
                amount = parsedAmount
                
                // Try to parse unit
                if let parsedUnit = IngredientUnit.allCases.first(where: { $0.rawValue == components[1] }) {
                    unit = parsedUnit
                    name = components[2...].joined(separator: " ")
                } else {
                    name = components[1...].joined(separator: " ")
                }
            }
            
            return IngredientModel(name: name, amount: amount, unit: unit, notes: nil, category: .other)
        }
        
        return RecipeModel(
            id: customRecipe.id ?? UUID(),
            name: name,
            category: category,
            prepTime: Int(customRecipe.prepTime),
            cookTime: Int(customRecipe.cookTime),
            servings: Int(customRecipe.servings),
            ingredients: ingredients,
            instructions: customRecipe.instructions ?? [],
            nutrition: NutritionInfo(
                calories: customRecipe.calories,
                protein: customRecipe.protein,
                carbs: customRecipe.carbs,
                fat: customRecipe.fat,
                fiber: customRecipe.fiber,
                sugar: customRecipe.sugar,
                sodium: customRecipe.sodium
            ),
            source: customRecipe.source,
            tags: customRecipe.tags ?? [],
            isFavorite: customRecipe.isFavorite
        )
    }
}

// #Preview {
//     ImportRecipeView()
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }