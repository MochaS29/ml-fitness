import Foundation
import AVFoundation
import Vision

// Service for barcode scanning and food database lookup
class BarcodeScannerService: NSObject, ObservableObject {
    static let shared = BarcodeScannerService()
    
    @Published var scannedBarcode: String?
    @Published var isScanning = false
    @Published var scanError: ScanError?
    
    enum ScanError: LocalizedError {
        case cameraAccessDenied
        case invalidBarcode
        case lookupFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .cameraAccessDenied:
                return "Camera access is required to scan barcodes"
            case .invalidBarcode:
                return "Invalid barcode format"
            case .lookupFailed(let message):
                return "Failed to lookup product: \(message)"
            }
        }
    }
    
    // Mock database - In production, this would connect to APIs like Open Food Facts or USDA
    private let mockFoodDatabase: [String: FoodProduct] = [
        "038000845512": FoodProduct(
            barcode: "038000845512",
            name: "Kellogg's Corn Flakes",
            brand: "Kellogg's",
            servingSize: "1 cup (28g)",
            calories: 100,
            protein: 2,
            carbs: 24,
            fat: 0,
            fiber: 1,
            sugar: 3,
            sodium: 200
        ),
        "070038639244": FoodProduct(
            barcode: "070038639244",
            name: "Nature Valley Granola Bars",
            brand: "Nature Valley",
            servingSize: "1 bar (21g)",
            calories: 90,
            protein: 1,
            carbs: 14,
            fat: 3.5,
            fiber: 1,
            sugar: 6,
            sodium: 90
        ),
        "0000000013529": FoodProduct(
            barcode: "0000000013529",
            name: "Banana",
            brand: "Fresh Produce",
            servingSize: "1 medium (118g)",
            calories: 105,
            protein: 1.3,
            carbs: 27,
            fat: 0.4,
            fiber: 3.1,
            sugar: 14.4,
            sodium: 1
        ),
        "078742058276": FoodProduct(
            barcode: "078742058276",
            name: "Greek Yogurt Plain",
            brand: "Great Value",
            servingSize: "1 container (170g)",
            calories: 100,
            protein: 17,
            carbs: 6,
            fat: 0,
            fiber: 0,
            sugar: 5,
            sodium: 60
        ),
        "016000288706": FoodProduct(
            barcode: "016000288706",
            name: "Cheerios",
            brand: "General Mills",
            servingSize: "1 cup (28g)",
            calories: 100,
            protein: 3,
            carbs: 20,
            fat: 2,
            fiber: 3,
            sugar: 1,
            sodium: 140
        )
    ]
    
    private override init() {
        super.init()
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    func lookupBarcode(_ barcode: String) async throws -> FoodProduct {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Check mock database first
        if let product = mockFoodDatabase[barcode] {
            return product
        }

        // In production, make API call here
        // For now, try to extract info from barcode if not in database
        if barcode.count >= 12 {
            // Generate a generic product for demo
            return FoodProduct(
                barcode: barcode,
                name: "Unknown Product",
                brand: "Generic",
                servingSize: "1 serving",
                calories: 100,
                protein: 2,
                carbs: 20,
                fat: 3,
                fiber: 1,
                sugar: 5,
                sodium: 150
            )
        }

        throw ScanError.lookupFailed("Product not found in database")
    }

    func lookupSupplementBarcode(_ barcode: String) async throws -> Supplement? {
        // First check if it's a supplement by barcode
        if let supplement = SupplementDatabase.shared.searchByBarcode(barcode) {
            return supplement
        }

        // Check by DPN if it's a Canadian format (8 digits)
        if barcode.count == 8, let supplement = SupplementDatabase.shared.searchByDPN(barcode) {
            return supplement
        }

        // In production, make API call to supplement databases
        // For now, return nil if not found
        return nil
    }
    
    func processBarcode(_ barcode: String) {
        scannedBarcode = barcode
        isScanning = false
    }
}

struct FoodProduct {
    let barcode: String
    let name: String
    let brand: String
    let servingSize: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    
    var displayName: String {
        return "\(brand) \(name)"
    }
}