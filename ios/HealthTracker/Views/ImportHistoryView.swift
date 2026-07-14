import SwiftUI
import UniformTypeIdentifiers

/// Import a MyFitnessPal history export into the diary. Handles the Nutrition,
/// Exercise, and Measurement (weight) CSVs, auto-detected from the file.
/// Flow: pick a CSV (or try a bundled sample) -> preview -> confirm -> import.
struct ImportHistoryView: View {
    private enum Stage {
        case idle
        case previewing(MFPImporter.Summary)
        case importing(Double)
        case done(inserted: Int, noun: String)
        case failed(String)
    }

    @State private var stage: Stage = .idle
    @State private var showingFileImporter = false
    @State private var showingGuide = false
    @State private var weightUnit: MFPImporter.WeightUnit = .pounds

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch stage {
                case .idle:
                    introSection
                case .previewing(let summary):
                    previewSection(summary)
                case .importing(let progress):
                    importingSection(progress)
                case .done(let inserted, let noun):
                    doneSection(inserted, noun)
                case .failed(let message):
                    failedSection(message)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Import History")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText, .text],
            allowsMultipleSelection: false
        ) { result in
            handleFilePick(result)
        }
        .sheet(isPresented: $showingGuide) {
            NavigationView { MFPExportGuideView() }
        }
    }

    // MARK: - Idle / intro

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            heroCard

            Text("Coming from another fitness app? Bring your history with you. Import your food diary, workouts, and weight so you don't start from scratch.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: { showingFileImporter = true }) {
                Label("Choose a CSV file", systemImage: "doc.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.wellnessGreen)
                    .cornerRadius(12)
            }

            Text("Works with exported food, exercise, and weight files. Import one at a time.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: { showingGuide = true }) {
                Label("How do I export my data?", systemImage: "questionmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTeal)
            }

            #if DEBUG
            Divider()
            Text("Sample data (debug)").font(.caption).foregroundColor(.secondary)
            HStack(spacing: 12) {
                sampleButton("Food", "SampleMFPExport")
                sampleButton("Exercise", "SampleMFPExercise")
                sampleButton("Weight", "SampleMFPWeight")
            }
            #endif
        }
    }

    #if DEBUG
    private func sampleButton(_ title: String, _ resource: String) -> some View {
        Button(action: { loadSample(resource) }) {
            Text(title)
                .font(.caption).fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(10)
        }
        .foregroundColor(.mindfulTeal)
    }
    #endif

    private var heroCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.wellnessGreen.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.wellnessGreen)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Import your history")
                    .font(.headline)
                Text("Food, exercise & weight history")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Preview

    private func previewSection(_ summary: MFPImporter.Summary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ready to import")
                .font(.title3).fontWeight(.bold)

            VStack(spacing: 0) {
                statRow("\(kindLabel(summary.kind)) found", "\(summary.importableRows)")
                Divider()
                statRow("Date range", dateRangeText(summary))
                if summary.skippedRows > 0 {
                    Divider()
                    statRow("Rows skipped", "\(summary.skippedRows)")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)

            if summary.kind == .nutrition, !summary.mealCounts.isEmpty {
                mealBreakdown(summary.mealCounts)
            }

            if summary.kind == .weight {
                weightUnitPicker
            }

            if !summary.sampleNames.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("For example")
                        .font(.caption).foregroundColor(.secondary)
                    ForEach(summary.sampleNames, id: \.self) { name in
                        Text("• \(name)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
            }

            Text("Anything already in your diary for these days won't be duplicated.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: { runImport(summary) }) {
                Text("Import \(summary.importableRows) \(summary.noun)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(summary.importableRows > 0 ? Color.wellnessGreen : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(summary.importableRows == 0)

            Button("Choose a different file") { stage = .idle }
                .font(.subheadline)
                .foregroundColor(.mindfulTeal)
                .frame(maxWidth: .infinity)
        }
    }

    private var weightUnitPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("These weights are in")
                .font(.caption).foregroundColor(.secondary)
            Picker("Weight unit", selection: $weightUnit) {
                Text("Pounds (lb)").tag(MFPImporter.WeightUnit.pounds)
                Text("Kilograms (kg)").tag(MFPImporter.WeightUnit.kilograms)
            }
            .pickerStyle(.segmented)
        }
    }

    private func mealBreakdown(_ counts: [MealType: Int]) -> some View {
        HStack(spacing: 10) {
            ForEach(MealType.allCases, id: \.self) { meal in
                if let n = counts[meal], n > 0 {
                    VStack(spacing: 2) {
                        Text("\(n)").font(.headline)
                        Text(meal.rawValue).font(.caption2).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Importing / done / failed

    private func importingSection(_ progress: Double) -> some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .tint(.wellnessGreen)
            Text("Importing your history…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }

    private func doneSection(_ inserted: Int, _ noun: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.wellnessGreen)
            Text(inserted > 0 ? "Imported \(inserted) \(noun)" : "Nothing new to import")
                .font(.title3).fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(inserted > 0
                 ? "Your history is now in the app. Open the Diary tab to see it."
                 : "These were already in your diary, so nothing was duplicated.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Import another file") { stage = .idle }
                .font(.headline)
                .foregroundColor(.mindfulTeal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func failedSection(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Couldn't import that file")
                .font(.title3).fontWeight(.bold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") { stage = .idle }
                .font(.headline)
                .foregroundColor(.mindfulTeal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    // MARK: - Helpers

    private func kindLabel(_ kind: MFPImporter.Kind) -> String {
        switch kind {
        case .nutrition: return "Entries"
        case .exercise: return "Workouts"
        case .weight: return "Weigh-ins"
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }

    private func dateRangeText(_ summary: MFPImporter.Summary) -> String {
        guard let start = summary.startDate, let end = summary.endDate else { return "—" }
        let df = DateFormatter()
        df.dateStyle = .medium
        if Calendar.current.isDate(start, inSameDayAs: end) { return df.string(from: start) }
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }

    // MARK: - Actions

    private func handleFilePick(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let needsAccess = url.startAccessingSecurityScopedResource()
            defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                preview(text)
            } catch {
                stage = .failed("We couldn't read that file. Make sure it's a CSV export from your other app.")
            }
        case .failure:
            stage = .failed("No file was selected.")
        }
    }

    private func loadSample(_ resource: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "csv"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            stage = .failed("Sample data isn't bundled in this build.")
            return
        }
        preview(text)
    }

    private func preview(_ text: String) {
        do {
            let summary = try MFPImporter.preview(csvText: text)
            stage = .previewing(summary)
        } catch {
            stage = .failed(error.localizedDescription)
        }
    }

    private func runImport(_ summary: MFPImporter.Summary) {
        stage = .importing(0)
        Task {
            do {
                let inserted = try await MFPImporter.importSummary(
                    summary,
                    weightUnit: weightUnit,
                    container: PersistenceController.shared.container
                ) { progress in
                    Task { @MainActor in
                        if case .importing = stage { stage = .importing(progress) }
                    }
                }
                await MainActor.run { stage = .done(inserted: inserted, noun: summary.noun) }
            } catch {
                await MainActor.run {
                    stage = .failed("Something went wrong while importing. Please try again.")
                }
            }
        }
    }
}

/// Step-by-step guide for getting a MyFitnessPal export out of MFP.
struct MFPExportGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Getting your data from another app")
                    .font(.title2).fontWeight(.bold)

                Text("Most fitness apps can export your food diary, exercise, and weight as CSV files. There are usually two ways to get them:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                guideBlock(
                    number: "1",
                    title: "Export from your account (fastest)",
                    steps: [
                        "On a computer, sign in to your current app's website.",
                        "Open its account or data settings and look for an Export Data option.",
                        "Request your data. Many apps email you CSV files for food, exercise, and measurements.",
                        "Save the files to your phone (AirDrop, email, or your Files app), then come back here and choose one."
                    ],
                    note: "Some apps keep the one-tap export behind a paid plan."
                )

                guideBlock(
                    number: "2",
                    title: "Request your data for free",
                    steps: [
                        "If export isn't on the free plan, you can still ask the app for a copy of your data.",
                        "In the app, open Settings, then look for a Privacy Center or a data request option.",
                        "They'll email you an archive within a few days. It includes your food, exercise, and weight history as CSV.",
                        "Save the files to your phone and choose them here, one at a time."
                    ],
                    note: "This is your data. The app has to provide it on request."
                )

                Text("Import one file at a time. We'll detect whether it's food, exercise, or weight and show a preview before importing.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Export Guide")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func guideBlock(number: String, title: String, steps: [String], note: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(Color.wellnessGreen).frame(width: 28, height: 28)
                    Text(number).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                }
                Text(title).font(.headline)
            }
            ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.wellnessGreen)
                    Text(step).font(.subheadline).foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text(note)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
