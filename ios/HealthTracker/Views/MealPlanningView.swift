import SwiftUI
import CoreData

struct MealPlanningView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var showingGroceryList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Week").tag(0)
                    Text("Month").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if selectedTab == 0 {
                    WeeklyMealPlanView(selectedDate: $selectedDate)
                } else {
                    MonthlyMealCalendarView(selectedDate: $selectedDate)
                }
            }
            .navigationTitle("Meal Planning")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddMeal = true }) {
                            Label("Add Meal", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showingGroceryList = true }) {
                            Label("Grocery List", systemImage: "cart")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealPlanView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingGroceryList) {
                GroceryListGeneratorView()
            }
        }
    }
}

// Weekly meal plan view
struct WeeklyMealPlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    @State private var weekOffset = 0
    
    var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button(action: { changeWeek(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(weekRangeText)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { changeWeek(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Weekly view
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(weekDates, id: \.self) { date in
                        DayMealPlanCard(date: date)
                    }
                }
                .padding()
            }
        }
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        if let first = weekDates.first, let last = weekDates.last {
            return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
        }
        return ""
    }
    
    private func changeWeek(_ direction: Int) {
        withAnimation {
            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: direction, to: selectedDate) {
                selectedDate = newDate
            }
        }
    }
}

// Day meal plan card
struct DayMealPlanCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    let date: Date
    @State private var showingAddMeal = false
    @State private var selectedMealType: MealType = .breakfast
    
    @FetchRequest private var mealPlans: FetchedResults<MealPlan>
    
    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        _mealPlans = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.mealType, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date, format: .dateTime.weekday(.wide))
                        .font(.headline)
                        .foregroundColor(isToday ? .wellnessGreen : .primary)
                    
                    Text(date, format: .dateTime.day().month())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isToday {
                    Text("TODAY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.wellnessGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.wellnessGreen.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            // Meals
            if mealPlans.isEmpty {
                Text("No meals planned")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        if let mealPlan = mealPlans.first(where: { $0.mealType == mealType.rawValue }) {
                            MealPlanRow(mealPlan: mealPlan, mealType: mealType)
                        }
                    }
                }
            }
            
            // Quick add button
            Button(action: {
                showingAddMeal = true
            }) {
                Label("Add Meal", systemImage: "plus.circle")
                    .font(.subheadline)
                    .foregroundColor(.wellnessGreen)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddMeal) {
            AddMealPlanView(selectedDate: date)
        }
    }
}

// Meal plan row
struct MealPlanRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    let mealPlan: MealPlan
    let mealType: MealType
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: mealTypeIcon)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mealType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(mealPlan.recipeName ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let notes = mealPlan.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if mealPlan.servings > 1 {
                Text("\(mealPlan.servings) servings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Menu {
                Button(action: {
                    // Edit meal
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    viewContext.delete(mealPlan)
                    try? viewContext.save()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var mealTypeIcon: String {
        switch mealType {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

// Monthly calendar view
struct MonthlyMealCalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    @State private var selectedMonth = Date()
    
    @FetchRequest private var monthlyMealPlans: FetchedResults<MealPlan>
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: Date())?.end ?? Date()
        
        _monthlyMealPlans = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.date, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        )
    }
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Month navigation
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: selectedMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Calendar grid
            ScrollView {
                VStack(spacing: 8) {
                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                            Text(weekday)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(monthDays, id: \.self) { date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    hasMeals: hasMeals(on: date),
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                                )
                                .onTapGesture {
                                    selectedDate = date
                                }
                            } else {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected date details
                    if calendar.isDate(selectedDate, equalTo: selectedMonth, toGranularity: .month) {
                        SelectedDateMealsView(date: selectedDate)
                            .padding()
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            selectedMonth = selectedDate
        }
    }
    
    private var monthDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty days for the first week
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for dayOffset in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasMeals(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return monthlyMealPlans.contains { mealPlan in
            if let mealDate = mealPlan.date {
                return mealDate >= startOfDay && mealDate < endOfDay
            }
            return false
        }
    }
    
    private func changeMonth(_ direction: Int) {
        withAnimation {
            if let newMonth = calendar.date(byAdding: .month, value: direction, to: selectedMonth) {
                selectedMonth = newMonth
                updateFetchRequest()
            }
        }
    }
    
    private func updateFetchRequest() {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.end ?? selectedMonth
        
        monthlyMealPlans.nsPredicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfMonth as NSDate,
            endOfMonth as NSDate
        )
    }
}

// Calendar day view with circle indicator
struct CalendarDayView: View {
    let date: Date
    let hasMeals: Bool
    let isSelected: Bool
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.wellnessGreen.opacity(0.2) : Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isToday ? Color.wellnessGreen : Color.clear, lineWidth: 2)
                )
            
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .semibold : .regular))
                    .foregroundColor(isToday ? .wellnessGreen : .primary)
                
                // Meal indicator circle
                if hasMeals {
                    Circle()
                        .fill(Color.wellnessGreen)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(height: 44)
    }
}

// Selected date meals view
struct SelectedDateMealsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let date: Date
    @State private var showingAddMeal = false
    
    @FetchRequest private var mealPlans: FetchedResults<MealPlan>
    
    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        _mealPlans = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.mealType, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date, format: .dateTime.weekday(.wide).day().month())
                        .font(.headline)
                    
                    Text("\(mealPlans.count) meals planned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingAddMeal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.wellnessGreen)
                }
            }
            
            if mealPlans.isEmpty {
                Text("No meals planned for this day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(mealPlans) { mealPlan in
                        HStack {
                            Text(mealPlan.mealType ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(mealPlan.recipeName ?? "Unknown")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if mealPlan.servings > 1 {
                                Text("\(mealPlan.servings) servings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showingAddMeal) {
            AddMealPlanView(selectedDate: date)
        }
    }
}

#Preview {
    MealPlanningView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}