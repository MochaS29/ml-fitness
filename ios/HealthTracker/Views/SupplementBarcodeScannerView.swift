import SwiftUI
import AVFoundation
import Vision

struct SupplementBarcodeScannerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = SupplementBarcodeScanner()
    @State private var scannedSupplement: Supplement?
    @State private var showingSupplementDetail = false
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                SupplementCameraPreview(scanner: scanner)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    // Scanning overlay
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 3)
                        .foregroundColor(.green)
                        .frame(width: 280, height: 200)
                        .overlay(
                            Text("Align barcode within frame")
                                .foregroundColor(.white)
                                .padding(.top, -100)
                        )

                    Spacer()

                    // Bottom info panel
                    VStack(spacing: 16) {
                        if isProcessing {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Looking up supplement...")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }

                        HStack(spacing: 20) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Manual Entry") {
                                // Navigate to manual entry
                                showingSupplementDetail = true
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                scanner.startScanning()
            }
            .onDisappear {
                scanner.stopScanning()
            }
            .onChange(of: scanner.scannedCode) { oldValue, newValue in
                if let code = newValue {
                    handleScannedCode(code)
                }
            }
            .sheet(item: $scannedSupplement) { supplement in
                SupplementDetailView(supplement: supplement) { supplement in
                    saveSupplement(supplement)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingSupplementDetail) {
                ManualSupplementEntryView()
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        isProcessing = true
        errorMessage = nil

        Task {
            do {
                if let supplement = try await BarcodeScannerService.shared.lookupSupplementBarcode(code) {
                    await MainActor.run {
                        self.scannedSupplement = supplement
                        self.isProcessing = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Supplement not found. Try manual entry."
                        self.isProcessing = false

                        // Reset after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.errorMessage = nil
                            self.scanner.scannedCode = nil
                        }
                    }
                }
            }
        }
    }

    private func saveSupplement(_ supplement: Supplement) {
        let entry = SupplementEntry(context: viewContext)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.date = Date()
        entry.name = supplement.name
        entry.brand = supplement.brand
        entry.servingSize = supplement.servingSize
        entry.servingUnit = "serving"
        // barcode field doesn't exist on SupplementEntry

        // Convert supplement nutrients to dictionary for Core Data
        var nutrients: [String: Double] = [:]

        // Add vitamins
        if let va = supplement.vitamins.vitaminA, va.amount > 0 { nutrients["Vitamin A"] = va.amount }
        if let vc = supplement.vitamins.vitaminC, vc.amount > 0 { nutrients["Vitamin C"] = vc.amount }
        if let vd = supplement.vitamins.vitaminD, vd.amount > 0 { nutrients["Vitamin D"] = vd.amount }
        if let ve = supplement.vitamins.vitaminE, ve.amount > 0 { nutrients["Vitamin E"] = ve.amount }
        if let vk = supplement.vitamins.vitaminK, vk.amount > 0 { nutrients["Vitamin K"] = vk.amount }
        if let b1 = supplement.vitamins.vitaminB1_thiamine, b1.amount > 0 { nutrients["Thiamine"] = b1.amount }
        if let b2 = supplement.vitamins.vitaminB2_riboflavin, b2.amount > 0 { nutrients["Riboflavin"] = b2.amount }
        if let b3 = supplement.vitamins.vitaminB3_niacin, b3.amount > 0 { nutrients["Niacin"] = b3.amount }
        if let b6 = supplement.vitamins.vitaminB6, b6.amount > 0 { nutrients["Vitamin B6"] = b6.amount }
        if let b9 = supplement.vitamins.vitaminB9_folate, b9.amount > 0 { nutrients["Folate"] = b9.amount }
        if let b12 = supplement.vitamins.vitaminB12, b12.amount > 0 { nutrients["Vitamin B12"] = b12.amount }
        if let b7 = supplement.vitamins.vitaminB7_biotin, b7.amount > 0 { nutrients["Biotin"] = b7.amount }
        if let b5 = supplement.vitamins.vitaminB5_pantothenicAcid, b5.amount > 0 { nutrients["Pantothenic Acid"] = b5.amount }

        // Add minerals
        if let ca = supplement.minerals.calcium, ca.amount > 0 { nutrients["Calcium"] = ca.amount }
        if let fe = supplement.minerals.iron, fe.amount > 0 { nutrients["Iron"] = fe.amount }
        if let mg = supplement.minerals.magnesium, mg.amount > 0 { nutrients["Magnesium"] = mg.amount }
        if let p = supplement.minerals.phosphorus, p.amount > 0 { nutrients["Phosphorus"] = p.amount }
        if let k = supplement.minerals.potassium, k.amount > 0 { nutrients["Potassium"] = k.amount }
        if let na = supplement.minerals.sodium, na.amount > 0 { nutrients["Sodium"] = na.amount }
        if let zn = supplement.minerals.zinc, zn.amount > 0 { nutrients["Zinc"] = zn.amount }
        if let cu = supplement.minerals.copper, cu.amount > 0 { nutrients["Copper"] = cu.amount }
        if let mn = supplement.minerals.manganese, mn.amount > 0 { nutrients["Manganese"] = mn.amount }
        if let se = supplement.minerals.selenium, se.amount > 0 { nutrients["Selenium"] = se.amount }
        if let cr = supplement.minerals.chromium, cr.amount > 0 { nutrients["Chromium"] = cr.amount }
        if let mo = supplement.minerals.molybdenum, mo.amount > 0 { nutrients["Molybdenum"] = mo.amount }
        if let io = supplement.minerals.iodine, io.amount > 0 { nutrients["Iodine"] = io.amount }

        // Set nutrients directly if not empty
        if !nutrients.isEmpty {
            entry.nutrients = nutrients
        }

        do {
            try viewContext.save()
        } catch {
            print("Error saving supplement: \(error)")
            // Show detailed error info
            if let nsError = error as NSError? {
                print("Core Data Error Code: \(nsError.code)")
                print("Core Data Error Domain: \(nsError.domain)")
                print("Core Data Error Info: \(nsError.userInfo)")
            }
        }
    }
}

// Camera Preview for barcode scanning
struct SupplementCameraPreview: UIViewRepresentable {
    let scanner: SupplementBarcodeScanner

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        scanner.setupCamera(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Barcode Scanner class
class SupplementBarcodeScanner: NSObject, ObservableObject {
    @Published var scannedCode: String?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        checkCameraPermission()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            print("Camera access denied")
        }
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128, .code39, .code93, .upce]
        }
    }

    func setupCamera(in view: UIView) {
        guard let captureSession = captureSession else { return }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill

        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }

    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        captureSession?.stopRunning()
    }
}

extension SupplementBarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let code = readableObject.stringValue else { return }

        // Vibrate to indicate scan
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Publish the scanned code
        scannedCode = code

        // Stop scanning temporarily to avoid multiple reads
        stopScanning()

        // Resume after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if self?.scannedCode == code {
                self?.startScanning()
            }
        }
    }
}

// Supplement Detail View
struct SupplementDetailView: View {
    let supplement: Supplement
    let onSave: (Supplement) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(supplement.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(supplement.brand)
                            .font(.title2)
                            .foregroundColor(.secondary)

                        if let barcode = supplement.barcode {
                            Text("Barcode: \(barcode)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // Serving info
                    HStack {
                        Label("\(supplement.servingSize) per serving", systemImage: "pills")
                        Spacer()
                        if supplement.servingsPerContainer > 0 {
                            Text("\(supplement.servingsPerContainer) servings")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Nutrients
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutritional Information")
                            .font(.headline)

                        // Vitamins
                        if hasVitamins() {
                            Text("Vitamins")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            NutrientGrid(nutrients: getVitaminsList())
                        }

                        // Minerals
                        if hasMinerals() {
                            Text("Minerals")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)

                            NutrientGrid(nutrients: getMineralsList())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onSave(supplement)
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func hasVitamins() -> Bool {
        let v = supplement.vitamins
        return (v.vitaminA?.amount ?? 0) > 0 || (v.vitaminC?.amount ?? 0) > 0 ||
               (v.vitaminD?.amount ?? 0) > 0 || (v.vitaminE?.amount ?? 0) > 0 ||
               (v.vitaminK?.amount ?? 0) > 0 || (v.vitaminB1_thiamine?.amount ?? 0) > 0 ||
               (v.vitaminB2_riboflavin?.amount ?? 0) > 0 || (v.vitaminB3_niacin?.amount ?? 0) > 0 ||
               (v.vitaminB6?.amount ?? 0) > 0 || (v.vitaminB9_folate?.amount ?? 0) > 0 ||
               (v.vitaminB12?.amount ?? 0) > 0 || (v.vitaminB7_biotin?.amount ?? 0) > 0 ||
               (v.vitaminB5_pantothenicAcid?.amount ?? 0) > 0
    }

    private func hasMinerals() -> Bool {
        let m = supplement.minerals
        return (m.calcium?.amount ?? 0) > 0 || (m.iron?.amount ?? 0) > 0 ||
               (m.magnesium?.amount ?? 0) > 0 || (m.phosphorus?.amount ?? 0) > 0 ||
               (m.potassium?.amount ?? 0) > 0 || (m.sodium?.amount ?? 0) > 0 ||
               (m.zinc?.amount ?? 0) > 0 || (m.copper?.amount ?? 0) > 0 ||
               (m.manganese?.amount ?? 0) > 0 || (m.selenium?.amount ?? 0) > 0 ||
               (m.chromium?.amount ?? 0) > 0 || (m.molybdenum?.amount ?? 0) > 0 ||
               (m.iodine?.amount ?? 0) > 0
    }

    private func getVitaminsList() -> [(name: String, amount: Double, unit: String)] {
        var nutrients: [(String, Double, String)] = []
        let v = supplement.vitamins

        if let va = v.vitaminA, va.amount > 0 { nutrients.append(("Vitamin A", va.amount, va.unit)) }
        if let vc = v.vitaminC, vc.amount > 0 { nutrients.append(("Vitamin C", vc.amount, vc.unit)) }
        if let vd = v.vitaminD, vd.amount > 0 { nutrients.append(("Vitamin D", vd.amount, vd.unit)) }
        if let ve = v.vitaminE, ve.amount > 0 { nutrients.append(("Vitamin E", ve.amount, ve.unit)) }
        if let vk = v.vitaminK, vk.amount > 0 { nutrients.append(("Vitamin K", vk.amount, vk.unit)) }
        if let b1 = v.vitaminB1_thiamine, b1.amount > 0 { nutrients.append(("Thiamine", b1.amount, b1.unit)) }
        if let b2 = v.vitaminB2_riboflavin, b2.amount > 0 { nutrients.append(("Riboflavin", b2.amount, b2.unit)) }
        if let b3 = v.vitaminB3_niacin, b3.amount > 0 { nutrients.append(("Niacin", b3.amount, b3.unit)) }
        if let b6 = v.vitaminB6, b6.amount > 0 { nutrients.append(("Vitamin B6", b6.amount, b6.unit)) }
        if let b9 = v.vitaminB9_folate, b9.amount > 0 { nutrients.append(("Folate", b9.amount, b9.unit)) }
        if let b12 = v.vitaminB12, b12.amount > 0 { nutrients.append(("Vitamin B12", b12.amount, b12.unit)) }
        if let b7 = v.vitaminB7_biotin, b7.amount > 0 { nutrients.append(("Biotin", b7.amount, b7.unit)) }
        if let b5 = v.vitaminB5_pantothenicAcid, b5.amount > 0 { nutrients.append(("Pantothenic Acid", b5.amount, b5.unit)) }

        return nutrients
    }

    private func getMineralsList() -> [(name: String, amount: Double, unit: String)] {
        var nutrients: [(String, Double, String)] = []
        let m = supplement.minerals

        if let ca = m.calcium, ca.amount > 0 { nutrients.append(("Calcium", ca.amount, ca.unit)) }
        if let fe = m.iron, fe.amount > 0 { nutrients.append(("Iron", fe.amount, fe.unit)) }
        if let mg = m.magnesium, mg.amount > 0 { nutrients.append(("Magnesium", mg.amount, mg.unit)) }
        if let p = m.phosphorus, p.amount > 0 { nutrients.append(("Phosphorus", p.amount, p.unit)) }
        if let k = m.potassium, k.amount > 0 { nutrients.append(("Potassium", k.amount, k.unit)) }
        if let na = m.sodium, na.amount > 0 { nutrients.append(("Sodium", na.amount, na.unit)) }
        if let zn = m.zinc, zn.amount > 0 { nutrients.append(("Zinc", zn.amount, zn.unit)) }
        if let cu = m.copper, cu.amount > 0 { nutrients.append(("Copper", cu.amount, cu.unit)) }
        if let mn = m.manganese, mn.amount > 0 { nutrients.append(("Manganese", mn.amount, mn.unit)) }
        if let se = m.selenium, se.amount > 0 { nutrients.append(("Selenium", se.amount, se.unit)) }
        if let cr = m.chromium, cr.amount > 0 { nutrients.append(("Chromium", cr.amount, cr.unit)) }
        if let mo = m.molybdenum, mo.amount > 0 { nutrients.append(("Molybdenum", mo.amount, mo.unit)) }
        if let io = m.iodine, io.amount > 0 { nutrients.append(("Iodine", io.amount, io.unit)) }

        return nutrients
    }
}

struct NutrientGrid: View {
    let nutrients: [(name: String, amount: Double, unit: String)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(nutrients, id: \.name) { nutrient in
                HStack {
                    Text(nutrient.name)
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(String(format: "%.1f", nutrient.amount)) \(nutrient.unit)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
}