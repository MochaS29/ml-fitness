import SwiftUI
import AVFoundation
import Vision

struct SupplementBarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var barcodeService = SupplementBarcodeService.shared
    @StateObject private var scanner = BarcodeScanner()

    @State private var scannedSupplement: SupplementBarcodeService.SupplementInfo?
    @State private var showingManualEntry = false
    @State private var showingNotFoundAlert = false
    @State private var lastScannedBarcode: String?
    @State private var servingCount = 1

    var body: some View {
        NavigationView {
            ZStack {
                // Camera View
                BarcodeCameraView(scanner: scanner)
                    .ignoresSafeArea()

                // Overlay
                VStack {
                    // Top bar
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Spacer()

                        Button("Enter Manually") {
                            showingManualEntry = true
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()

                    Spacer()

                    // Scanning frame
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 280, height: 200)
                        .overlay(
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.3))
                        )

                    // Instructions
                    Text("Position barcode within frame")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.top)

                    Spacer()

                    // Loading indicator
                    if barcodeService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
            }
            .navigationBarHidden(true)
            .onReceive(scanner.$lastScannedCode) { barcode in
                if let barcode = barcode, barcode != lastScannedBarcode {
                    lastScannedBarcode = barcode
                    lookupBarcode(barcode)
                }
            }
            .sheet(item: $scannedSupplement) { supplement in
                SupplementDetailsView(
                    supplement: supplement,
                    servingCount: $servingCount,
                    onSave: { saveSupplement(supplement) },
                    onCancel: {
                        scannedSupplement = nil
                        scanner.resumeScanning()
                    }
                )
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualSupplementEntryView()
            }
            .alert("Supplement Not Found", isPresented: $showingNotFoundAlert) {
                Button("Try Again") {
                    scanner.resumeScanning()
                }
                Button("Enter Manually") {
                    showingManualEntry = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This barcode wasn't found in our database. You can try scanning again or enter the supplement information manually.")
            }
        }
    }

    private func lookupBarcode(_ barcode: String) {
        Task {
            do {
                // Use enhanced database service that includes scraped data
                let databaseService = SupplementDatabaseService.shared
                if let supplement = try await databaseService.lookupSupplement(barcode: barcode) {
                    await MainActor.run {
                        scanner.stopScanning()
                        scannedSupplement = supplement
                    }
                } else {
                    await MainActor.run {
                        showingNotFoundAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    showingNotFoundAlert = true
                }
            }
        }
    }

    private func saveSupplement(_ supplement: SupplementBarcodeService.SupplementInfo) {
        let entry = SupplementEntry(context: viewContext)
        entry.id = UUID()
        entry.name = supplement.name
        entry.brand = supplement.brand
        entry.servingSize = supplement.servingSize
        entry.servingUnit = supplement.servingUnit ?? "serving"
        entry.servingCount = Int16(servingCount)
        entry.barcode = supplement.barcode
        entry.timestamp = Date()

        // Save nutrients as JSON in notes field for now
        if !supplement.nutrients.isEmpty {
            let nutrientData = supplement.nutrients.map { nutrient in
                "\(nutrient.name): \(nutrient.amount)\(nutrient.unit)"
            }.joined(separator: ", ")
            entry.notes = nutrientData
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving supplement: \(error)")
        }
    }
}

// MARK: - Scanner Camera View

struct BarcodeCameraView: UIViewControllerRepresentable {
    let scanner: BarcodeScanner

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.scanner = scanner
        return controller
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
    }
}

// MARK: - Barcode Scanner View Controller

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var scanner: BarcodeScanner?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
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

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        scanner?.captureSession = captureSession

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            // Vibrate on scan
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            scanner?.lastScannedCode = stringValue
        }
    }
}

// MARK: - Barcode Scanner Class

class BarcodeScanner: ObservableObject {
    @Published var lastScannedCode: String?
    weak var captureSession: AVCaptureSession?

    func stopScanning() {
        captureSession?.stopRunning()
    }

    func resumeScanning() {
        lastScannedCode = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
}

// MARK: - Supplement Details View

struct SupplementDetailsView: View {
    let supplement: SupplementBarcodeService.SupplementInfo
    @Binding var servingCount: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Product Image
                    if let imageURL = supplement.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                    }

                    // Product Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(supplement.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let brand = supplement.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Image(systemName: "barcode")
                            Text(supplement.barcode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if supplement.source == .openFoodFacts {
                            Label("Data from Open Food Facts", systemImage: "info.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    Divider()

                    // Serving Size
                    HStack {
                        Text("Serving Size:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(supplement.servingSize ?? "1") \(supplement.servingUnit ?? "serving")")
                    }

                    // Serving Count Selector
                    HStack {
                        Text("Number of Servings:")
                            .fontWeight(.semibold)
                        Spacer()
                        Stepper("\(servingCount)", value: $servingCount, in: 1...10)
                    }

                    if !supplement.nutrients.isEmpty {
                        Divider()

                        // Nutrients
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nutritional Information")
                                .font(.headline)

                            ForEach(supplement.nutrients, id: \.name) { nutrient in
                                HStack {
                                    Text(nutrient.name)
                                    Spacer()
                                    Text("\(Int(nutrient.amount))\(nutrient.unit)")
                                        .foregroundColor(.secondary)
                                    if let dv = nutrient.dailyValue {
                                        Text("(\(Int(dv))% DV)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if let ingredients = supplement.ingredients {
                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.headline)
                            Text(ingredients)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Supplement Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Make supplement info identifiable for sheet presentation
extension SupplementBarcodeService.SupplementInfo: Identifiable {
    var id: String { barcode }
}