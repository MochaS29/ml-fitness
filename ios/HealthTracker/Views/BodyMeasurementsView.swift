import SwiftUI

// MARK: - Model

struct BodyMeasurementEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var waist: Double?
    var hips: Double?
    var chest: Double?
    var biceps: Double?
    var thighs: Double?
    var height: Double?
}

// MARK: - Storage

class BodyMeasurementsManager: ObservableObject {
    static let shared = BodyMeasurementsManager()
    private let key = "bodyMeasurementEntries"

    @Published var entries: [BodyMeasurementEntry] = []

    private init() {
        load()
    }

    func add(_ entry: BodyMeasurementEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    var latest: BodyMeasurementEntry? { entries.first }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([BodyMeasurementEntry].self, from: data)
        else { return }
        entries = decoded
    }
}

// MARK: - Main View

struct BodyMeasurementsView: View {
    @ObservedObject private var manager = BodyMeasurementsManager.shared
    @State private var showingAdd = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current measurements card
                if let latest = manager.latest {
                    CurrentMeasurementsCard(entry: latest)
                        .cardStyle()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "ruler.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.mindfulTeal)
                        Text("No measurements yet")
                            .font(.headline)
                        Text("Tap + to log your first measurements")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }

                // History
                if !manager.entries.isEmpty {
                    MeasurementHistoryCard(entries: manager.entries, onDelete: manager.delete)
                        .cardStyle()
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Body Measurements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddMeasurementsView()
        }
    }
}

// MARK: - Current Card

struct CurrentMeasurementsCard: View {
    let entry: BodyMeasurementEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Latest Measurements")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let v = entry.height  { MeasurementCell(label: "Height",  value: v, unit: "in") }
                if let v = entry.waist   { MeasurementCell(label: "Waist",   value: v, unit: "in") }
                if let v = entry.hips    { MeasurementCell(label: "Hips",    value: v, unit: "in") }
                if let v = entry.chest   { MeasurementCell(label: "Chest",   value: v, unit: "in") }
                if let v = entry.biceps  { MeasurementCell(label: "Biceps",  value: v, unit: "in") }
                if let v = entry.thighs  { MeasurementCell(label: "Thighs",  value: v, unit: "in") }
            }
        }
        .padding()
    }
}

struct MeasurementCell: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.1f %@", value, unit))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - History Card

struct MeasurementHistoryCard: View {
    let entries: [BodyMeasurementEntry]
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ForEach(Array(entries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(entry.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    let parts: [(String, Double)] = [
                        ("H", entry.height), ("W", entry.waist), ("Hi", entry.hips),
                        ("C", entry.chest), ("B", entry.biceps), ("T", entry.thighs)
                    ].compactMap { label, val in val.map { (label, $0) } }

                    if !parts.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(parts, id: \.0) { label, val in
                                Text("\(label): \(String(format: "%.1f\"", val))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                if index < min(entries.count, 10) - 1 {
                    Divider().padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Add View

struct AddMeasurementsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = BodyMeasurementsManager.shared

    @State private var height  = ""
    @State private var waist   = ""
    @State private var hips    = ""
    @State private var chest   = ""
    @State private var biceps  = ""
    @State private var thighs  = ""
    @State private var date    = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Measurements (inches)") {
                    MeasurementField(label: "Height", value: $height)
                    MeasurementField(label: "Waist",  value: $waist)
                    MeasurementField(label: "Hips",   value: $hips)
                    MeasurementField(label: "Chest",  value: $chest)
                    MeasurementField(label: "Biceps", value: $biceps)
                    MeasurementField(label: "Thighs", value: $thighs)
                }
            }
            .navigationTitle("Add Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(allEmpty)
                }
            }
        }
    }

    var allEmpty: Bool {
        [height, waist, hips, chest, biceps, thighs].allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func saveEntry() {
        let entry = BodyMeasurementEntry(
            date:   date,
            waist:  Double(waist),
            hips:   Double(hips),
            chest:  Double(chest),
            biceps: Double(biceps),
            thighs: Double(thighs),
            height: Double(height)
        )
        manager.add(entry)
        dismiss()
    }
}

struct MeasurementField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.0", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("in")
                .foregroundColor(.secondary)
        }
    }
}
