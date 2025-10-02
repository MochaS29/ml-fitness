import SwiftUI
import CoreData

struct EnhancedMealPlanningView: View {
    @StateObject private var mealPlanManager = MealPlanManager()
    @State private var showingPlanSelector = false
    @State private var showingShoppingList = false
    @State private var showingMealDetail: Meal?
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
                // Plan type selector
                if let selectedPlan = mealPlanManager.selectedPlanType {
                    PlanTypeBanner(planType: selectedPlan) {
                        showingPlanSelector = true
                    }
                } else {
                    EmptyPlanBanner {
                        showingPlanSelector = true
                    }
                }

                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                if mealPlanManager.selectedPlanType != nil {
                    switch selectedTab {
                    case 0:
                        TodaysMealView(manager: mealPlanManager, showingMealDetail: $showingMealDetail)
                    case 1:
                        WeeklyMealView(manager: mealPlanManager, showingMealDetail: $showingMealDetail)
                    case 2:
                        MonthlyOverviewView(manager: mealPlanManager)
                    default:
                        EmptyView()
                    }
                } else {
                    NoPlanSelectedView {
                        showingPlanSelector = true
                    }
                }
            }
            .navigationTitle("Meal Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingPlanSelector = true }) {
                            Label("Change Plan", systemImage: "arrow.triangle.2.circlepath")
                        }

                        Button(action: { showingShoppingList = true }) {
                            Label("Shopping List", systemImage: "cart")
                        }

                        Button(action: { mealPlanManager.currentWeek = 1 }) {
                            Label("Reset to Week 1", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingPlanSelector) {
                MealPlanSelectorView(manager: mealPlanManager)
            }
            .sheet(isPresented: $showingShoppingList) {
                ShoppingListView(manager: mealPlanManager)
            }
            .sheet(item: $showingMealDetail) { meal in
                MealDetailView(meal: meal, isFavorite: mealPlanManager.favoriteMeals.contains(meal.id)) {
                    mealPlanManager.toggleFavorite(meal.id)
                }
            }
    }
}

// MARK: - Plan Type Banner
struct PlanTypeBanner: View {
    let planType: MealPlanType
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(planType.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(planType.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onTap) {
                Text("Change")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.wellnessGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.wellnessGreen, Color.wellnessGreen.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

struct EmptyPlanBanner: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Select a Meal Plan")
                        .font(.headline)
                    Text("Choose from 5 different diet types")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
    }
}

// MARK: - Today's Meals View
struct TodaysMealView: View {
    @ObservedObject var manager: MealPlanManager
    @Binding var showingMealDetail: Meal?

    private var todaysMeals: DailyMealPlan? {
        guard let weekPlan = manager.getCurrentWeekPlan() else { return nil }
        let dayOfWeek = Calendar.current.component(.weekday, from: Date()) - 1
        guard dayOfWeek >= 0 && dayOfWeek < weekPlan.days.count else { return nil }
        return weekPlan.days[dayOfWeek]
    }

    var body: some View {
        ScrollView {
            if let meals = todaysMeals {
                VStack(spacing: 16) {
                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(Date(), format: .dateTime.weekday(.wide).month().day())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Daily totals
                        VStack(alignment: .trailing, spacing: 2) {
                            let totalCalories = meals.breakfast.calories + meals.lunch.calories + meals.dinner.calories + meals.snacks.reduce(0) { $0 + $1.calories }
                            Text("\(totalCalories)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // Meal cards
                    MealCard(meal: meals.breakfast, mealType: "Breakfast", icon: "sunrise.fill", color: .orange) {
                        showingMealDetail = meals.breakfast
                    }

                    MealCard(meal: meals.lunch, mealType: "Lunch", icon: "sun.max.fill", color: .yellow) {
                        showingMealDetail = meals.lunch
                    }

                    MealCard(meal: meals.dinner, mealType: "Dinner", icon: "moon.fill", color: .purple) {
                        showingMealDetail = meals.dinner
                    }

                    if !meals.snacks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Snacks", systemImage: "leaf.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.horizontal)

                            ForEach(meals.snacks) { snack in
                                MiniMealCard(meal: snack) {
                                    showingMealDetail = snack
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            } else {
                Text("No meals available for today")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

// MARK: - Meal Card
struct MealCard: View {
    let meal: Meal
    let mealType: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var showingAddedAlert = false
    @State private var addedMealName = ""

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(mealType, systemImage: icon)
                        .font(.headline)
                        .foregroundColor(color)

                    Spacer()

                    // Add to Diary button
                    Button(action: {
                        addToDiary()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Diary")
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.wellnessGreen)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(meal.prepTime + meal.cookTime) min")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                Text(meal.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text(meal.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Nutrition info
                HStack(spacing: 16) {
                    NutritionBadge(value: meal.calories, unit: "cal", color: .orange)
                    NutritionBadge(value: Int(meal.protein), unit: "g protein", color: .red)
                    NutritionBadge(value: Int(meal.carbs), unit: "g carbs", color: .blue)
                    NutritionBadge(value: Int(meal.fat), unit: "g fat", color: .green)
                }

                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(meal.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.wellnessGreen.opacity(0.2))
                                .foregroundColor(.wellnessGreen)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Added to Diary", isPresented: $showingAddedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(addedMealName) has been added to your food diary for \(mealType.lowercased()).")
        }
    }

    private func addToDiary() {
        // Map meal type to MealType enum
        let diaryMealType: MealType
        switch mealType.lowercased() {
        case "breakfast":
            diaryMealType = .breakfast
        case "lunch":
            diaryMealType = .lunch
        case "dinner":
            diaryMealType = .dinner
        default:
            diaryMealType = .snack
        }

        // Add each ingredient or the meal as a whole to diary
        dataManager.addFoodEntry(
            name: meal.name,
            calories: Double(meal.calories),
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            fiber: 0, // Add if available in meal data
            sugar: 0, // Add if available in meal data
            sodium: 0, // Add if available in meal data
            servingSize: "1 serving",
            mealType: diaryMealType
        )

        // Show confirmation
        addedMealName = meal.name
        showingAddedAlert = true
    }
}

struct MiniMealCard: View {
    let meal: Meal
    let onTap: () -> Void
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var showingAddedAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Text("\(meal.calories) cal")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(meal.prepTime) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Add to Diary button
                Button(action: {
                    addToDiary()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body)
                        .foregroundColor(.wellnessGreen)
                }
                .buttonStyle(PlainButtonStyle())

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Added to Diary", isPresented: $showingAddedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(meal.name) has been added to your food diary as a snack.")
        }
    }

    private func addToDiary() {
        dataManager.addFoodEntry(
            name: meal.name,
            calories: Double(meal.calories),
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            servingSize: "1 serving",
            mealType: .snack
        )
        showingAddedAlert = true
    }
}

struct NutritionBadge: View {
    let value: Int
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Weekly View
struct WeeklyMealView: View {
    @ObservedObject var manager: MealPlanManager
    @Binding var showingMealDetail: Meal?

    var body: some View {
        ScrollView {
            if let weekPlan = manager.getCurrentWeekPlan() {
                VStack(spacing: 16) {
                    // Week header
                    HStack {
                        Button(action: {
                            if manager.currentWeek > 1 {
                                manager.currentWeek -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                        }
                        .disabled(manager.currentWeek <= 1)

                        Spacer()

                        Text("Week \(manager.currentWeek)")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            if manager.currentWeek < 4 {
                                manager.currentWeek += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                        }
                        .disabled(manager.currentWeek >= 4)
                    }
                    .padding()

                    ForEach(weekPlan.days) { day in
                        DayMealSummaryCard(day: day) { meal in
                            showingMealDetail = meal
                        }
                    }
                }
            }
        }
    }
}

struct DayMealSummaryCard: View {
    let day: DailyMealPlan
    let onMealTap: (Meal) -> Void
    @State private var isExpanded = false

    var totalCalories: Int {
        day.breakfast.calories + day.lunch.calories + day.dinner.calories +
        day.snacks.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.dayName)
                            .font(.headline)
                        Text("\(totalCalories) calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 0) {
                    MealRowItem(meal: day.breakfast, mealType: "Breakfast", onTap: onMealTap)
                    Divider().padding(.leading, 16)
                    MealRowItem(meal: day.lunch, mealType: "Lunch", onTap: onMealTap)
                    Divider().padding(.leading, 16)
                    MealRowItem(meal: day.dinner, mealType: "Dinner", onTap: onMealTap)

                    if !day.snacks.isEmpty {
                        Divider().padding(.leading, 16)
                        ForEach(day.snacks) { snack in
                            MealRowItem(meal: snack, mealType: "Snack", onTap: onMealTap)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MealRowItem: View {
    let meal: Meal
    let mealType: String
    let onTap: (Meal) -> Void

    var body: some View {
        Button(action: { onTap(meal) }) {
            HStack {
                Text(mealType)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("\(meal.calories) cal • \(meal.prepTime + meal.cookTime) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Monthly Overview
struct MonthlyOverviewView: View {
    @ObservedObject var manager: MealPlanManager
    @State private var selectedDate = Date()
    @State private var displayMonth = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var foodEntries: [FoodEntry] = []
    @State private var showingDayDetail = false

    init(manager: MealPlanManager) {
        self.manager = manager
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month header
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.mindfulTeal)
                    }

                    Spacer()

                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mindfulTeal)
                    }
                }
                .padding(.horizontal)

                // Calendar grid
                CalendarGridView(
                    selectedDate: $selectedDate,
                    displayMonth: displayMonth,
                    foodEntries: foodEntries,
                    onDateSelected: {
                        showingDayDetail = true
                    }
                )
                .padding(.horizontal)

                // Legend
                MealTypeLegend()
                    .padding(.horizontal)

                // Selected day details
                if let dayMeals = getMealsForSelectedDate() {
                    SelectedDayDetailView(date: selectedDate, meals: dayMeals)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchFoodEntries()
        }
        .onChange(of: displayMonth) { _ in
            fetchFoodEntries()
        }
        .sheet(isPresented: $showingDayDetail) {
            NavigationView {
                DayDetailView(date: selectedDate, foodEntries: getMealsForSelectedDate() ?? [])
                    .navigationTitle("Daily Meals")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingDayDetail = false
                            }
                        }
                    }
            }
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayMonth)
    }

    private func changeMonth(_ direction: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: direction, to: displayMonth) {
            displayMonth = newDate
            selectedDate = newDate
        }
    }

    private func fetchFoodEntries() {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayMonth) else { return }

        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: true)]
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                                       monthInterval.start as NSDate,
                                       monthInterval.end as NSDate)

        // Add fetch optimizations to prevent memory issues
        request.fetchBatchSize = 20  // Load data in batches
        request.returnsObjectsAsFaults = false  // Prevent faulting overhead
        request.includesPropertyValues = true  // Include all properties to avoid faulting
        request.relationshipKeyPathsForPrefetching = []  // No relationships to prefetch

        do {
            // Use autoreleasepool to manage memory during fetch
            try autoreleasepool {
                foodEntries = try viewContext.fetch(request)
            }

            // Debug: Log fetched entries
            print("Fetched \(foodEntries.count) food entries for month \(displayMonth)")

            // Debug: Show unique dates with meals
            let uniqueDates = Set(foodEntries.compactMap { entry -> Date? in
                guard let timestamp = entry.timestamp else { return nil }
                return Calendar.current.startOfDay(for: timestamp)
            })
            print("Days with meals: \(uniqueDates.count)")

        } catch {
            print("Error fetching food entries: \(error)")
            foodEntries = []
        }
    }

    private func getMealsForSelectedDate() -> [FoodEntry]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let dayMeals = foodEntries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= startOfDay && timestamp < endOfDay
        }

        return dayMeals.isEmpty ? nil : Array(dayMeals)
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let displayMonth: Date
    let foodEntries: [FoodEntry]
    let onDateSelected: () -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 10) {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        EnhancedCalendarDayView(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            meals: getMealsForDate(date)
                        ) {
                            selectedDate = date
                            onDateSelected()
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
    }

    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayMonth) else {
            return []
        }

        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        let numberOfDays = calendar.range(of: .day, in: .month, for: displayMonth)?.count ?? 0
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func getMealsForDate(_ date: Date) -> MealDots {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        var mealDots = MealDots()
        var dayMealCount = 0

        // Use early exit to minimize processing
        for entry in foodEntries {
            // Check all meal types are set before continuing
            if mealDots.hasBreakfast && mealDots.hasLunch &&
               mealDots.hasDinner && mealDots.hasSnack {
                break  // All dots set, no need to continue
            }

            guard let timestamp = entry.timestamp,
                  timestamp >= startOfDay && timestamp < endOfDay,
                  let mealType = entry.mealType else { continue }

            switch mealType {
            case "Breakfast" where !mealDots.hasBreakfast:
                mealDots.hasBreakfast = true
                dayMealCount += 1
            case "Lunch" where !mealDots.hasLunch:
                mealDots.hasLunch = true
                dayMealCount += 1
            case "Dinner", "Supper" where !mealDots.hasDinner:
                mealDots.hasDinner = true
                dayMealCount += 1
            case "Snack", "Snacks" where !mealDots.hasSnack:
                mealDots.hasSnack = true
                dayMealCount += 1
            default:
                break
            }
        }

        // Debug: Log if this day has meals
        if dayMealCount > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            print("Date \(formatter.string(from: date)) has \(dayMealCount) meal types")
        }

        return mealDots
    }
}

// MARK: - Calendar Day View
struct EnhancedCalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let meals: MealDots
    let onTap: () -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .regular))
                    .foregroundColor(isToday ? .mindfulTeal : .primary)

                // Meal dots
                HStack(spacing: 2) {
                    if meals.hasBreakfast {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                    }
                    if meals.hasLunch {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                    }
                    if meals.hasDinner {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 6, height: 6)
                    }
                    if meals.hasSnack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.mindfulTeal.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.mindfulTeal : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Meal Dots Structure
struct MealDots {
    var hasBreakfast = false
    var hasLunch = false
    var hasDinner = false
    var hasSnack = false
}

// MARK: - Meal Type Legend
struct MealTypeLegend: View {
    var body: some View {
        HStack(spacing: 20) {
            LegendItem(color: .orange, text: "Breakfast")
            LegendItem(color: .blue, text: "Lunch")
            LegendItem(color: .purple, text: "Dinner")
            LegendItem(color: .green, text: "Snacks")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Food Entry Detail View
struct FoodEntryDetailView: View {
    let foodEntry: FoodEntry
    @Environment(\.dismiss) private var dismiss
    @State private var recipe: RecipeModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Food Name and Basic Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(foodEntry.name ?? "Unknown Food")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if let mealType = foodEntry.mealType {
                        Label(mealType, systemImage: mealIconForType(mealType))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("Consumed on \(foodEntry.timestamp ?? Date(), formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                // Nutrition Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nutrition Facts")
                        .font(.headline)

                    VStack(spacing: 12) {
                        FoodNutritionRow(label: "Calories", value: "0", unit: "cal", color: .orange)
                        FoodNutritionRow(label: "Protein", value: String(format: "%.1f", foodEntry.protein), unit: "g", color: .blue)
                        FoodNutritionRow(label: "Carbohydrates", value: String(format: "%.1f", foodEntry.carbs), unit: "g", color: .brown)
                        FoodNutritionRow(label: "Fat", value: String(format: "%.1f", foodEntry.fat), unit: "g", color: .purple)
                        FoodNutritionRow(label: "Fiber", value: String(format: "%.1f", foodEntry.fiber), unit: "g", color: .green)
                        FoodNutritionRow(label: "Sugar", value: String(format: "%.1f", foodEntry.sugar), unit: "g", color: .pink)
                        FoodNutritionRow(label: "Sodium", value: String(format: "%.0f", foodEntry.sodium), unit: "mg", color: .red)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                // Recipe Information (if available)
                if let recipeName = foodEntry.name,
                   let recipe = findRecipe(named: recipeName) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recipe Details")
                            .font(.headline)

                        if !recipe.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ingredients")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                ForEach(recipe.ingredients) { ingredient in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 4))
                                            .foregroundColor(.secondary)
                                        Text("\(ingredient.name) - \(Int(ingredient.amount)) \(ingredient.unit.rawValue)")
                                            .font(.caption)
                                    }
                                }
                            }
                        }

                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack {
                                Text("View Full Recipe")
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .foregroundColor(.mindfulTeal)
                            .padding()
                            .background(Color.mindfulTeal.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }

    private func findRecipe(named: String) -> RecipeModel? {
        // Try to find a matching recipe in the database
        if let matchingRecipe = RecipeDatabase.shared.recipes.first(where: {
            $0.name.lowercased() == named.lowercased()
        }) {
            return matchingRecipe
        }

        // Try to find in meal plan data - check all categories
        let allPlans = MealPlanData.shared.allMealPlans
        for plan in allPlans {
            for week in plan.monthlyPlans {
                for day in week.days {
                    // Check breakfast (not optional)
                    if day.breakfast.name.lowercased() == named.lowercased() {
                        return convertMealToRecipe(day.breakfast)
                    }
                    // Check lunch (not optional)
                    if day.lunch.name.lowercased() == named.lowercased() {
                        return convertMealToRecipe(day.lunch)
                    }
                    // Check dinner (not optional)
                    if day.dinner.name.lowercased() == named.lowercased() {
                        return convertMealToRecipe(day.dinner)
                    }
                    // Check snacks
                    for snack in day.snacks {
                        if snack.name.lowercased() == named.lowercased() {
                            return convertMealToRecipe(snack)
                        }
                    }
                }
            }
        }

        return nil
    }

    private func convertMealToRecipe(_ meal: Meal) -> RecipeModel {
        // Convert string ingredients to IngredientModel
        let ingredientModels = meal.ingredients.map { ingredientString in
            IngredientModel(
                name: ingredientString,
                amount: 1,
                unit: .piece,
                category: .other
            )
        }

        // Create nutrition info
        let nutrition = NutritionInfo(
            calories: Double(meal.calories),
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            fiber: meal.fiber,
            sugar: nil,  // Meal doesn't have sugar property
            sodium: nil  // Meal doesn't have sodium property
        )

        // Determine category based on meal name or default to dinner
        let category: RecipeCategory = .dinner

        return RecipeModel(
            name: meal.name,
            category: category,
            prepTime: meal.prepTime,
            cookTime: meal.cookTime,
            servings: 1,
            ingredients: ingredientModels,
            instructions: meal.instructions,
            nutrition: nutrition,
            tags: meal.tags
        )
    }

    private func mealIconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "breakfast": return "sunrise.fill"
        case "lunch": return "sun.max.fill"
        case "dinner", "supper": return "moon.stars.fill"
        case "snacks", "snack": return "leaf.fill"
        default: return "fork.knife"
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct FoodNutritionRow: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.subheadline)

            Spacer()

            Text("\(value) \(unit)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Day Detail View (Full Screen)
struct DayDetailView: View {
    let date: Date
    let foodEntries: [FoodEntry]
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddFood = false
    @State private var selectedFoodEntry: FoodEntry?

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private var mealsByType: [(String, [FoodEntry])] {
        let grouped = Dictionary(grouping: foodEntries) { $0.mealType ?? "Other" }
        let order = ["Breakfast", "Lunch", "Dinner", "Snacks"]
        return order.compactMap { mealType in
            if let entries = grouped[mealType], !entries.isEmpty {
                return (mealType, entries)
            }
            return nil
        }
    }

    private var totalCalories: Int {
        foodEntries.reduce(0) { $0 + Int($1.calories) }
    }

    private var totalProtein: Double {
        foodEntries.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        foodEntries.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        foodEntries.reduce(0) { $0 + $1.fat }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                dateHeaderView
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)

                // Meals by Type
                if mealsByType.isEmpty {
                    emptyStateView
                } else {
                    mealsListView
                }

                // Add Meal Button
                if !mealsByType.isEmpty {
                    Button(action: { showingAddFood = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Another Meal")
                        }
                        .font(.headline)
                        .foregroundColor(.mindfulTeal)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddFood) {
            // This would navigate to the food tracking view
            Text("Add Food View")
        }
        .sheet(item: $selectedFoodEntry) { foodEntry in
            NavigationView {
                FoodEntryDetailView(foodEntry: foodEntry)
                    .navigationTitle("Meal Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                selectedFoodEntry = nil
                            }
                        }
                    }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No meals tracked for this day")
                .font(.headline)
                .foregroundColor(.secondary)

            Button(action: { showingAddFood = true }) {
                Label("Add Meal", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.mindfulTeal)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var mealsListView: some View {
        ForEach(mealsByType, id: \.0) { mealType, entries in
            mealTypeSection(mealType: mealType, entries: entries)
        }
    }

    private func mealTypeSection(mealType: String, entries: [FoodEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Meal Type Header
            HStack {
                Circle()
                    .fill(colorForMealType(mealType))
                    .frame(width: 12, height: 12)

                Text(mealType)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(entries.reduce(0) { $0 + Int($1.calories) }) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Food Items
            VStack(spacing: 8) {
                ForEach(entries) { entry in
                    foodItemRow(entry: entry)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func foodItemRow(entry: FoodEntry) -> some View {
        Button(action: {
            selectedFoodEntry = entry
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name ?? "Unknown")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text("P: \(Int(entry.protein))g • C: \(Int(entry.carbs))g • F: \(Int(entry.fat))g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(Int(entry.calories)) cal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var dateHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dateString)
                .font(.title2)
                .fontWeight(.bold)

            // Nutrition Summary
            HStack(spacing: 20) {
                DayNutritionSummaryItem(label: "Calories", value: "0", color: .orange)
                DayNutritionSummaryItem(label: "Protein", value: String(format: "%.0fg", totalProtein), color: .blue)
                DayNutritionSummaryItem(label: "Carbs", value: String(format: "%.0fg", totalCarbs), color: .brown)
                DayNutritionSummaryItem(label: "Fat", value: String(format: "%.0fg", totalFat), color: .purple)
            }
        }
    }

    private func colorForMealType(_ mealType: String) -> Color {
        switch mealType.lowercased() {
        case "breakfast": return .orange
        case "lunch": return .blue
        case "dinner", "supper": return .purple
        case "snacks", "snack": return .green
        default: return .gray
        }
    }
}

struct DayNutritionSummaryItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Selected Day Detail View
struct SelectedDayDetailView: View {
    let date: Date
    let meals: [FoodEntry]

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var mealsByType: [String: [FoodEntry]] {
        Dictionary(grouping: meals) { $0.mealType ?? "Other" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateString)
                .font(.headline)

            ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
                if let typeMeals = mealsByType[mealType], !typeMeals.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(colorForMealType(mealType))
                                .frame(width: 10, height: 10)
                            Text(mealType)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        ForEach(typeMeals) { meal in
                            HStack {
                                Text(meal.name ?? "Unknown")
                                    .font(.caption)
                                Spacer()
                                Text("\(Int(meal.calories)) cal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 14)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func colorForMealType(_ mealType: String) -> Color {
        switch mealType.lowercased() {
        case "breakfast": return .orange
        case "lunch": return .blue
        case "dinner", "supper": return .purple
        case "snacks", "snack": return .green
        default: return .gray
        }
    }
}

struct WeekOverviewCard: View {
    let week: WeeklyMealPlan
    let weekNumber: Int

    var averageCalories: Int {
        let total = week.days.reduce(0) { sum, day in
            sum + day.breakfast.calories + day.lunch.calories + day.dinner.calories +
            day.snacks.reduce(0) { $0 + $1.calories }
        }
        return total / week.days.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Week \(weekNumber)")
                    .font(.headline)

                Spacer()

                Text("Avg: \(averageCalories) cal/day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Quick preview of meals
            HStack(spacing: 4) {
                ForEach(0..<min(3, week.days.count), id: \.self) { index in
                    Text(week.days[index].breakfast.name)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.wellnessGreen.opacity(0.2))
                        .cornerRadius(4)
                }

                if week.days.count > 3 {
                    Text("+\(week.days.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Meal Plan Selector
struct MealPlanSelectorView: View {
    @ObservedObject var manager: MealPlanManager
    @Environment(\.dismiss) private var dismiss

    private let planData = MealPlanData.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(planData.allMealPlans) { plan in
                        PlanTypeCard(plan: plan, isSelected: manager.selectedPlanType?.id == plan.id) {
                            manager.selectPlan(plan.id)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct PlanTypeCard: View {
    let plan: MealPlanType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(plan.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.wellnessGreen)
                    }
                }

                Text(plan.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                // Benefits
                VStack(alignment: .leading, spacing: 4) {
                    Text("Benefits:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    ForEach(plan.benefits.prefix(3), id: \.self) { benefit in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.wellnessGreen)
                            Text(benefit)
                                .font(.caption)
                        }
                    }
                }

                // Restrictions
                if !plan.restrictions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Considerations:")
                            .font(.caption)
                            .fontWeight(.semibold)

                        ForEach(plan.restrictions.prefix(2), id: \.self) { restriction in
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text(restriction)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.wellnessGreen : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Meal Detail View
struct MealDetailView: View {
    let meal: Meal
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(meal.description)
                .font(.body)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Label("\(meal.prepTime + meal.cookTime) min", systemImage: "clock")
                Label("\(meal.calories) calories", systemImage: "flame")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition")
                .font(.headline)

            HStack(spacing: 12) {
                NutritionCard(label: "Protein", value: "0", color: .red)
                NutritionCard(label: "Carbs", value: "0", color: .blue)
                NutritionCard(label: "Fat", value: "0", color: .green)
                NutritionCard(label: "Fiber", value: "0", color: .orange)
            }
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            ForEach(meal.ingredients, id: \.self) { ingredient in
                HStack {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ingredient)
                        .font(.body)
                }
            }
        }
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)

            ForEach(Array(meal.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.wellnessGreen)
                        .clipShape(Circle())

                    Text(instruction)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)

            FlowLayout(items: meal.tags) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.wellnessGreen.opacity(0.2))
                    .foregroundColor(.wellnessGreen)
                    .cornerRadius(15)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    nutritionSection
                    ingredientsSection

                    instructionsSection

                    if !meal.tags.isEmpty {
                        tagsSection
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                    }
                }
            }
        }
    }
}

struct NutritionCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// Flow layout for tags
struct MealPlanFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = MealPlanFlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = MealPlanFlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    struct MealPlanFlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxWidth = max(maxWidth, currentX - spacing)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Shopping List View
struct ShoppingListView: View {
    @ObservedObject var manager: MealPlanManager
    @Environment(\.dismiss) private var dismiss
    @State private var checkedItems: Set<String> = []

    var body: some View {
        NavigationView {
            List {
                if manager.shoppingList.isEmpty {
                    Text("No shopping list generated")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(manager.shoppingList, id: \.self) { item in
                        HStack {
                            Button(action: {
                                if checkedItems.contains(item) {
                                    checkedItems.remove(item)
                                } else {
                                    checkedItems.insert(item)
                                }
                            }) {
                                Image(systemName: checkedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(checkedItems.contains(item) ? .wellnessGreen : .gray)
                            }

                            Text(item)
                                .strikethrough(checkedItems.contains(item))
                                .foregroundColor(checkedItems.contains(item) ? .secondary : .primary)

                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate") {
                        if let weekPlan = manager.getCurrentWeekPlan() {
                            manager.generateShoppingList(for: weekPlan)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - No Plan Selected View
struct NoPlanSelectedView: View {
    let onSelectPlan: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(.wellnessGreen)

            Text("No Meal Plan Selected")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose from 5 different diet types with full monthly menus")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onSelectPlan) {
                Text("Choose a Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.wellnessGreen)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}