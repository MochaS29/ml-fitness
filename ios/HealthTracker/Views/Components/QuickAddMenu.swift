import SwiftUI

struct QuickAddMenu: View {
    @Environment(\.dismiss) private var dismiss

    let onFoodTap: () -> Void
    let onExerciseTap: () -> Void
    let onWaterTap: () -> Void
    let onSupplementTap: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: onFoodTap) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Food")
                                    .foregroundColor(.primary)
                                Text("Track meals and snacks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                        }
                    }

                    Button(action: onExerciseTap) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Exercise")
                                    .foregroundColor(.primary)
                                Text("Log workouts and activities")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "figure.run")
                                .foregroundColor(.green)
                                .frame(width: 30)
                        }
                    }

                    Button(action: onWaterTap) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Water")
                                    .foregroundColor(.primary)
                                Text("Track hydration")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                        }
                    }

                    Button(action: onSupplementTap) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Supplements")
                                    .foregroundColor(.primary)
                                Text("Log vitamins and supplements")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                        }
                    }
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}