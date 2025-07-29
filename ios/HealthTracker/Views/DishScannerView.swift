import SwiftUI
import AVFoundation
import Vision
import PhotosUI

struct DishScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var showingResults = false
    @State private var scanResults: FoodScanResult?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let image = capturedImage {
                    // Show captured image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                    
                    if isProcessing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing dish...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                } else {
                    // Camera preview placeholder
                    ZStack {
                        Rectangle()
                            .fill(Color(UIColor.systemGray6))
                            .aspectRatio(4/3, contentMode: .fit)
                            .cornerRadius(12)
                        
                        VStack(spacing: 20) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(UIColor.systemGray3))
                            
                            Text("Take a photo of your dish")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Get instant nutrition information")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    if capturedImage == nil {
                        Button(action: { showingCamera = true }) {
                            Label("Take Photo", systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showingImagePicker = true }) {
                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 127/255, green: 176/255, blue: 105/255), lineWidth: 2)
                                )
                        }
                    } else if !isProcessing {
                        Button(action: analyzeDish) {
                            Label("Analyze Dish", systemImage: "wand.and.stars")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                                .cornerRadius(12)
                        }
                        
                        Button(action: { capturedImage = nil }) {
                            Text("Retake Photo")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Scan Dish")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingCamera) {
                CameraCaptureView(image: $capturedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $capturedImage)
            }
            .sheet(isPresented: $showingResults) {
                if let results = scanResults {
                    FoodScanResultsView(scanResult: results, capturedImage: capturedImage)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func analyzeDish() {
        guard let image = capturedImage else { return }
        
        isProcessing = true
        
        Task {
            do {
                // Use the food recognition service
                let results = try await FoodRecognitionService.shared.analyzeDish(from: image)
                
                await MainActor.run {
                    self.scanResults = results
                    self.isProcessing = false
                    self.showingResults = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                    self.isProcessing = false
                }
            }
        }
    }
}

// Models for food scanning
struct FoodScanResult: Identifiable {
    let id: UUID
    let timestamp: Date
    let identifiedFoods: [IdentifiedFood]
    let totalNutrition: NutritionInfo
}

struct IdentifiedFood: Identifiable {
    let id = UUID()
    let name: String
    let confidence: Double
    let estimatedWeight: Double // in grams
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let category: FoodCategory
}

// Camera Capture View
struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView
        
        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Image Picker for Photo Library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    DishScannerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}