#!/bin/bash

echo "🔧 Fixing compilation errors..."

# Fix DashboardOption1View
sed -i '' 's/StatCard(title: "Calories", value: .*)/StatCard(title: "Calories", value: totalCalories)/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/DashboardOption1View.swift

# Fix DashboardOption2View
sed -i '' 's/CircularProgressView(progress: 0.0, target: nil/CircularProgressView(progress: 0.0/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/DashboardOption2View.swift

# Fix DashboardOption4View
sed -i '' 's/QuickStatCard(title: .*, value: 0.0, target: nil/QuickStatCard(title: \1, value: "0"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/DashboardOption4View.swift

# Fix DashboardView
sed -i '' 's/NutritionCard(.*value: \([0-9.]*\), target: nil/NutritionCard(\1value: "\1"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/DashboardView.swift

# Fix DiaryView - SummaryMetric
sed -i '' 's/SummaryMetric(.*value: 0.0, target: nil/SummaryMetric(\1value: "\1"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/DiaryView.swift

# Fix ExerciseTrackingView
sed -i '' 's/ExerciseSummaryMetric(.*value: 0.0, target: nil/ExerciseSummaryMetric(\1value: "0"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/ExerciseTrackingView.swift

# Fix EnhancedMealPlanningView
sed -i '' 's/FoodNutritionRow(label: "Calories", value: 0.0, target: nil/FoodNutritionRow(label: "Calories", value: String(format: "%.0f", foodEntry.calories)/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/EnhancedMealPlanningView.swift
sed -i '' 's/DayNutritionSummaryItem(label: "Calories", value: 0.0, target: nil/DayNutritionSummaryItem(label: "Calories", value: String(format: "%.0f", totalCalories)/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/EnhancedMealPlanningView.swift
sed -i '' 's/NutritionCard(.*value: 0.0, target: nil/NutritionCard(\1value: "0"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/EnhancedMealPlanningView.swift

# Fix FoodScanResultsView
sed -i '' 's/NutritionSummaryItem(.*value: 0.0, target: nil/NutritionSummaryItem(\1value: "0"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/FoodScanResultsView.swift

# Fix GoalsView
sed -i '' 's/GoalProgressCard(.*value: \([0-9.]*\), target: nil/GoalProgressCard(\1value: "\1"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/GoalsView.swift

# Fix HybridDashboardView
sed -i '' 's/MetricCard(.*value: 0.0, target:/MetricCard(\1value: "0"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/HybridDashboardView.swift

# Fix IntermittentFastingView
sed -i '' 's/FastingMetric(.*value: .*, target: nil/FastingMetric(\1value: \2/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/IntermittentFastingView.swift

# Fix OnboardingView
sed -i '' 's/ProfileSummaryRow(label: "Age", value: 0.0, target: nil/ProfileSummaryRow(label: "Age", value: "\\(age)"/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/OnboardingView.swift

# Fix ProfessionalDashboardView
sed -i '' 's/QuickStatItem(.*value: .*, target: nil/QuickStatItem(\1value: \2/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/ProfessionalDashboardView.swift

# Fix ProfileView
sed -i '' 's/ProfileRow(.*value: .*, target: nil/ProfileRow(\1value: \2/g' /Users/mocha/Development/iOS-Apps/HealthTracker/HealthTracker/Views/ProfileView.swift

echo "✅ Fixes applied!"