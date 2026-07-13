import SwiftUI
import UniformTypeIdentifiers

/// Import a MyFitnessPal history export into the food diary.
/// Flow: pick a CSV (or try the bundled sample) -> preview -> confirm -> import.
struct ImportHistoryView: View {
    private enum Stage {
        case idle
        case previewing(MFPImporter.Summary)
        case importing(Double)
        case done(inserted: Int)
        case failed(String)
    }

    @State private var stage: Stage = .idle
    @State private var showingFileImporter = false
    @State private var showingGuide = false

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
                case .done(let inserted):
                    doneSection(inserted)
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

            Text("Switching from MyFitnessPal? Bring your food diary with you. Import your MyFitnessPal history so you don't start from scratch.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: { showingFileImporter = true }) {
                Label("Choose a MyFitnessPal CSV", systemImage: "doc.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.wellnessGreen)
                    .cornerRadius(12)
            }

            Button(action: { showingGuide = true }) {
                Label("How do I get my MyFitnessPal data?", systemImage: "questionmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTeal)
            }

            #if DEBUG
            Divider()
            Button(action: loadSample) {
                Label("Try with sample data", systemImage: "wand.and.stars")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            #endif
        }
    }

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
                Text("MyFitnessPal food diary")
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
                statRow("Entries found", "\(summary.importableRows)")
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

            if !summary.mealCounts.isEmpty {
                mealBreakdown(summary.mealCounts)
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

            Button(action: { runImport(summary.entries) }) {
                Text("Import \(summary.importableRows) entries")
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

    private func doneSection(_ inserted: Int) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.wellnessGreen)
            Text(inserted > 0 ? "Imported \(inserted) entries" : "Nothing new to import")
                .font(.title3).fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(inserted > 0
                 ? "Your MyFitnessPal history is now in your diary. Open the Diary tab to see it."
                 : "These entries were already in your diary, so nothing was duplicated.")
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
                stage = .failed("We couldn't read that file. Make sure it's the CSV from your MyFitnessPal export.")
            }
        case .failure:
            stage = .failed("No file was selected.")
        }
    }

    private func loadSample() {
        guard let url = Bundle.main.url(forResource: "SampleMFPExport", withExtension: "csv"),
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

    private func runImport(_ entries: [MFPImporter.ParsedFoodRow]) {
        stage = .importing(0)
        Task {
            do {
                let inserted = try await MFPImporter.importEntries(
                    entries,
                    container: PersistenceController.shared.container
                ) { progress in
                    Task { @MainActor in
                        if case .importing = stage { stage = .importing(progress) }
                    }
                }
                await MainActor.run { stage = .done(inserted: inserted) }
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
                Text("Getting your MyFitnessPal data")
                    .font(.title2).fontWeight(.bold)

                Text("MyFitnessPal lets you export your food diary as a CSV file. There are two ways to get it:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                guideBlock(
                    number: "1",
                    title: "Export from your account (fastest)",
                    steps: [
                        "On a computer, sign in at myfitnesspal.com.",
                        "Go to your account settings and open \"Export Data\".",
                        "Request the Nutrition export. MyFitnessPal emails you a CSV file.",
                        "Save the CSV to your phone (AirDrop, email it to yourself, or your Files app), then come back here and choose it."
                    ],
                    note: "MyFitnessPal keeps the one-tap export behind their Premium plan."
                )

                guideBlock(
                    number: "2",
                    title: "Request your data for free",
                    steps: [
                        "If you don't have Premium, you can still ask MyFitnessPal for a copy of your data.",
                        "In MyFitnessPal, go to Settings, then Privacy Center, and request a copy of your data (a data / privacy request).",
                        "They'll email you an archive within a few days. It includes your nutrition history as CSV.",
                        "Save that CSV to your phone and choose it here."
                    ],
                    note: "This is your data. MyFitnessPal has to provide it on request."
                )

                Text("Once you have the CSV on your phone, tap \"Choose a MyFitnessPal CSV\" and we'll show you a preview before importing.")
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
