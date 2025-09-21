import SwiftUI

struct AppIconPreview: View {
    @State private var selectedDesign = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Design picker
                Picker("Design", selection: $selectedDesign) {
                    Text("Brain + Health").tag(0)
                    Text("Leaf + Mind").tag(1)
                    Text("ML Monogram").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Preview at different sizes
                VStack(spacing: 20) {
                    Text("App Icon Preview")
                        .font(.headline)
                    
                    HStack(spacing: 30) {
                        iconPreview(size: 60, label: "60pt")
                        iconPreview(size: 120, label: "120pt")
                        iconPreview(size: 180, label: "180pt")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Full size preview
                VStack(spacing: 10) {
                    Text("Full Size (1024x1024)")
                        .font(.headline)
                    
                    Group {
                        switch selectedDesign {
                        case 0:
                            AppIconView()
                        case 1:
                            AppIconAlternativeView()
                        case 2:
                            AppIconMinimalistView()
                        default:
                            AppIconView()
                        }
                    }
                    .frame(width: 300, height: 300)
                    .cornerRadius(60)
                    .shadow(radius: 10)
                }
                
                Spacer()
                
                // Instructions
                VStack(alignment: .leading, spacing: 10) {
                    Text("To export the icon:")
                        .font(.headline)
                    Text("1. Take a screenshot of the full size preview")
                        .font(.caption)
                    Text("2. Use an app icon generator service like:")
                        .font(.caption)
                    Text("   • appicon.co")
                        .font(.caption)
                    Text("   • makeappicon.com")
                        .font(.caption)
                    Text("   • iconset.io")
                        .font(.caption)
                    Text("3. Upload the screenshot to generate all required sizes")
                        .font(.caption)
                    Text("4. Add the generated icons to Assets.xcassets/AppIcon")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .navigationTitle("App Icon Generator")
        }
    }
    
    func iconPreview(size: CGFloat, label: String) -> some View {
        VStack(spacing: 5) {
            Group {
                switch selectedDesign {
                case 0:
                    AppIconView()
                case 1:
                    AppIconAlternativeView()
                case 2:
                    AppIconMinimalistView()
                default:
                    AppIconView()
                }
            }
            .frame(width: size, height: size)
            .cornerRadius(size * 0.2237)
            .shadow(radius: 2)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// #Preview {
//     AppIconPreview()
// }