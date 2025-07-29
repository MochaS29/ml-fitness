import SwiftUI
import AVFoundation
import Vision
import CoreData

struct BarcodeScannerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = BarcodeScannerService.shared
    @State private var scannedProduct: FoodProduct?
    @State private var showingProductDetails = false
    @State private var showingError = false
    @State private var isLoading = false
    @State private var servingMultiplier: Double = 1.0
    
    let selectedDate: Date
    let mealType: MealType?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera view
                CameraPreview(scannerService: scanner)
                    .ignoresSafeArea()
                
                // Scanning overlay
                VStack {
                    Spacer()
                    
                    // Scanning frame
                    Rectangle()
                        .stroke(Color.wellnessGreen, lineWidth: 3)
                        .frame(width: 250, height: 150)
                        .overlay(
                            VStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                } else {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                            }
                        )
                    
                    Text(isLoading ? "Looking up product..." : "Align barcode within frame")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Manual entry button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Enter Manually")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: scanner.scannedBarcode) { _, barcode in
                if let barcode = barcode {
                    handleScannedBarcode(barcode)
                }
            }
            .sheet(isPresented: $showingProductDetails) {
                if let product = scannedProduct {
                    ProductDetailsView(
                        product: product,
                        servingMultiplier: $servingMultiplier,
                        onSave: { saveProductToFoodEntry(product) },
                        onCancel: {
                            // Reset scanner
                            scanner.scannedBarcode = nil
                            scanner.isScanning = true
                        }
                    )
                }
            }
            .alert("Scan Error", isPresented: $showingError) {
                Button("OK") {
                    scanner.scannedBarcode = nil
                    scanner.isScanning = true
                }
            } message: {
                Text(scanner.scanError?.localizedDescription ?? "Unknown error occurred")
            }
        }
        .onAppear {
            scanner.checkCameraPermission { granted in
                if granted {
                    scanner.isScanning = true
                } else {
                    scanner.scanError = .cameraAccessDenied
                    showingError = true
                }
            }
        }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isLoading = true
        
        Task {
            do {
                let product = try await scanner.lookupBarcode(barcode)
                await MainActor.run {
                    self.scannedProduct = product
                    self.showingProductDetails = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.scanner.scanError = error as? BarcodeScannerService.ScanError ?? .lookupFailed(error.localizedDescription)
                    self.showingError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveProductToFoodEntry(_ product: FoodProduct) {
        let entry = FoodEntry(context: viewContext)
        entry.id = UUID()
        entry.name = product.displayName
        entry.calories = product.calories * servingMultiplier
        entry.protein = product.protein * servingMultiplier
        entry.carbs = product.carbs * servingMultiplier
        entry.fat = product.fat * servingMultiplier
        entry.fiber = product.fiber * servingMultiplier
        entry.sugar = product.sugar * servingMultiplier
        entry.sodium = product.sodium * servingMultiplier
        entry.timestamp = selectedDate
        entry.mealType = mealType?.rawValue ?? MealType.snack.rawValue
        entry.barcode = product.barcode
        entry.servingSize = product.servingSize
        entry.servingCount = servingMultiplier
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving food entry: \(error)")
        }
    }
}

struct ProductDetailsView: View {
    let product: FoodProduct
    @Binding var servingMultiplier: Double
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Product header
                VStack(spacing: 8) {
                    Text(product.brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(product.servingSize)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Serving adjuster
                VStack(spacing: 12) {
                    Text("Number of Servings")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if servingMultiplier > 0.25 {
                                servingMultiplier -= 0.25
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.wellnessGreen)
                        }
                        
                        Text(String(format: "%.2f", servingMultiplier))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(minWidth: 60)
                        
                        Button(action: {
                            servingMultiplier += 0.25
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.wellnessGreen)
                        }
                    }
                }
                .padding()
                .background(Color.lightGray.opacity(0.1))
                .cornerRadius(10)
                
                // Nutrition facts
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nutrition Facts")
                        .font(.headline)
                    
                    NutritionRow(label: "Calories", value: product.calories * servingMultiplier, unit: "")
                    NutritionRow(label: "Protein", value: product.protein * servingMultiplier, unit: "g")
                    NutritionRow(label: "Carbohydrates", value: product.carbs * servingMultiplier, unit: "g")
                    NutritionRow(label: "Fat", value: product.fat * servingMultiplier, unit: "g")
                    NutritionRow(label: "Fiber", value: product.fiber * servingMultiplier, unit: "g")
                    NutritionRow(label: "Sugar", value: product.sugar * servingMultiplier, unit: "g")
                    NutritionRow(label: "Sodium", value: product.sodium * servingMultiplier, unit: "mg")
                }
                .padding()
                .background(Color.lightGray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("Scan Another")
                            .fontWeight(.medium)
                            .foregroundColor(.wellnessGreen)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.wellnessGreen, lineWidth: 2)
                            )
                    }
                    
                    Button(action: onSave) {
                        Text("Add to Diary")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(String(format: "%.1f", value))\(unit)")
                .fontWeight(.medium)
        }
    }
}

// Camera preview for barcode scanning
struct CameraPreview: UIViewControllerRepresentable {
    let scannerService: BarcodeScannerService
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.scannerService = scannerService
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // Update if needed
    }
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var scannerService: BarcodeScannerService?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128, .code39, .upce]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Only process if scanner is actively scanning
            if scannerService?.isScanning == true {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                scannerService?.processBarcode(stringValue)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

#Preview {
    BarcodeScannerView(selectedDate: Date(), mealType: .lunch)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}