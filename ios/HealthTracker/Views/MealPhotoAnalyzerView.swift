import SwiftUI
import PhotosUI
import CoreData

struct MealPhotoAnalyzerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var analysisService = MealAnalysisService.shared

    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var analysisResult: MealAnalysis?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var mealType: MealType = .lunch

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    // Image preview
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    if analysisService.isAnalyzing {
                        ProgressView("Analyzing your meal...")
                            .padding()
                    } else if let result = analysisResult {
                        // Analysis results
                        AnalysisResultsView(
                            analysis: result,
                            mealType: $mealType,
                            onSave: { items in saveToFoodDiary(items: items) }
                        )
                    } else {
                        // Analyze button
                        Button(action: analyzeMeal) {
                            Label("Analyze Meal", systemImage: "wand.and.stars")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Photo selection
                    VStack(spacing: 30) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("Take or select a photo of your meal")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 20) {
                            Button(action: { showingCamera = true }) {
                                Label("Camera", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: { showingImagePicker = true }) {
                                Label("Library", systemImage: "photo")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Meal Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if selectedImage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Photo") {
                            selectedImage = nil
                            analysisResult = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            MealImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            MealImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .alert("Analysis Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func analyzeMeal() {
        guard let image = selectedImage else { return }

        analysisService.analyzeMealPhoto(image) { result in
            switch result {
            case .success(let analysis):
                self.analysisResult = analysis
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
    }

    private func saveToFoodDiary(items: [DetectedFood]) {
        do {
            try analysisService.saveAnalysisToFoodEntry(
                items: items,
                mealType: mealType,
                context: viewContext
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save to diary: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Analysis Results View

struct AnalysisResultsView: View {
    let analysis: MealAnalysis
    @Binding var mealType: MealType
    let onSave: ([DetectedFood]) -> Void

    @State private var editedItems: [DetectedFood]
    @State private var editingFood: DetectedFood?

    init(analysis: MealAnalysis, mealType: Binding<MealType>, onSave: @escaping ([DetectedFood]) -> Void) {
        self.analysis = analysis
        self._mealType = mealType
        self.onSave = onSave
        self._editedItems = State(initialValue: analysis.items)
    }

    var totalCalories: Int {
        editedItems.reduce(0) { $0 + Int($1.calories) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Meal type selector
            Picker("Meal Type", selection: $mealType) {
                ForEach(MealType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Total calories
            HStack {
                Text("Total Calories")
                    .font(.headline)
                Spacer()
                Text("\(totalCalories)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            // Tap hint
            HStack {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.secondary)
                Text("Tap any item to edit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Detected foods list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(editedItems) { item in
                        DetectedFoodRow(
                            food: item,
                            onTap: { editingFood = item }
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Confidence indicator
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Confidence: \(Int(analysis.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Save button
            Button(action: { onSave(editedItems) }) {
                Text("Add to Food Diary")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .sheet(item: $editingFood) { foodToEdit in
            EditDetectedFoodSheet(food: foodToEdit) { edited in
                if let idx = editedItems.firstIndex(where: { $0.id == foodToEdit.id }) {
                    editedItems[idx] = edited
                }
            }
        }
    }
}

// MARK: - Detected Food Row

struct DetectedFoodRow: View {
    let food: DetectedFood
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(food.name)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(food.calories)) cal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(food.quantity)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 15) {
                    MealMacroLabel(label: "Pro", value: food.protein, color: .red)
                    MealMacroLabel(label: "Carb", value: food.carbs, color: .blue)
                    MealMacroLabel(label: "Fat", value: food.fat, color: .green)
                }

                // Confidence bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        Rectangle()
                            .fill(confidenceColor(food.confidence))
                            .frame(width: geometry.size.width * food.confidence, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .yellow
        } else {
            return .orange
        }
    }
}

struct MealMacroLabel: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(color)
            Text("\(Int(value))g")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Edit Detected Food Sheet

struct EditDetectedFoodSheet: View {
    let food: DetectedFood
    let onSave: (DetectedFood) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var quantity: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String

    init(food: DetectedFood, onSave: @escaping (DetectedFood) -> Void) {
        self.food = food
        self.onSave = onSave
        _name = State(initialValue: food.name)
        _quantity = State(initialValue: food.quantity)
        _calories = State(initialValue: "\(Int(food.calories))")
        _protein = State(initialValue: "\(Int(food.protein))")
        _carbs = State(initialValue: "\(Int(food.carbs))")
        _fat = State(initialValue: "\(Int(food.fat))")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    HStack {
                        Text("Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Quantity")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("e.g. 3 eggs", text: $quantity)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("Nutrition (per serving)") {
                    numericRow("Calories", value: $calories, unit: "cal")
                    numericRow("Protein", value: $protein, unit: "g")
                    numericRow("Carbs", value: $carbs, unit: "g")
                    numericRow("Fat", value: $fat, unit: "g")
                }
            }
            .navigationTitle("Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var edited = food
                        edited.name = name.isEmpty ? food.name : name
                        edited.quantity = quantity
                        edited.calories = Double(calories) ?? food.calories
                        edited.protein = Double(protein) ?? food.protein
                        edited.carbs = Double(carbs) ?? food.carbs
                        edited.fat = Double(fat) ?? food.fat
                        onSave(edited)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func numericRow(_ label: String, value: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
        }
    }
}

// MARK: - Image Picker

struct MealImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MealImagePicker

        init(_ parent: MealImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}