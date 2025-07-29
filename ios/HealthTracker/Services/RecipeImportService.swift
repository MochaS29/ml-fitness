import Foundation
import SwiftUI
import CoreData

// MARK: - Recipe Import Service

class RecipeImportService {
    static let shared = RecipeImportService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func importRecipe(from url: String, context: NSManagedObjectContext) async throws -> CustomRecipe {
        guard let recipeURL = URL(string: url) else {
            throw RecipeImportError.invalidURL
        }
        
        // Determine the parser based on the domain
        let parser = getParser(for: recipeURL)
        
        // Fetch and parse the recipe
        let recipeData = try await parser.parseRecipe(from: recipeURL)
        
        // Save to Core Data
        return try saveRecipeToCoreData(recipeData, context: context)
    }
    
    func canImport(url: String) -> Bool {
        guard let recipeURL = URL(string: url) else { return false }
        return supportedDomains.contains { domain in
            recipeURL.host?.contains(domain) ?? false
        }
    }
    
    // MARK: - Private Properties
    
    private let supportedDomains = [
        "allrecipes.com",
        "foodnetwork.com",
        "bonappetit.com",
        "seriouseats.com",
        "epicurious.com",
        "simplyrecipes.com",
        "cookinglight.com",
        "myrecipes.com",
        "food52.com",
        "thekitchn.com",
        "minimalistbaker.com",
        "budgetbytes.com",
        "skinnytaste.com",
        "pinchofyum.com",
        "loveandlemons.com"
    ]
    
    // MARK: - Private Methods
    
    private func getParser(for url: URL) -> RecipeParserProtocol {
        let host = url.host?.lowercased() ?? ""
        
        // Return specific parser based on domain
        if host.contains("allrecipes.com") {
            return AllRecipesParser()
        } else if host.contains("foodnetwork.com") {
            return FoodNetworkParser()
        } else {
            // Default to generic schema.org parser
            return SchemaOrgParser()
        }
    }
    
    private func saveRecipeToCoreData(_ recipeData: ParsedRecipe, context: NSManagedObjectContext) throws -> CustomRecipe {
        let recipe = CustomRecipe(context: context)
        recipe.id = UUID()
        recipe.name = recipeData.name
        recipe.category = recipeData.category?.rawValue ?? RecipeCategory.dinner.rawValue
        recipe.prepTime = Int32(recipeData.prepTime ?? 0)
        recipe.cookTime = Int32(recipeData.cookTime ?? 0)
        recipe.servings = Int32(recipeData.servings ?? 4)
        recipe.instructions = recipeData.instructions
        recipe.ingredients = recipeData.ingredients.map { ingredient in
            "\(ingredient.amount) \(ingredient.unit) \(ingredient.name)"
        }
        recipe.source = recipeData.sourceURL
        recipe.calories = recipeData.nutrition?.calories ?? 0
        recipe.protein = recipeData.nutrition?.protein ?? 0
        recipe.carbs = recipeData.nutrition?.carbs ?? 0
        recipe.fat = recipeData.nutrition?.fat ?? 0
        recipe.fiber = recipeData.nutrition?.fiber ?? 0
        recipe.sugar = recipeData.nutrition?.sugar ?? 0
        recipe.sodium = recipeData.nutrition?.sodium ?? 0
        recipe.isUserCreated = false
        recipe.isFavorite = false
        recipe.createdDate = Date()
        recipe.tags = recipeData.tags
        
        // Download and save image if available
        if let imageURL = recipeData.imageURL {
            Task {
                if let imageData = try? await downloadImage(from: imageURL) {
                    await MainActor.run {
                        recipe.imageData = imageData
                    }
                    try? context.save()
                }
            }
        }
        
        try context.save()
        return recipe
    }
    
    private func downloadImage(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

// MARK: - Error Types

enum RecipeImportError: LocalizedError {
    case invalidURL
    case unsupportedWebsite
    case parsingFailed
    case networkError
    case noRecipeFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid recipe URL"
        case .unsupportedWebsite:
            return "This website is not yet supported"
        case .parsingFailed:
            return "Could not extract recipe information"
        case .networkError:
            return "Network connection error"
        case .noRecipeFound:
            return "No recipe found at this URL"
        }
    }
}

// MARK: - Parser Protocol

protocol RecipeParserProtocol {
    func parseRecipe(from url: URL) async throws -> ParsedRecipe
}

// MARK: - Parsed Recipe Model

struct ParsedRecipe {
    let name: String
    let category: RecipeCategory?
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let ingredients: [ParsedIngredient]
    let instructions: [String]
    let nutrition: ParsedNutrition?
    let imageURL: String?
    let sourceURL: String
    let tags: [String]
}

struct ParsedIngredient {
    let name: String
    let amount: String
    let unit: String
}

struct ParsedNutrition {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
}

// MARK: - Generic Schema.org Parser

class SchemaOrgParser: RecipeParserProtocol {
    func parseRecipe(from url: URL) async throws -> ParsedRecipe {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw RecipeImportError.parsingFailed
        }
        
        // Look for JSON-LD structured data
        if let jsonLD = extractJSONLD(from: html) {
            return try parseFromJSONLD(jsonLD, sourceURL: url.absoluteString)
        }
        
        // Fallback to microdata parsing
        return try parseFromMicrodata(html, sourceURL: url.absoluteString)
    }
    
    private func extractJSONLD(from html: String) -> Data? {
        let pattern = #"<script[^>]*type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        
        let jsonString = String(html[range])
        return jsonString.data(using: .utf8)
    }
    
    private func parseFromJSONLD(_ data: Data, sourceURL: String) throws -> ParsedRecipe {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Handle array of objects or single object
        let recipeData: [String: Any]?
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            recipeData = jsonArray.first { ($0["@type"] as? String)?.contains("Recipe") ?? false }
        } else if let type = json?["@type"] as? String, type.contains("Recipe") {
            recipeData = json
        } else {
            throw RecipeImportError.noRecipeFound
        }
        
        guard let recipe = recipeData else {
            throw RecipeImportError.noRecipeFound
        }
        
        // Extract recipe details
        let name = recipe["name"] as? String ?? "Untitled Recipe"
        let prepTime = parseISO8601Duration(recipe["prepTime"] as? String)
        let cookTime = parseISO8601Duration(recipe["cookTime"] as? String)
        let servings = parseServings(recipe["recipeYield"])
        
        // Parse ingredients
        let ingredients = parseIngredients(recipe["recipeIngredient"] as? [String] ?? [])
        
        // Parse instructions
        let instructions = parseInstructions(recipe["recipeInstructions"])
        
        // Parse nutrition
        let nutrition = parseNutrition(recipe["nutrition"] as? [String: Any])
        
        // Get image
        let imageURL = extractImageURL(from: recipe["image"])
        
        // Extract tags/keywords
        let tags = (recipe["keywords"] as? String)?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
        return ParsedRecipe(
            name: name,
            category: guessCategory(from: name, tags: tags),
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            ingredients: ingredients,
            instructions: instructions,
            nutrition: nutrition,
            imageURL: imageURL,
            sourceURL: sourceURL,
            tags: tags
        )
    }
    
    private func parseFromMicrodata(_ html: String, sourceURL: String) throws -> ParsedRecipe {
        // Basic HTML parsing fallback
        // This is simplified - in production, use a proper HTML parser
        throw RecipeImportError.parsingFailed
    }
    
    private func parseISO8601Duration(_ duration: String?) -> Int? {
        guard let duration = duration else { return nil }
        
        // Parse ISO 8601 duration format (e.g., "PT30M" = 30 minutes)
        let pattern = #"PT(?:(\d+)H)?(?:(\d+)M)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)) else {
            return nil
        }
        
        var totalMinutes = 0
        
        // Hours
        if let hoursRange = Range(match.range(at: 1), in: duration),
           let hours = Int(duration[hoursRange]) {
            totalMinutes += hours * 60
        }
        
        // Minutes
        if let minutesRange = Range(match.range(at: 2), in: duration),
           let minutes = Int(duration[minutesRange]) {
            totalMinutes += minutes
        }
        
        return totalMinutes > 0 ? totalMinutes : nil
    }
    
    private func parseServings(_ yield: Any?) -> Int? {
        if let servings = yield as? Int {
            return servings
        } else if let servingsString = yield as? String {
            // Extract number from string like "4 servings" or "Serves 6"
            let numbers = servingsString.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
            return numbers.first
        }
        return nil
    }
    
    private func parseIngredients(_ ingredientStrings: [String]) -> [ParsedIngredient] {
        return ingredientStrings.compactMap { parseIngredientString($0) }
    }
    
    private func parseIngredientString(_ ingredient: String) -> ParsedIngredient {
        // Simple parsing - in production, use a more sophisticated ingredient parser
        let components = ingredient.components(separatedBy: " ")
        
        var amount = "1"
        var unit = ""
        var name = ingredient
        
        if components.count >= 2 {
            // Try to extract amount
            if let _ = Double(components[0]) {
                amount = components[0]
                if components.count >= 3 {
                    unit = components[1]
                    name = components[2...].joined(separator: " ")
                } else {
                    name = components[1...].joined(separator: " ")
                }
            }
        }
        
        return ParsedIngredient(name: name, amount: amount, unit: unit)
    }
    
    private func parseInstructions(_ instructionsData: Any?) -> [String] {
        if let instructions = instructionsData as? [String] {
            return instructions
        } else if let instructions = instructionsData as? [[String: Any]] {
            return instructions.compactMap { instruction in
                if let text = instruction["text"] as? String {
                    return text
                } else if let name = instruction["name"] as? String {
                    return name
                }
                return nil
            }
        } else if let instructionText = instructionsData as? String {
            // Split by common delimiters
            return instructionText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        }
        return []
    }
    
    private func parseNutrition(_ nutritionData: [String: Any]?) -> ParsedNutrition? {
        guard let nutrition = nutritionData else { return nil }
        
        // Common nutrition property names in schema.org
        let calories = extractNutrientValue(nutrition["calories"] ?? nutrition["Calories"])
        let protein = extractNutrientValue(nutrition["proteinContent"] ?? nutrition["protein"])
        let carbs = extractNutrientValue(nutrition["carbohydrateContent"] ?? nutrition["carbohydrates"])
        let fat = extractNutrientValue(nutrition["fatContent"] ?? nutrition["fat"])
        let fiber = extractNutrientValue(nutrition["fiberContent"] ?? nutrition["fiber"])
        let sugar = extractNutrientValue(nutrition["sugarContent"] ?? nutrition["sugar"])
        let sodium = extractNutrientValue(nutrition["sodiumContent"] ?? nutrition["sodium"])
        
        return ParsedNutrition(
            calories: calories ?? 0,
            protein: protein ?? 0,
            carbs: carbs ?? 0,
            fat: fat ?? 0,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium
        )
    }
    
    private func extractNutrientValue(_ value: Any?) -> Double? {
        if let number = value as? Double {
            return number
        } else if let number = value as? Int {
            return Double(number)
        } else if let string = value as? String {
            // Extract number from strings like "250 calories" or "12g"
            let numbers = string.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Double($0) }
            return numbers.first
        }
        return nil
    }
    
    private func extractImageURL(from imageData: Any?) -> String? {
        if let urlString = imageData as? String {
            return urlString
        } else if let imageObject = imageData as? [String: Any] {
            return imageObject["url"] as? String ?? imageObject["contentUrl"] as? String
        } else if let imageArray = imageData as? [Any], let firstImage = imageArray.first {
            return extractImageURL(from: firstImage)
        }
        return nil
    }
    
    private func guessCategory(from name: String, tags: [String]) -> RecipeCategory? {
        let allText = (name + " " + tags.joined(separator: " ")).lowercased()
        
        if allText.contains("breakfast") || allText.contains("pancake") || allText.contains("waffle") || allText.contains("omelet") {
            return .breakfast
        } else if allText.contains("lunch") || allText.contains("sandwich") || allText.contains("salad") {
            return .lunch
        } else if allText.contains("dinner") || allText.contains("main") {
            return .dinner
        } else if allText.contains("dessert") || allText.contains("cake") || allText.contains("cookie") || allText.contains("sweet") {
            return .dessert
        } else if allText.contains("snack") || allText.contains("appetizer") {
            return .snack
        } else if allText.contains("soup") {
            return .soup
        } else if allText.contains("salad") {
            return .salad
        } else if allText.contains("drink") || allText.contains("beverage") || allText.contains("smoothie") {
            return .beverage
        }
        
        return .dinner // Default
    }
}

// MARK: - Site-Specific Parsers

class AllRecipesParser: SchemaOrgParser {
    // AllRecipes uses schema.org, so we can use the parent implementation
    // Add any AllRecipes-specific parsing here if needed
}

class FoodNetworkParser: SchemaOrgParser {
    // FoodNetwork also uses schema.org
    // Add any FoodNetwork-specific parsing here if needed
}