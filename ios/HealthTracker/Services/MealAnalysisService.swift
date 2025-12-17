import Foundation
import UIKit
import CoreData

// MARK: - Models

struct MealAnalysis: Codable {
    let items: [DetectedFood]
    let totalCalories: Int
    let confidence: Double
    let imageId: String?
}

struct DetectedFood: Codable, Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let confidence: Double
    let boundingBox: CGRect?

    enum CodingKeys: String, CodingKey {
        case name, quantity, calories, protein, carbs, fat, fiber, confidence, boundingBox
    }
}

// MARK: - API Service

class MealAnalysisService: ObservableObject {
    static let shared = MealAnalysisService()

    @Published var isAnalyzing = false
    @Published var lastAnalysis: MealAnalysis?

    // API Configuration (You'll set your API key here)
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    private let apiEndpoint = "https://api.openai.com/v1/chat/completions"

    // Alternative: Use a local config file
    private var apiConfig: APIConfig {
        // Store API key in a plist or keychain for production
        return APIConfig.load()
    }

    private init() {}

    // MARK: - Main Analysis Function

    func analyzeMealPhoto(_ image: UIImage, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        isAnalyzing = true

        // Resize image to optimize API calls
        let resizedImage = resizeImage(image, maxDimension: 1024)

        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(AnalysisError.imageProcessingFailed))
            isAnalyzing = false
            return
        }

        let base64String = imageData.base64EncodedString()

        // Call Vision API
        analyzeWithOpenAI(base64Image: base64String, completion: completion)
    }

    // MARK: - OpenAI Vision API

    private func analyzeWithOpenAI(base64Image: String, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        let prompt = """
        Analyze this food image and identify all food items. For each item provide:
        1. Food name
        2. Estimated quantity/portion size
        3. Estimated calories
        4. Estimated macros (protein, carbs, fat in grams)
        5. Confidence level (0-1)

        Return response as JSON:
        {
            "items": [
                {
                    "name": "food name",
                    "quantity": "portion description",
                    "calories": 0,
                    "protein": 0,
                    "carbs": 0,
                    "fat": 0,
                    "fiber": 0,
                    "confidence": 0.0
                }
            ],
            "totalCalories": 0,
            "confidence": 0.0
        }
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]

        var request = URLRequest(url: URL(string: apiEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(AnalysisError.noData))
                    return
                }

                do {
                    let result = try self?.parseOpenAIResponse(data)
                    if let analysis = result {
                        self?.lastAnalysis = analysis
                        completion(.success(analysis))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Alternative: Nutritionix API

    func analyzeWithNutritionix(base64Image: String, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        // Nutritionix has a specific food recognition endpoint
        let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("YOUR_APP_ID", forHTTPHeaderField: "x-app-id")
        request.setValue("YOUR_APP_KEY", forHTTPHeaderField: "x-app-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Nutritionix expects a query string, not an image
        // You'd need to use their visual search endpoint
        // This is a simplified example

        let body = ["query": "1 cup rice, grilled chicken breast, steamed broccoli"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Parse Nutritionix response
            // Similar to OpenAI parsing
        }.resume()
    }

    // MARK: - Alternative: Clarifai Food Model

    func analyzeWithClarifai(base64Image: String, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        let url = URL(string: "https://api.clarifai.com/v2/models/food-item-recognition/outputs")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key YOUR_CLARIFAI_KEY", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "inputs": [
                ["data": ["image": ["base64": base64Image]]]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Parse Clarifai response
            // Convert to MealAnalysis format
        }.resume()
    }

    // MARK: - Response Parsing

    private func parseOpenAIResponse(_ data: Data) throws -> MealAnalysis {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AnalysisError.invalidResponse
        }

        // Extract JSON from the response
        let jsonData = content.data(using: .utf8)!
        let analysis = try JSONDecoder().decode(MealAnalysis.self, from: jsonData)

        return analysis
    }

    // MARK: - Helper Functions

    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return resizedImage
    }

    // MARK: - Save to Core Data

    func saveAnalysisToFoodEntry(analysis: MealAnalysis, image: UIImage?, context: NSManagedObjectContext) {
        for item in analysis.items {
            let entry = FoodEntry(context: context)
            entry.id = UUID()
            entry.name = item.name
            entry.calories = item.calories
            entry.protein = item.protein
            entry.carbs = item.carbs
            entry.fat = item.fat
            entry.fiber = item.fiber ?? 0
            entry.timestamp = Date()
            entry.date = Date()
            entry.servingSize = item.quantity
            entry.servingUnit = "serving"
            // Note: isFromPhoto, aiConfidence, and photoData fields can be added to Core Data model later
        }

        do {
            try context.save()
        } catch {
            print("Error saving meal analysis: \(error)")
        }
    }
}

// MARK: - Error Types

enum AnalysisError: LocalizedError {
    case imageProcessingFailed
    case noData
    case invalidResponse
    case apiKeyMissing
    case quotaExceeded
    case networkError

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response format"
        case .apiKeyMissing:
            return "API key not configured"
        case .quotaExceeded:
            return "API quota exceeded"
        case .networkError:
            return "Network connection error"
        }
    }
}

// MARK: - API Configuration

struct APIConfig: Codable {
    let openAIKey: String?
    let nutritionixAppId: String?
    let nutritionixAppKey: String?
    let clarifaiKey: String?
    let selectedProvider: APIProvider

    enum APIProvider: String, Codable {
        case openAI = "openai"
        case nutritionix = "nutritionix"
        case clarifai = "clarifai"
        case googleVision = "google"
    }

    static func load() -> APIConfig {
        // Load from UserDefaults or Keychain
        // For development, you can hardcode here
        return APIConfig(
            openAIKey: "sk-...", // Add your key here
            nutritionixAppId: nil,
            nutritionixAppKey: nil,
            clarifaiKey: nil,
            selectedProvider: .openAI
        )
    }
}