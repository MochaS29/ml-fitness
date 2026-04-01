import Foundation
import CoreData
import Combine

class LoggingStreakManager: ObservableObject {
    static let shared = LoggingStreakManager()

    @Published private(set) var currentStreak: Int = 0

    private var cancellables = Set<AnyCancellable>()

    private init() {
        refreshStreak()

        // Refresh when Core Data changes
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: PersistenceController.shared.container.viewContext
        )
        .debounce(for: .seconds(1), scheduler: RunLoop.main)
        .sink { [weak self] _ in self?.refreshStreak() }
        .store(in: &cancellables)
    }

    func refreshStreak() {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        guard let entries = try? context.fetch(request) else {
            currentStreak = 0
            return
        }

        let calendar = Calendar.current
        var loggedDays = Set<Date>()
        for entry in entries {
            if let ts = entry.timestamp {
                loggedDays.insert(calendar.startOfDay(for: ts))
            }
        }

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Streak starts from today or yesterday
        var startDay: Date
        if loggedDays.contains(today) {
            startDay = today
        } else if loggedDays.contains(yesterday) {
            startDay = yesterday
        } else {
            currentStreak = 0
            return
        }

        var streak = 1
        var checkDay = calendar.date(byAdding: .day, value: -1, to: startDay)!
        while loggedDays.contains(checkDay) {
            streak += 1
            checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
        }

        currentStreak = streak
    }
}
