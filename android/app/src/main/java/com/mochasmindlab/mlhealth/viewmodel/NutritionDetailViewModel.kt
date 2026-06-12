package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.models.*
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class NutritionDetailViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    private val prefs: PreferencesManager
) : ViewModel() {

    // ---- State ----

    private val _period = MutableStateFlow(Period.DAY)
    val period: StateFlow<Period> = _period.asStateFlow()

    private val _dailyTotals = MutableStateFlow(NutritionDailyTotals())
    val dailyTotals: StateFlow<NutritionDailyTotals> = _dailyTotals.asStateFlow()

    private val _weekDays = MutableStateFlow<List<DailyTotals>>(emptyList())
    val weekDays: StateFlow<List<DailyTotals>> = _weekDays.asStateFlow()

    private val _monthDays = MutableStateFlow<List<DailyTotals>>(emptyList())
    val monthDays: StateFlow<List<DailyTotals>> = _monthDays.asStateFlow()

    private val _goals = MutableStateFlow(MacroGoals())
    val goals: StateFlow<MacroGoals> = _goals.asStateFlow()

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    // ---- Formatters ----

    private val weekDayFmt = SimpleDateFormat("EEE", Locale.getDefault())   // Mon, Tue …
    private val monthDayFmt = SimpleDateFormat("d", Locale.getDefault())    // 1, 2, … 31

    // ---- Init ----

    init {
        // Observe calorie goal from DataStore and rebuild MacroGoals whenever it changes.
        viewModelScope.launch {
            prefs.dailyCalorieGoal.collect { calGoal ->
                _goals.value = _goals.value.copy(calories = calGoal)
            }
        }
        // Also pick up per-macro goals from the UserProfile stored in DataStore.
        viewModelScope.launch {
            prefs.userProfile.collect { profile ->
                if (profile != null) {
                    _goals.value = _goals.value.copy(
                        calories = profile.dailyCalorieGoal,
                        // UserProfile only stores calorie goal; macro defaults stay unless
                        // a future goals screen persists them.
                    )
                }
            }
        }
        loadAll()
    }

    // ---- Public API ----

    fun selectPeriod(newPeriod: Period) {
        _period.value = newPeriod
    }

    fun refresh() {
        loadAll()
    }

    // ---- Data Loading ----

    private fun loadAll() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                withContext(Dispatchers.IO) {
                    val today = dayStart(Date())
                    loadTodayTotals(today)
                    loadRangeTotals(7, _weekDays, weekDayFmt)
                    loadRangeTotals(30, _monthDays, monthDayFmt)
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

    private suspend fun loadTodayTotals(today: Date) {
        val entries = database.foodDao().getEntriesForDate(today)
        val supplements = database.supplementDao().getEntriesForDay(today)

        // Aggregate totals, respecting servingCount for nullable fields
        var cal = 0.0; var pro = 0.0; var carb = 0.0; var fat = 0.0
        var fib = 0.0; var sug = 0.0; var sod = 0.0
        var chol = 0.0; var satFat = 0.0
        val micros = mutableMapOf<String, Double>()
        val mealMap = mutableMapOf<String, Double>()

        for (e in entries) {
            val sc = e.servingCount
            cal  += e.calories * sc
            pro  += e.protein  * sc
            carb += e.carbs    * sc
            fat  += e.fat      * sc
            fib  += (e.fiber  ?: 0.0) * sc
            sug  += (e.sugar  ?: 0.0) * sc
            sod  += (e.sodium ?: 0.0) * sc
            chol += (e.cholesterol ?: 0.0) * sc
            satFat += (e.saturatedFat ?: 0.0) * sc
            // Vitamins/minerals carried from the USDA bundled DB.
            for ((k, v) in e.additionalNutrients) {
                micros[k] = (micros[k] ?: 0.0) + v * sc
            }
            val key = e.mealType.replaceFirstChar { it.uppercaseChar() }
            mealMap[key] = (mealMap[key] ?: 0.0) + e.calories * sc
        }

        // Supplements contribute their vitamins/minerals too (mirrors iOS).
        for (s in supplements) {
            for ((k, v) in s.nutrients) {
                micros[k] = (micros[k] ?: 0.0) + v
            }
        }

        val mealOrder = listOf("Breakfast", "Lunch", "Dinner", "Snack")
        val mealBreakdown = mealOrder
            .filter { mealMap.containsKey(it) }
            .map { MealTotals(it, mealMap[it] ?: 0.0) }

        _dailyTotals.value = NutritionDailyTotals(
            calories = cal,
            protein = pro,
            carbs = carb,
            fat = fat,
            fiber = fib,
            sugar = sug,
            sodium = sod,
            cholesterol = chol,
            saturatedFat = satFat,
            micronutrients = micros.filterValues { it > 0.0 },
            mealBreakdown = mealBreakdown
        )
    }

    private suspend fun loadRangeTotals(
        dayCount: Int,
        target: MutableStateFlow<List<DailyTotals>>,
        labelFmt: SimpleDateFormat
    ) {
        val result = mutableListOf<DailyTotals>()
        val cal = Calendar.getInstance()

        // Build oldest → newest
        for (offset in (dayCount - 1) downTo 0) {
            val iter = Calendar.getInstance()
            iter.add(Calendar.DAY_OF_MONTH, -offset)
            val dayDate = dayStart(iter.time)

            val entries = database.foodDao().getEntriesForDate(dayDate)
            var c = 0.0; var p = 0.0; var cb = 0.0; var f = 0.0
            var fi = 0.0; var s = 0.0; var so = 0.0
            for (e in entries) {
                val sc = e.servingCount
                c  += e.calories * sc
                p  += e.protein  * sc
                cb += e.carbs    * sc
                f  += e.fat      * sc
                fi += (e.fiber  ?: 0.0) * sc
                s  += (e.sugar  ?: 0.0) * sc
                so += (e.sodium ?: 0.0) * sc
            }
            result.add(DailyTotals(dayDate, c, p, cb, f, fi, s, so))
        }

        target.value = result
    }

    // ---- Helpers ----

    /** Returns a Date with time zeroed to midnight for the given date. */
    private fun dayStart(date: Date): Date {
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }

    /** Bar-chart labels for a list of DailyTotals entries.
     *  Week → short day names; Month → day-of-month numbers. */
    fun labelsFor(days: List<DailyTotals>, period: Period): List<String> {
        val fmt = if (period == Period.WEEK) weekDayFmt else monthDayFmt
        return days.map { fmt.format(it.date) }
    }
}
