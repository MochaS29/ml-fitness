import SwiftUI

struct SleepTrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Sleep Tracking")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sleep tracking feature coming soon!\nTrack your sleep patterns and see how they affect your nutrition and exercise goals.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Sleep Tracking")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// #Preview {
//     SleepTrackingView()
// }