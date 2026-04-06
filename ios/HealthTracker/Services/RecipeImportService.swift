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
            Task { @MainActor [recipe] in
                if let imageData = try? await downloadImage(from: imageURL) {
                    recipe.imageData = imageData
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
        let html = try await fetchHTML(from: url)

        // Try every JSON-LD block — sites put BreadcrumbList/WebPage first, Recipe later.
        let blocks = extractAllJSONLD(from: html)
        for block in blocks {
            if let recipe = try? parseFromJSONLD(block, sourceURL: url.absoluteString) {
                return recipe
            }
        }

        // Fallback: microdata / meta tags
        return try parseFromMicrodata(html, sourceURL: url.absoluteString)
    }

    func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        // Use a desktop Chrome UA — more reliable against bot detection than mobile Safari
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("https://www.google.com/", forHTTPHeaderField: "Referer")
        request.setValue("1", forHTTPHeaderField: "DNT")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Surface HTTP errors
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            throw RecipeImportError.networkError
        }

        guard let html = String(data: data, encoding: .utf8)
                      ?? String(data: data, encoding: .isoLatin1) else {
            throw RecipeImportError.parsingFailed
        }
        return html
    }

    private func extractAllJSONLD(from html: String) -> [Data] {
        let pattern = #"<script[^>]*type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return []
        }
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)
        return matches.compactMap { match in
            guard let r = Range(match.range(at: 1), in: html) else { return nil }
            return String(html[r]).data(using: .utf8)
        }
    }

    private func parseFromJSONLD(_ data: Data, sourceURL: String) throws -> ParsedRecipe {
        let rawJSON = try JSONSerialization.jsonObject(with: data)

        // Helper: does an @type value (String or [String]) contain "Recipe"?
        func isRecipeType(_ value: Any?) -> Bool {
            if let s = value as? String { return s.contains("Recipe") }
            if let arr = value as? [String] { return arr.contains { $0.contains("Recipe") } }
            return false
        }

        // Handle four common JSON-LD patterns:
        // 1. Top-level dict, @type is "Recipe"
        // 2. Top-level dict with @graph array containing a Recipe
        // 3. Top-level array of objects — iterate and find Recipe (AllRecipes, many modern sites)
        // 4. Top-level array where one element has its own @graph
        let recipeData: [String: Any]?

        if let json = rawJSON as? [String: Any] {
            if isRecipeType(json["@type"]) {
                recipeData = json
            } else if let graph = json["@graph"] as? [[String: Any]] {
                recipeData = graph.first { isRecipeType($0["@type"]) }
            } else {
                recipeData = nil
            }
        } else if let array = rawJSON as? [[String: Any]] {
            // Top-level array — find the Recipe entry
            recipeData = array.first { isRecipeType($0["@type"]) }
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
        let tags = (recipe["keywords"] as? String)?.components(separatedBy: ",").map { decodeHTMLEntities($0.trimmingCharacters(in: .whitespaces)) } ?? []
        
        return ParsedRecipe(
            name: decodeHTMLEntities(name),
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
    
    func decodeHTMLEntities(_ string: String) -> String {
        var s = string
        // Named entities
        let table: [(String, String)] = [
            ("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"),
            ("&quot;", "\""), ("&apos;", "'"), ("&#39;", "'"),
            ("&nbsp;", " "), ("&rsquo;", "\u{2019}"), ("&lsquo;", "\u{2018}"),
            ("&rdquo;", "\u{201D}"), ("&ldquo;", "\u{201C}"),
            ("&mdash;", "\u{2014}"), ("&ndash;", "\u{2013}"),
            ("&hellip;", "\u{2026}"), ("&trade;", "\u{2122}"),
            ("&reg;", "\u{00AE}"), ("&copy;", "\u{00A9}"), ("&frac12;", "½")
        ]
        for (entity, char) in table {
            s = s.replacingOccurrences(of: entity, with: char, options: .caseInsensitive)
        }
        // Numeric decimal &#NNN;
        if let rx = try? NSRegularExpression(pattern: "&#(\\d+);") {
            for m in rx.matches(in: s, range: NSRange(s.startIndex..., in: s)).reversed() {
                guard let r = Range(m.range, in: s),
                      let nr = Range(m.range(at: 1), in: s),
                      let cp = UInt32(s[nr]),
                      let sc = Unicode.Scalar(cp) else { continue }
                s.replaceSubrange(r, with: String(Character(sc)))
            }
        }
        // Numeric hex &#xHH;
        if let rx = try? NSRegularExpression(pattern: "&#x([0-9a-fA-F]+);", options: .caseInsensitive) {
            for m in rx.matches(in: s, range: NSRange(s.startIndex..., in: s)).reversed() {
                guard let r = Range(m.range, in: s),
                      let hr = Range(m.range(at: 1), in: s),
                      let cp = UInt32(s[hr], radix: 16),
                      let sc = Unicode.Scalar(cp) else { continue }
                s.replaceSubrange(r, with: String(Character(sc)))
            }
        }
        return s
    }

    private func parseIngredients(_ ingredientStrings: [String]) -> [ParsedIngredient] {
        return ingredientStrings.compactMap { parseIngredientString(decodeHTMLEntities($0)) }
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
        let raw: [String]
        if let instructions = instructionsData as? [String] {
            raw = instructions
        } else if let instructions = instructionsData as? [[String: Any]] {
            raw = instructions.compactMap { step in
                (step["text"] as? String) ?? (step["name"] as? String)
            }
        } else if let instructionText = instructionsData as? String {
            raw = instructionText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } else {
            return []
        }
        return raw.map { decodeHTMLEntities($0) }.filter { !$0.isEmpty }
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
    override func parseRecipe(from url: URL) async throws -> ParsedRecipe {
        // Try the normal URL first
        if let recipe = try? await super.parseRecipe(from: url) {
            return recipe
        }
        // Fallback: AllRecipes AMP pages are simpler and reliably contain JSON-LD
        if let ampURL = makeAMPURL(from: url) {
            return try await super.parseRecipe(from: ampURL)
        }
        throw RecipeImportError.parsingFailed
    }

    private func makeAMPURL(from url: URL) -> URL? {
        // https://www.allrecipes.com/recipe/236218/... → /amp/recipe/236218/...
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              !url.path.hasPrefix("/amp") else { return nil }
        components.path = "/amp" + url.path
        return components.url
    }
}

class FoodNetworkParser: SchemaOrgParser {
    // FoodNetwork also uses schema.org
    // Add any FoodNetwork-specific parsing here if needed
}