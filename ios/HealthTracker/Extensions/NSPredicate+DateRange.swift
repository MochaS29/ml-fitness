import Foundation

extension NSPredicate {
    /// Predicate matching records where `key` falls within the calendar day of `date`.
    /// Usage:  request.predicate = .forDay()              // today, key = "timestamp"
    ///         request.predicate = .forDay(someDate)      // specific date
    ///         request.predicate = .forDay(date, key: "date")  // different key
    static func forDay(_ date: Date = Date(), key: String = "timestamp") -> NSPredicate {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return NSPredicate(format: "\(key) >= %@ AND \(key) < %@", start as NSDate, end as NSDate)
    }

    /// Returns the start and end of day for `date` as a tuple (useful when you need
    /// both values separately, e.g. for a compound predicate with an extra condition).
    static func dayBounds(for date: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return (start, end)
    }
}
