package com.mochasmindlab.mlhealth.utils

import com.mochasmindlab.mlhealth.viewmodel.DiaryUiState
import java.text.SimpleDateFormat
import java.util.Locale

object DiaryShareFormatter {

    fun format(state: DiaryUiState): String {
        val dateFormatter = SimpleDateFormat("MMMM d, yyyy", Locale.getDefault())
        val dateStr = dateFormatter.format(state.selectedDate)
        val divider = "───────────────────"

        val sb = StringBuilder()
        sb.appendLine("MindLab Fitness — $dateStr")
        sb.appendLine(divider)

        // Meal sections
        appendMealSection(sb, "BREAKFAST", state.breakfastEntries)
        appendMealSection(sb, "LUNCH", state.lunchEntries)
        appendMealSection(sb, "DINNER", state.dinnerEntries)
        appendMealSection(sb, "SNACKS", state.snackEntries)

        // Exercise section
        if (state.exerciseEntries.isNotEmpty()) {
            sb.appendLine()
            sb.appendLine("EXERCISE")
            state.exerciseEntries.forEach { ex ->
                sb.appendLine("• ${ex.name} — ${ex.duration} min — ${ex.caloriesBurned} cal burned")
            }
        }

        // Supplements section
        if (state.supplementEntries.isNotEmpty()) {
            sb.appendLine()
            sb.appendLine("SUPPLEMENTS")
            state.supplementEntries.forEach { sup ->
                sb.appendLine("• ${sup.name} — ${sup.amount} — ${sup.time}")
            }
        }

        // Totals
        sb.appendLine()
        sb.appendLine(divider)
        sb.appendLine("DAILY TOTALS")
        sb.appendLine("Calories: ${formatNumber(state.totalCalories)} / ${formatNumber(state.caloriesGoal)}")
        sb.appendLine(
            "Protein: ${state.totalProtein.toInt()}g · " +
            "Carbs: ${state.totalCarbs.toInt()}g · " +
            "Fat: ${state.totalFat.toInt()}g"
        )
        sb.append("Water: ${state.waterCups} / ${state.waterGoal} cups")

        return sb.toString()
    }

    private fun appendMealSection(
        sb: StringBuilder,
        label: String,
        entries: List<com.mochasmindlab.mlhealth.ui.screens.FoodEntryDisplay>
    ) {
        if (entries.isEmpty()) return
        val totalCal = entries.sumOf { it.calories }
        sb.appendLine()
        sb.appendLine("$label  ($totalCal cal)")
        entries.forEach { entry ->
            val qty = if (entry.quantity == entry.quantity.toLong().toFloat()) {
                entry.quantity.toLong().toString()
            } else {
                entry.quantity.toString()
            }
            sb.appendLine(
                "• ${entry.name} — $qty ${entry.unit} — ${entry.calories} cal · " +
                "${entry.protein.toInt()}p / ${entry.carbs.toInt()}c / ${entry.fat.toInt()}f"
            )
        }
    }

    private fun formatNumber(value: Int): String {
        return String.format(Locale.getDefault(), "%,d", value)
    }
}
