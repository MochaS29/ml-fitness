import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.9),  // Light blue
                    Color(red: 0.1, green: 0.4, blue: 0.8)   // Deeper blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // White circle background for logo
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 280, height: 280)
            
            // Brain/Mind symbol with health cross
            ZStack {
                // Brain outline
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 160, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                
                // Health cross overlay
                Image(systemName: "cross.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.5))
                    .offset(x: 40, y: -30)
            }
        }
        .frame(width: 400, height: 400)
    }
}

// Alternative design with leaf and brain
struct AppIconAlternativeView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.5, green: 0.8, blue: 0.4),  // Light green
                    Color(red: 0.2, green: 0.6, blue: 0.9)   // Light blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // White rounded square background
            RoundedRectangle(cornerRadius: 80)
                .fill(Color.white.opacity(0.95))
                .frame(width: 320, height: 320)
            
            // Logo composition
            ZStack {
                // Leaf representing health/wellness
                Image(systemName: "leaf.fill")
                    .font(.system(size: 180, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.3))
                    .rotationEffect(.degrees(-15))
                
                // Brain overlay representing "mind"
                Image(systemName: "brain")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.8))
                    .offset(x: 20, y: -10)
            }
        }
        .frame(width: 400, height: 400)
    }
}

// Minimalist design
struct AppIconMinimalistView: View {
    var body: some View {
        ZStack {
            // Solid color background
            Color(red: 0.15, green: 0.5, blue: 0.85)
            
            // ML monogram
            Text("ML")
                .font(.system(size: 180, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Health indicator
            Circle()
                .fill(Color(red: 0.3, green: 0.8, blue: 0.5))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
                .offset(x: 100, y: -100)
        }
        .frame(width: 400, height: 400)
    }
}

#Preview("Main Design") {
    AppIconView()
}

#Preview("Alternative Design") {
    AppIconAlternativeView()
}

#Preview("Minimalist Design") {
    AppIconMinimalistView()
}