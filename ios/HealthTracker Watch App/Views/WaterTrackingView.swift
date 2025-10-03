import SwiftUI

struct WaterTrackingView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var showingSuccess = false

    let quickAddAmounts = [8, 16, 24, 32]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Water")
                    .font(.title3)
                    .bold()

                ZStack {
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: connectivity.waterProgress)
                        .stroke(Color.cyan, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: connectivity.waterProgress)

                    VStack {
                        Image(systemName: "drop.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)

                        Text("\(Int(connectivity.currentWater)) oz")
                            .font(.headline)

                        Text("of \(Int(connectivity.waterGoal))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 120, height: 120)
                .padding(.vertical, 5)

                VStack(spacing: 8) {
                    ForEach(quickAddAmounts, id: \.self) { amount in
                        Button(action: {
                            addWater(amount: Double(amount))
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.cyan)
                                Text("\(amount) oz")
                                    .font(.footnote)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.cyan.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .overlay(
            Group {
                if showingSuccess {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("Added!")
                            .font(.caption)
                            .bold()
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }

    private func addWater(amount: Double) {
        connectivity.sendWaterEntry(amount: amount)
        connectivity.currentWater += amount

        withAnimation {
            showingSuccess = true
        }

        WKInterfaceDevice.current().play(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSuccess = false
            }
        }
    }
}

import WatchKit

#Preview {
    WaterTrackingView()
        .environmentObject(WatchConnectivityManager())
}