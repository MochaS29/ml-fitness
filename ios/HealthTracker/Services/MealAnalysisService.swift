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
    var name: String
    var quantity: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
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

    // Meal-scan goes through the Vercel proxy at mochasmindlab.com/api/v1/meal-scan.
    // The Anthropic key lives in the proxy's env vars, not in the app binary.
    // Apps authenticate to the proxy with APP_SHARED_SECRET + a per-install UUID.
    private let proxyEndpoint = SecretsManager.mealScanEndpoint
    private let appSharedSecret = SecretsManager.appSharedSecret

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
        // Proxy expects a minimal body — image only. Prompt + model selection
        // are owned by the proxy so they can be tuned server-side without app
        // updates. See Web-Projects/mochamindlabs-website/api/v1/meal-scan.js.
        let requestBody: [String: Any] = [
            "image": base64Image
        ]

        guard let url = URL(string: proxyEndpoint) else {
            completion(.failure(AnalysisError.networkError))
            return
        }
        guard !appSharedSecret.isEmpty else {
            completion(.failure(AnalysisError.apiKeyMissing))
            isAnalyzing = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(appSharedSecret, forHTTPHeaderField: "X-App-Secret")
        request.setValue(SecretsManager.installId, forHTTPHeaderField: "X-Install-Id")
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

                // Map proxy HTTP status to friendly errors before attempting to
                // parse — a 401/429 body won't look like an Anthropic response.
                if let http = response as? HTTPURLResponse {
                    switch http.statusCode {
                    case 200...299:
                        break
                    case 401:
                        completion(.failure(AnalysisError.apiKeyMissing))
                        return
                    case 429:
                        completion(.failure(AnalysisError.quotaExceeded))
                        return
                    default:
                        completion(.failure(AnalysisError.invalidResponse))
                        return
                    }
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
        // Debug: print raw response
        if let rawString = String(data: data, encoding: .utf8) {
            print("🔍 Claude raw response:\n\(rawString)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Check for API error
        if let errorInfo = json?["error"] as? [String: Any],
           let errorMessage = errorInfo["message"] as? String {
            print("❌ Claude API Error: \(errorMessage)")
            throw AnalysisError.invalidResponse
        }

        guard let content = json?["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            print("❌ Could not extract text from Claude response. Keys: \(json?.keys.joined(separator: ", ") ?? "none")")
            throw AnalysisError.invalidResponse
        }

        // Extract JSON from the response (Claude might include extra text)
        print("📝 Claude text response:\n\(text)")
        let jsonString = extractJSON(from: text)
        print("📦 Extracted JSON:\n\(jsonString)")

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AnalysisError.invalidResponse
        }

        do {
            let analysis = try JSONDecoder().decode(MealAnalysis.self, from: jsonData)
            return analysis
        } catch {
            print("❌ Decode error: \(error)")
            throw error
        }
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
        try saveAnalysisToFoodEntry(items: analysis.items, mealType: mealType, context: context)
    }

    func saveAnalysisToFoodEntry(items: [DetectedFood], mealType: MealType, context: NSManagedObjectContext) throws {
        for item in items {
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
        ReviewRequestManager.shared.recordMealScanned()
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
