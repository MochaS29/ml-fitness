import SwiftUI

struct QuickAddMenu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @AppStorage("freeMealScansUsed") private var freeMealScansUsed = 0

    let selectedDate: Date

    @State private var selectedMealType: MealType = .breakfast
    @State private var activeSheet: ActiveSheet?

    private static let freeScansAllowed = 3

    private enum ActiveSheet: Identifiable {
        case foodSearch
        case exerciseSearch
        case barcodeScanner
        case supplementAdd
        case weightEntry
        case waterEntry
        case mealScanner

        var id: Self { self }
    }

    var body: some View {
        NavigationView {
            listContent
                .navigationTitle("Add to Diary")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .foodSearch:
                UnifiedFoodSearchSheet(mealType: selectedMealType, targetDate: selectedDate)
            case .barcodeScanner:
                ProFeatureGate {
                    BarcodeScannerView(selectedDate: selectedDate, mealType: selectedMealType)
                }
            case .exerciseSearch:
                ExerciseQuickAddView()
            case .supplementAdd:
                ManualSupplementEntryView()
            case .weightEntry:
                QuickWeightAddView(selectedDate: selectedDate)
            case .waterEntry:
                QuickWaterAddView(selectedDate: selectedDate)
            case .mealScanner:
                MealPhotoAnalyzerView()
            }
        }
    }

    private var listContent: some View {
        List {
            // Food Section
            Section("Food") {
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Text(mealType.rawValue).tag(mealType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)

                Button(action: { activeSheet = .foodSearch }) {
                    Label("Search Food Database", systemImage: "magnifyingglass")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .mealScanner }) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Scan Meal with Camera", systemImage: "camera.fill")
                                .foregroundColor(.primary)
                            if !storeManager.isPro && !TrialManager.shared.isTrialActive {
                                let remaining = max(0, Self.freeScansAllowed - freeMealScansUsed)
                                Text(remaining > 0
                                     ? "\(remaining) free scan\(remaining == 1 ? "" : "s") · tap to try"
                                     : "Upgrade to keep scanning")
                                    .font(.caption)
                                    .foregroundColor(remaining > 0 ? .orange : .secondary)
                            }
                        }
                        Spacer()
                        if !storeManager.isPro && !TrialManager.shared.isTrialActive {
                            let remaining = max(0, Self.freeScansAllowed - freeMealScansUsed)
                            if remaining > 0 {
                                Text("FREE")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Button(action: { activeSheet = .barcodeScanner }) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        .foregroundColor(.primary)
                }
            }

            // Exercise Section
            Section("Exercise") {
                Button(action: { activeSheet = .exerciseSearch }) {
                    Label("Add Exercise", systemImage: "figure.run")
                        .foregroundColor(.primary)
                }
            }

            // Tracking Section
            Section("Tracking") {
                Button(action: { activeSheet = .weightEntry }) {
                    Label("Log Weight", systemImage: "scalemass")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .waterEntry }) {
                    Label("Log Water", systemImage: "drop.fill")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .supplementAdd }) {
                    Label("Add Supplement", systemImage: "pills.fill")
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
