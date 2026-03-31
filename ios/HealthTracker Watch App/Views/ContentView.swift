import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        TabView {
            DashboardView()
                .tag(0)

            WaterTrackingView()
                .tag(1)

            QuickLogView()
                .tag(2)

            ExerciseView()
                .tag(3)
        }
        .tabViewStyle(.carousel)
    }
}

struct DashboardView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("ML Fitness")
                    .font(.title3)
                    .bold()

                HStack(spacing: 15) {
                    ProgressRing(
                        progress: connectivity.calorieProgress,
                        color: .blue,
                        icon: "flame.fill",
                        value: "\(Int(connectivity.currentCalories))",
                        label: "Cal"
                    )

                    ProgressRing(
                        progress: connectivity.waterProgress,
                        color: .cyan,
                        icon: "drop.fill",
                        value: "\(Int(connectivity.currentWater))",
                        label: "oz"
                    )
                }

                VStack(alignment: .leading, spacing: 5) {
                    MacroRow(label: "Protein", value: connectivity.currentProtein, color: .orange)
                    MacroRow(label: "Carbs", value: connectivity.currentCarbs, color: .green)
                    MacroRow(label: "Fat", value: connectivity.currentFat, color: .purple)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, lineWidth: 4)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Image(systemName: icon)
                        .font(.caption2)
                    Text(value)
                        .font(.caption)
                        .bold()
                }
            }
            .frame(width: 60, height: 60)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MacroRow: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
            Spacer()
            Text("\(value)g")
                .font(.caption)
                .bold()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager())
}