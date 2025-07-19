import SwiftUI
import Vision
import VisionKit

struct SupplementTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    @State private var scannedImage: UIImage?
    @State private var extractedNutrients: [ExtractedNutrient] = []
    @State private var isProcessing = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        animation: .default)
    private var supplements: FetchedResults<SupplementEntry>
    
    var body: some View {
        NavigationView {
            VStack {
                if supplements.isEmpty {
                    EmptySupplementsView(
                        showingScanner: $showingScanner,
                        showingManualEntry: $showingManualEntry
                    )
                } else {
                    List {
                        Section {
                            HStack {
                                Button(action: { showingScanner = true }) {
                                    Label("Scan Label", systemImage: "camera.viewfinder")
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button(action: { showingManualEntry = true }) {
                                    Label("Manual Entry", systemImage: "plus.circle")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        Section("Today's Supplements") {
                            ForEach(todaysSupplements) { supplement in
                                SupplementRow(supplement: supplement)
                            }
                            .onDelete(perform: deleteSupplements)
                        }
                        
                        if !olderSupplements.isEmpty {
                            Section("Previous Days") {
                                ForEach(olderSupplements) { supplement in
                                    SupplementRow(supplement: supplement)
                                }
                                .onDelete(perform: deleteSupplements)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Supplements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Analysis") {
                        // Show nutrient analysis
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView(scannedImage: $scannedImage)
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualSupplementEntryView()
            }
            .onChange(of: scannedImage) { oldValue, newValue in
                if let image = newValue {
                    processScannedImage(image)
                }
            }
        }
    }
    
    var todaysSupplements: [SupplementEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return supplements.filter { supplement in
            guard let timestamp = supplement.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    var olderSupplements: [SupplementEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return supplements.filter { supplement in
            guard let timestamp = supplement.timestamp else { return false }
            return !calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    func deleteSupplements(offsets: IndexSet) {
        withAnimation {
            offsets.map { supplements[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting supplement: \(error)")
            }
        }
    }
    
    func processScannedImage(_ image: UIImage) {
        isProcessing = true
        
        let textRecognizer = TextRecognizer()
        textRecognizer.recognizeText(in: image) { recognizedText in
            DispatchQueue.main.async {
                self.extractedNutrients = NutrientExtractor.extractNutrients(from: recognizedText)
                self.isProcessing = false
                self.showingScanner = false
                
                if !self.extractedNutrients.isEmpty {
                    self.showingManualEntry = true
                }
            }
        }
    }
}

struct EmptySupplementsView: View {
    @Binding var showingScanner: Bool
    @Binding var showingManualEntry: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "pills")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Supplements Tracked")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your vitamins and supplements to monitor your nutrient intake")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                Button(action: { showingScanner = true }) {
                    Label("Scan Supplement Label", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: { showingManualEntry = true }) {
                    Label("Manual Entry", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct SupplementRow: View {
    let supplement: SupplementEntry
    
    var nutrientCount: Int {
        // The nutrients property is already transformed by Core Data using NSSecureUnarchiveFromData
        if let nutrientDict = supplement.nutrients {
            return nutrientDict.count
        }
        return 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(supplement.name ?? "Unknown Supplement")
                    .font(.headline)
                
                HStack {
                    if let brand = supplement.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("• \(nutrientCount) nutrients")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let timestamp = supplement.timestamp {
                Text(timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            parent.scannedImage = scan.imageOfPage(at: 0)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class TextRecognizer {
    func recognizeText(in image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion("")
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform text recognition: \(error)")
            completion("")
        }
    }
}

struct ExtractedNutrient {
    let name: String
    let amount: Double
    let unit: String
}

struct NutrientExtractor {
    static func extractNutrients(from text: String) -> [ExtractedNutrient] {
        var nutrients: [ExtractedNutrient] = []
        let lines = text.components(separatedBy: .newlines)
        
        // Common nutrient patterns
        let patterns = [
            // Pattern: Vitamin C 1000mg
            "([A-Za-z\\s]+?)\\s*(\\d+(?:\\.\\d+)?)\\s*(mg|mcg|iu|g)",
            // Pattern: Vitamin C (as Ascorbic Acid) 1000 mg
            "([A-Za-z\\s]+?)\\s*\\([^)]+\\)\\s*(\\d+(?:\\.\\d+)?)\\s*(mg|mcg|iu|g)",
            // Pattern: Vitamin C: 1000mg
            "([A-Za-z\\s]+?):\\s*(\\d+(?:\\.\\d+)?)\\s*(mg|mcg|iu|g)"
        ]
        
        for line in lines {
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                    
                    let nutrientRange = Range(match.range(at: 1), in: line)
                    let amountRange = Range(match.range(at: 2), in: line)
                    let unitRange = Range(match.range(at: 3), in: line)
                    
                    if let nutrientRange = nutrientRange,
                       let amountRange = amountRange,
                       let unitRange = unitRange,
                       let amount = Double(line[amountRange]) {
                        
                        let nutrient = ExtractedNutrient(
                            name: String(line[nutrientRange]).trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            unit: String(line[unitRange]).lowercased()
                        )
                        nutrients.append(nutrient)
                        break // Move to next line after finding a match
                    }
                }
            }
        }
        
        return nutrients
    }
}