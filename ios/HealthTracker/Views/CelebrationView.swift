import SwiftUI

struct CelebrationView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    @State private var animationScale: CGFloat = 0.1
    @State private var confettiOpacity: Double = 0
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCelebration()
                }
            
            // Celebration card
            VStack(spacing: 20) {
                // Achievement icon with animation
                ZStack {
                    Circle()
                        .fill(achievement.type.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(achievement.type.color, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: achievement.type.icon)
                        .font(.system(size: 50))
                        .foregroundColor(achievement.type.color)
                    
                    // Success checkmark overlay
                    if showCheckmark {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.wellnessGreen)
                            .offset(x: 40, y: -40)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(animationScale)
                
                // Title
                Text(achievement.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Description
                Text(achievement.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Value badge if present
                if let value = achievement.value {
                    Text(value)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(achievement.type.color.opacity(0.2))
                        .foregroundColor(achievement.type.color)
                        .cornerRadius(20)
                }
                
                // Dismiss button
                Button(action: dismissCelebration) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(achievement.type.color)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 350)
            .scaleEffect(animationScale)
            
            // Confetti effect
            ConfettiView()
                .opacity(confettiOpacity)
                .allowsHitTesting(false)
        }
        .onAppear {
            animateCelebration()
        }
    }
    
    func animateCelebration() {
        // Scale up animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animationScale = 1.0
        }
        
        // Show checkmark after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) {
                showCheckmark = true
            }
        }
        
        // Show confetti
        withAnimation(.easeIn(duration: 0.3)) {
            confettiOpacity = 1.0
        }
        
        // Hide confetti after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 1)) {
                confettiOpacity = 0
            }
        }
    }
    
    func dismissCelebration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            animationScale = 0.1
            isShowing = false
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }
    
    func createConfetti(in size: CGSize) {
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: [Color.mochaBrown, .mindfulTeal, .wellnessGreen, .orange, .pink, .purple].randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .scaleEffect(piece.scale)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: piece.y + offsetY)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 2...4))) {
                    offsetY = UIScreen.main.bounds.height + 100
                    rotation = piece.rotation + 360
                }
            }
    }
}

// Achievement List View for viewing history
struct AchievementHistoryView: View {
    @ObservedObject var achievementManager = AchievementManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if achievementManager.recentAchievements.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.lightGray)
                        
                        Text("No achievements yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Keep tracking your health to earn achievements!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else {
                    ForEach(achievementManager.recentAchievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.type.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.type.icon)
                    .font(.title2)
                    .foregroundColor(achievement.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(achievement.dateEarned, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let value = achievement.value {
                        Text("• \(value)")
                            .font(.caption2)
                            .foregroundColor(achievement.type.color)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}