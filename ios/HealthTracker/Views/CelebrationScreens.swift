import SwiftUI
import CoreData
import Combine

// MARK: - Achievement Detector
class AchievementDetector: ObservableObject {
    @Published var showingCelebration = false
    @Published var currentAchievement: CelebrationAchievement?

    private var cancellables = Set<AnyCancellable>()
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        setupNotifications()
    }

    private func setupNotifications() {
        // Listen for Core Data saves
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.checkForAchievements()
            }
            .store(in: &cancellables)
    }

    func checkForAchievements() {
        checkWeightLoss()
        checkExerciseTarget()
        checkCalorieTarget()
        checkLoggingStreak()
    }

    private func checkWeightLoss() {
        let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: false)]
        request.fetchLimit = 2

        guard let entries = try? viewContext.fetch(request),
              entries.count >= 2 else { return }

        let latestWeight = entries[0].weight
        let previousWeight = entries[1].weight

        if latestWeight < previousWeight {
            let weightLost = previousWeight - latestWeight
            triggerCelebration(.weightLoss(pounds: weightLost))
        }
    }

    private func checkExerciseTarget() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let request: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", today as NSDate, tomorrow as NSDate)

        guard let exercises = try? viewContext.fetch(request) else { return }

        let totalCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }
        let totalMinutes = exercises.reduce(0) { $0 + Int($1.duration) }

        // Check if hit 30 minutes of exercise
        if totalMinutes >= 30 {
            triggerCelebration(.exerciseGoal(minutes: totalMinutes, calories: Int(totalCalories)))
        }
    }

    private func checkCalorieTarget() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", today as NSDate, tomorrow as NSDate)

        guard let foods = try? viewContext.fetch(request) else { return }

        let totalCalories = foods.reduce(0) { $0 + $1.calories }
        let targetCalories = UserDefaults.standard.double(forKey: "dailyCalorieTarget")

        if targetCalories > 0 {
            let difference = abs(totalCalories - targetCalories)
            let percentageOff = (difference / targetCalories) * 100

            // Within 5% of target
            if percentageOff <= 5 {
                triggerCelebration(.calorieTarget(calories: Int(totalCalories), target: Int(targetCalories)))
            }
        }
    }

    private func checkLoggingStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        for _ in 0..<30 {  // Check up to 30 days
            let startOfDay = calendar.startOfDay(for: checkDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
            request.fetchLimit = 1

            if let count = try? viewContext.count(for: request), count > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        // Celebrate streaks at specific milestones
        if [2, 3, 7, 14, 21, 30].contains(streak) {
            triggerCelebration(.loggingStreak(days: streak))
        }
    }

    private func triggerCelebration(_ achievement: CelebrationAchievement) {
        DispatchQueue.main.async {
            self.currentAchievement = achievement
            self.showingCelebration = true
        }
    }
}

// MARK: - Achievement Type
enum CelebrationAchievement {
    case weightLoss(pounds: Double)
    case exerciseGoal(minutes: Int, calories: Int)
    case calorieTarget(calories: Int, target: Int)
    case loggingStreak(days: Int)

    var title: String {
        switch self {
        case .weightLoss:
            return "Weight Loss!"
        case .exerciseGoal:
            return "Exercise Goal!"
        case .calorieTarget:
            return "Calorie Target!"
        case .loggingStreak:
            return "Logging Streak!"
        }
    }

    var message: String {
        switch self {
        case .weightLoss(let pounds):
            return String(format: "You've lost %.1f lbs! Keep up the amazing work!", pounds)
        case .exerciseGoal(let minutes, let calories):
            return "You completed \(minutes) minutes of exercise and burned \(calories) calories today!"
        case .calorieTarget(let calories, let target):
            return "You hit your calorie target of \(target)! You consumed \(calories) calories."
        case .loggingStreak(let days):
            return "You've logged your meals for \(days) days in a row! Consistency is key!"
        }
    }

    var icon: String {
        switch self {
        case .weightLoss:
            return "scalemass"
        case .exerciseGoal:
            return "figure.run"
        case .calorieTarget:
            return "flame.fill"
        case .loggingStreak:
            return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .weightLoss:
            return .green
        case .exerciseGoal:
            return .orange
        case .calorieTarget:
            return .red
        case .loggingStreak:
            return .blue
        }
    }

    // Helper to convert from Achievement model
    static func from(_ achievement: Achievement) -> CelebrationAchievement {
        switch achievement.type {
        case .weightLoss:
            return .weightLoss(pounds: achievement.value ?? 0)
        case .exerciseGoal:
            return .exerciseGoal(minutes: Int(achievement.value ?? 0), calories: 0)
        case .calorieTarget:
            return .calorieTarget(calories: Int(achievement.value ?? 0), target: Int(achievement.target ?? 0))
        case .loggingStreak:
            return .loggingStreak(days: Int(achievement.value ?? 0))
        default:
            return .loggingStreak(days: 1) // Default fallback
        }
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    let achievement: CelebrationAchievement
    @Binding var isPresented: Bool
    @State private var showConfetti = false
    @State private var animateIcon = false
    @State private var animateText = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCelebration()
                }

            // Confetti Effect
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }

            // Main Content
            VStack(spacing: 30) {
                // Icon
                ZStack {
                    Circle()
                        .fill(achievement.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateIcon ? 1.2 : 0.8)
                        .opacity(animateIcon ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: animateIcon
                        )

                    Circle()
                        .fill(achievement.color)
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateIcon ? 1.0 : 0.5)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .scaleEffect(animateIcon ? 1.0 : 0.5)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateIcon)

                // Title
                Text(achievement.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .scaleEffect(animateText ? 1.0 : 0.8)
                    .opacity(animateText ? 1.0 : 0)

                // Message
                Text(achievement.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)

                // Motivational Quote
                Text(getMotivationalQuote())
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .opacity(animateText ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateText)

                // Continue Button
                Button(action: dismissCelebration) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(achievement.color)
                        .cornerRadius(25)
                }
                .scaleEffect(animateText ? 1.0 : 0.8)
                .opacity(animateText ? 1.0 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.8), value: animateText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(40)
            .scaleEffect(animateText ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateText)
        }
        .onAppear {
            startAnimations()
            playHapticFeedback()
        }
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.5)) {
            animateIcon = true
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            animateText = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }

        // Auto-dismiss after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if isPresented {
                dismissCelebration()
            }
        }
    }

    private func dismissCelebration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
    }

    private func playHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Additional haptic pattern for celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
    }

    private func getMotivationalQuote() -> String {
        let quotes = [
            "Every accomplishment starts with the decision to try.",
            "Success is the sum of small efforts repeated day in and day out.",
            "You are stronger than you think!",
            "Progress, not perfection.",
            "The only bad workout is the one that didn't happen.",
            "Your body can stand almost anything. It's your mind you have to convince.",
            "Don't stop until you're proud.",
            "A healthy outside starts from the inside.",
            "Take care of your body. It's the only place you have to live.",
            "The groundwork for all happiness is good health."
        ]

        return quotes.randomElement() ?? quotes[0]
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, screenSize: geometry.size)
                }
            }
        }
        .onAppear {
            createConfetti()
        }
    }

    private func createConfetti() {
        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple].randomElement()!,
                startX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                startY: -20,
                scale: CGFloat.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360),
                delay: Double.random(in: 0...1)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let scale: CGFloat
    let rotation: Double
    let delay: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let screenSize: CGSize
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .scaleEffect(piece.scale)
            .rotationEffect(.degrees(piece.rotation))
            .position(x: piece.startX + offsetX, y: piece.startY + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: Double.random(in: 2...4))
                    .delay(piece.delay)
                ) {
                    offsetY = screenSize.height + 100
                    offsetX = CGFloat.random(in: -50...50)
                    opacity = 0
                }
            }
    }
}

// MARK: - Integration View Modifier
struct CelebrationModifier: ViewModifier {
    @StateObject private var detector: AchievementDetector

    init(context: NSManagedObjectContext) {
        _detector = StateObject(wrappedValue: AchievementDetector(context: context))
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if detector.showingCelebration, let achievement = detector.currentAchievement {
                        CelebrationView(
                            achievement: achievement,
                            isPresented: $detector.showingCelebration
                        )
                        .zIndex(999)
                        .transition(.opacity)
                    }
                }
            )
    }
}

extension View {
    func withCelebrations(context: NSManagedObjectContext) -> some View {
        self.modifier(CelebrationModifier(context: context))
    }
}