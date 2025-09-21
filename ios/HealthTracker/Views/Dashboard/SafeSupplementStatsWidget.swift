import SwiftUI

// Memory-safe version of SupplementStatsWidget
struct SafeSupplementStatsWidget: View {
    @Binding var showingDetail: Bool

    var body: some View {
        // Check if we're in preview mode
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Simple placeholder for previews
            placeholderView
        } else {
            // Actual widget in production
            SupplementStatsWidget(showingDetail: $showingDetail)
        }
    }

    private var placeholderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Supplements")
                        .font(.headline)
                    Text("Preview Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Data disabled in preview")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// #Preview {
//     SafeSupplementStatsWidget(showingDetail: .constant(false))
// }