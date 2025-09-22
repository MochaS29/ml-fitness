import SwiftUI
import CoreData

struct MealPlanningView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var showingGroceryList = false
    @State private var showingGenerateSuggestions = false
    @State private var isGeneratingSuggestions = false
    
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

                        Button(action: { showingGenerateSuggestions = true }) {
                            Label("Generate Month Plan", systemImage: "wand.and.stars")
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
            .sheet(isPresented: $showingGenerateSuggestions) {
                GenerateMealSuggestionsView(selectedDate: selectedDate)
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
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var showingAddedAlert = false
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

            if showingAddedAlert {
                Text("Added!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.wellnessGreen)
                    .transition(.scale.combined(with: .opacity))
            }

            if mealPlan.servings > 1 {
                Text("\(mealPlan.servings) servings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Quick Add to Diary button
            Button(action: addToDiary) {
                Image(systemName: "plus.app")
                    .font(.body)
                    .foregroundColor(.mindfulTeal)
            }
            .buttonStyle(.plain)

            Menu {
                Button(action: addToDiary) {
                    Label("Add to Today's Diary", systemImage: "plus.app")
                }

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

    private func addToDiary() {
        // Create a food entry from the meal plan
        let calories = mealPlan.calories > 0 ? mealPlan.calories : 300 // Default if not set
        let protein = mealPlan.protein > 0 ? mealPlan.protein : 15
        let carbs = mealPlan.carbohydrates > 0 ? mealPlan.carbohydrates : 30
        let fat = mealPlan.fat > 0 ? mealPlan.fat : 10

        dataManager.addFoodEntry(
            name: mealPlan.recipeName ?? "Meal",
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            servingSize: "\(mealPlan.servings) serving\(mealPlan.servings > 1 ? "s" : "")",
            mealType: mealType.rawValue
        )

        // Show confirmation
        showingAddedAlert = true

        // Hide alert after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingAddedAlert = false
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

// Generate meal suggestions view
struct GenerateMealSuggestionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date

    @State private var isGenerating = false
    @State private var progress: Double = 0
    @State private var currentMessage = "Preparing meal suggestions..."
    @State private var selectedDuration = 30 // Days
    @State private var dietaryPreference = "Balanced"
    @State private var mealsPerDay = 3
    @State private var includeSnacks = true

    let dietaryOptions = ["Balanced", "Vegetarian", "Vegan", "Low Carb", "High Protein", "Mediterranean"]

    // Sample meal database
    let mealSuggestions: [String: [(name: String, calories: Int, protein: Double, carbs: Double, fat: Double)]] = [
        "Breakfast": [
            ("Oatmeal with Berries", 350, 10, 60, 8),
            ("Greek Yogurt Parfait", 280, 20, 35, 6),
            ("Scrambled Eggs with Toast", 420, 25, 30, 20),
            ("Avocado Toast", 380, 12, 40, 22),
            ("Protein Smoothie Bowl", 400, 25, 45, 12),
            ("Whole Grain Pancakes", 450, 15, 65, 15),
            ("Veggie Omelet", 320, 24, 12, 20)
        ],
        "Lunch": [
            ("Grilled Chicken Salad", 450, 35, 25, 22),
            ("Quinoa Buddha Bowl", 480, 18, 60, 18),
            ("Turkey Sandwich", 420, 28, 45, 15),
            ("Salmon Poke Bowl", 520, 30, 55, 20),
            ("Mediterranean Wrap", 480, 22, 52, 20),
            ("Chicken Burrito Bowl", 550, 35, 65, 18),
            ("Vegetable Stir Fry", 380, 15, 50, 15)
        ],
        "Dinner": [
            ("Grilled Salmon with Vegetables", 520, 40, 25, 28),
            ("Chicken Breast with Sweet Potato", 480, 38, 45, 12),
            ("Beef Stir Fry with Brown Rice", 580, 35, 55, 22),
            ("Pasta Primavera", 450, 18, 65, 15),
            ("Turkey Chili", 420, 30, 40, 15),
            ("Baked Cod with Quinoa", 460, 35, 40, 16),
            ("Vegetable Curry with Rice", 480, 12, 70, 18)
        ],
        "Snack": [
            ("Apple with Peanut Butter", 200, 5, 25, 10),
            ("Protein Bar", 220, 20, 25, 8),
            ("Trail Mix", 180, 6, 20, 10),
            ("Hummus with Veggies", 150, 6, 20, 8),
            ("Greek Yogurt", 120, 15, 10, 3),
            ("Mixed Nuts", 200, 7, 8, 18),
            ("Fruit Smoothie", 180, 5, 35, 2)
        ]
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !isGenerating {
                    // Settings
                    Form {
                        Section("Duration") {
                            Picker("Generate meals for", selection: $selectedDuration) {
                                Text("1 Week").tag(7)
                                Text("2 Weeks").tag(14)
                                Text("1 Month").tag(30)
                            }
                            .pickerStyle(.segmented)
                        }

                        Section("Preferences") {
                            Picker("Dietary Preference", selection: $dietaryPreference) {
                                ForEach(dietaryOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }

                            Stepper("Meals per day: \(mealsPerDay)", value: $mealsPerDay, in: 2...4)

                            Toggle("Include snacks", isOn: $includeSnacks)
                        }

                        Section {
                            Button(action: generateMealPlans) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "wand.and.stars")
                                    Text("Generate Meal Plan")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                            }
                            .foregroundColor(.white)
                            .listRowBackground(Color.mindfulTeal)
                        }
                    }
                } else {
                    // Generating animation
                    VStack(spacing: 30) {
                        Spacer()

                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                .frame(width: 150, height: 150)

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(colors: [.mindfulTeal, .wellnessGreen],
                                                   startPoint: .leading,
                                                   endPoint: .trailing),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.5), value: progress)

                            VStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(.mindfulTeal)
                                Text("\(Int(progress * 100))%")
                                    .font(.headline)
                            }
                        }

                        Text(currentMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer()
                    }
                }
            }
            .navigationTitle("Generate Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func generateMealPlans() {
        isGenerating = true
        progress = 0
        currentMessage = "Analyzing dietary preferences..."

        // Simulate meal plan generation with progress updates
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let totalDays = selectedDuration
            let startDate = calendar.startOfDay(for: selectedDate)

            for dayOffset in 0..<totalDays {
                guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }

                // Update progress
                DispatchQueue.main.async {
                    self.progress = Double(dayOffset + 1) / Double(totalDays)
                    self.currentMessage = "Creating meals for day \(dayOffset + 1) of \(totalDays)..."
                }

                // Generate meals for this day
                generateDayMeals(for: targetDate)

                // Small delay to show progress
                Thread.sleep(forTimeInterval: 0.05)
            }

            DispatchQueue.main.async {
                self.currentMessage = "Finalizing meal plan..."

                // Save and dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    do {
                        try self.viewContext.save()
                        self.dismiss()
                    } catch {
                        print("Failed to save meal plans: \(error)")
                    }
                }
            }
        }
    }

    private func generateDayMeals(for date: Date) {
        // Generate breakfast
        if let breakfast = mealSuggestions["Breakfast"]?.randomElement() {
            createMealPlan(
                date: date,
                mealType: .breakfast,
                name: breakfast.name,
                calories: breakfast.calories,
                protein: breakfast.protein,
                carbs: breakfast.carbs,
                fat: breakfast.fat
            )
        }

        // Generate lunch
        if mealsPerDay >= 2, let lunch = mealSuggestions["Lunch"]?.randomElement() {
            createMealPlan(
                date: date,
                mealType: .lunch,
                name: lunch.name,
                calories: lunch.calories,
                protein: lunch.protein,
                carbs: lunch.carbs,
                fat: lunch.fat
            )
        }

        // Generate dinner
        if mealsPerDay >= 3, let dinner = mealSuggestions["Dinner"]?.randomElement() {
            createMealPlan(
                date: date,
                mealType: .dinner,
                name: dinner.name,
                calories: dinner.calories,
                protein: dinner.protein,
                carbs: dinner.carbs,
                fat: dinner.fat
            )
        }

        // Generate snacks
        if includeSnacks, let snack = mealSuggestions["Snack"]?.randomElement() {
            createMealPlan(
                date: date,
                mealType: .snack,
                name: snack.name,
                calories: snack.calories,
                protein: snack.protein,
                carbs: snack.carbs,
                fat: snack.fat
            )
        }
    }

    private func createMealPlan(date: Date, mealType: MealType, name: String, calories: Int, protein: Double, carbs: Double, fat: Double) {
        let mealPlan = MealPlan(context: viewContext)
        mealPlan.id = UUID()
        mealPlan.date = date
        mealPlan.mealType = mealType.rawValue
        mealPlan.recipeName = name
        mealPlan.calories = Int32(calories)
        mealPlan.protein = protein
        mealPlan.carbohydrates = carbs
        mealPlan.fat = fat
        mealPlan.servings = 1
        mealPlan.createdAt = Date()

        // Add some variety to notes based on meal type
        switch mealType {
        case .breakfast:
            mealPlan.notes = "Healthy start to your day"
        case .lunch:
            mealPlan.notes = "Balanced midday meal"
        case .dinner:
            mealPlan.notes = "Nutritious evening meal"
        case .snack:
            mealPlan.notes = "Energy boost"
        }
    }
}

// #Preview {
//     MealPlanningView()
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }