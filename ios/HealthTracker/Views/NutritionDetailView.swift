import SwiftUI
import Charts
import CoreData

struct NutritionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        animation: .default)
    private var allEntries: FetchedResults<FoodEntry>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        macroSummaryCard
                        macroBarChart
                        nutrientBreakdownCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Nutrition Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Data Helpers

    private var filteredEntries: [FoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch selectedTab {
        case 0:
            startDate = calendar.startOfDay(for: now)
        case 1:
            startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) ?? now
        default:
            startDate = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) ?? now
        }

        return allEntries.filter { entry in
            guard let ts = entry.timestamp else { return false }
            return ts >= startDate
        }
    }

    private var totalCalories: Double { filteredEntries.reduce(0) { $0 + $1.calories } }
    private var totalProtein: Double { filteredEntries.reduce(0) { $0 + $1.protein } }
    private var totalCarbs: Double { filteredEntries.reduce(0) { $0 + $1.carbs } }
    private var totalFat: Double { filteredEntries.reduce(0) { $0 + $1.fat } }
    private var totalFiber: Double { filteredEntries.reduce(0) { $0 + $1.fiber } }
    private var totalSugar: Double { filteredEntries.reduce(0) { $0 + $1.sugar } }
    private var totalSodium: Double { filteredEntries.reduce(0) { $0 + $1.sodium } }

    private var dayCount: Double {
        switch selectedTab {
        case 0: return 1
        case 1: return 7
        default: return 30
        }
    }

    private var avgCalories: Double { totalCalories / max(dayCount, 1) }
    private var avgProtein: Double { totalProtein / max(dayCount, 1) }
    private var avgCarbs: Double { totalCarbs / max(dayCount, 1) }
    private var avgFat: Double { totalFat / max(dayCount, 1) }

    private var periodLabel: String {
        switch selectedTab {
        case 0: return "Today"
        case 1: return "This Week"
        default: return "This Month"
        }
    }

    // Daily chart data (last 7 or 30 days)
    private var dailyCalorieData: [(label: String, calories: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let count = selectedTab == 1 ? 7 : 30

        return (0..<count).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: now)!
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!

            let dayEntries = allEntries.filter { entry in
                guard let ts = entry.timestamp else { return false }
                return ts >= start && ts < end
            }
            let cals = dayEntries.reduce(0.0) { $0 + $1.calories }

            let fmt = DateFormatter()
            fmt.dateFormat = selectedTab == 1 ? "EEE" : "d"
            return (label: fmt.string(from: date), calories: cals)
        }
    }

    // MARK: - Views

    private var macroSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(periodLabel) Summary")
                .font(.headline)
                .foregroundColor(.primary)

            let showAvg = selectedTab > 0

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NutritionStatCard(
                    title: showAvg ? "Avg Calories" : "Calories",
                    value: String(format: "%.0f", selectedTab == 0 ? totalCalories : avgCalories),
                    unit: "kcal",
                    color: .orange
                )
                NutritionStatCard(
                    title: showAvg ? "Avg Protein" : "Protein",
                    value: String(format: "%.1f", selectedTab == 0 ? totalProtein : avgProtein),
                    unit: "g",
                    color: .blue
                )
                NutritionStatCard(
                    title: showAvg ? "Avg Carbs" : "Carbs",
                    value: String(format: "%.1f", selectedTab == 0 ? totalCarbs : avgCarbs),
                    unit: "g",
                    color: .green
                )
                NutritionStatCard(
                    title: showAvg ? "Avg Fat" : "Fat",
                    value: String(format: "%.1f", selectedTab == 0 ? totalFat : avgFat),
                    unit: "g",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var macroBarChart: some View {
        if selectedTab == 0 {
            // Today: show macro distribution as horizontal bars
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Macros")
                    .font(.headline)

                let defaults = UserDefaults.standard
                let proteinGoal = Double(defaults.integer(forKey: "proteinGoal")) > 0
                    ? Double(defaults.integer(forKey: "proteinGoal")) : 50.0

                MacroProgressBar(label: "Protein", value: totalProtein, goal: proteinGoal, unit: "g", color: .blue)
                MacroProgressBar(label: "Carbs",   value: totalCarbs,   goal: 275,         unit: "g", color: .green)
                MacroProgressBar(label: "Fat",     value: totalFat,     goal: 78,           unit: "g", color: .yellow)
                if totalFiber > 0 {
                    MacroProgressBar(label: "Fiber", value: totalFiber, goal: 28, unit: "g", color: .brown)
                }
                if totalSodium > 0 {
                    MacroProgressBar(label: "Sodium", value: totalSodium, goal: 2300, unit: "mg", color: .gray)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        } else {
            // Week/Month: show calorie bar chart
            VStack(alignment: .leading, spacing: 12) {
                Text(selectedTab == 1 ? "Daily Calories (7 days)" : "Daily Calories (30 days)")
                    .font(.headline)

                Chart(dailyCalorieData, id: \.label) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Calories", item.calories)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
    }

    private var nutrientBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedTab == 0 ? "Full Nutrient Breakdown" : "Period Totals")
                .font(.headline)

            let showAvg = selectedTab > 0
            let div = selectedTab == 0 ? 1.0 : dayCount

            VStack(spacing: 0) {
                NutritionDetailRow(name: "Calories",       value: totalCalories / div,  unit: "kcal", showAvg: showAvg, color: .orange)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Protein",        value: totalProtein / div,   unit: "g",    showAvg: showAvg, color: .blue)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Carbohydrates",  value: totalCarbs / div,     unit: "g",    showAvg: showAvg, color: .green)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Fat",            value: totalFat / div,       unit: "g",    showAvg: showAvg, color: .yellow)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Fiber",          value: totalFiber / div,     unit: "g",    showAvg: showAvg, color: .brown)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Sugar",          value: totalSugar / div,     unit: "g",    showAvg: showAvg, color: .pink)
                Divider().padding(.leading)
                NutritionDetailRow(name: "Sodium",         value: totalSodium / div,    unit: "mg",   showAvg: showAvg, color: .gray)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Supporting Views

private struct NutritionStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

private struct MacroProgressBar: View {
    let label: String
    let value: Double
    let goal: Double
    let unit: String
    let color: Color

    private var progress: Double { min(value / max(goal, 1), 1.0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: unit == "mg" ? "%.0f / %.0f %@" : "%.1f / %.0f %@", value, goal, unit))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

private struct NutritionDetailRow: View {
    let name: String
    let value: Double
    let unit: String
    let showAvg: Bool
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            if showAvg {
                Text("avg/day")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
            Text(unit == "mg"
                 ? String(format: "%.0f %@", value, unit)
                 : unit == "kcal"
                   ? String(format: "%.0f %@", value, unit)
                   : String(format: "%.1f %@", value, unit))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}
