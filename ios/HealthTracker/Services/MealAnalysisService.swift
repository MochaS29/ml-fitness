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

    // Anthropic Claude API Configuration
    private let anthropicApiKey = SecretsManager.anthropicAPIKey
    private let anthropicEndpoint = "https://api.anthropic.com/v1/messages"

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

        // Call Claude Vision API
        analyzeWithClaude(base64Image: base64String, completion: completion)
    }

    // MARK: - Claude Vision API

    private func analyzeWithClaude(base64Image: String, completion: @escaping (Result<MealAnalysis, Error>) -> Void) {
        let prompt = """
        Analyze this food image and identify all food items. For each item provide:
        1. Food name
        2. Estimated quantity/portion size
        3. Estimated calories
        4. Estimated macros (protein, carbs, fat in grams)
        5. Confidence level (0-1)

        Return ONLY valid JSON with no other text, in this exact format:
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
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        guard let url = URL(string: anthropicEndpoint) else {
            completion(.failure(AnalysisError.networkError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anthropicApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
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
                    let result = try self?.parseClaudeResponse(data)
                    if let analysis = result {
                        self?.lastAnalysis = analysis
                        completion(.success(analysis))
                    }
                } catch {
                    print("Parse error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Response Parsing

    private func parseClaudeResponse(_ data: Data) throws -> MealAnalysis {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Check for API error
        if let errorInfo = json?["error"] as? [String: Any],
           let errorMessage = errorInfo["message"] as? String {
            print("Claude API Error: \(errorMessage)")
            throw AnalysisError.invalidResponse
        }

        guard let content = json?["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            print("Could not extract text from Claude response")
            throw AnalysisError.invalidResponse
        }

        // Extract JSON from the response (Claude might include extra text)
        let jsonString = extractJSON(from: text)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AnalysisError.invalidResponse
        }

        let analysis = try JSONDecoder().decode(MealAnalysis.self, from: jsonData)
        return analysis
    }

    // Helper to extract JSON from Claude's response
    private func extractJSON(from text: String) -> String {
        // Try to find JSON object in the response
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            return String(text[startIndex...endIndex])
        }
        return text
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

    func saveAnalysisToFoodEntry(analysis: MealAnalysis, image: UIImage?, mealType: MealType, context: NSManagedObjectContext) throws {
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
            entry.mealType = mealType.rawValue
        }

        try context.save()
        UnifiedDataManager.shared.refreshAllData()
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
