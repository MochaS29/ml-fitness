package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.data.database.FoodDao
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import java.util.Calendar
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Computes and reactively exposes the current food-logging streak.
 *
 * Algorithm mirrors iOS LoggingStreakManager exactly:
 *   1. Collect all distinct logged days from the food_entries table.
 *   2. If today has an entry → start counting from today backward.
 *   3. Else if yesterday has an entry → start counting from yesterday backward.
 *   4. Else → streak is 0.
 *   5. Walk backward one day at a time, incrementing while a day exists.
 *
 * Room's Flow query causes this to recalculate automatically whenever
 * food_entries changes (insert/update/delete), matching iOS Core Data
 * NSManagedObjectContextObjectsDidChange behavior.
 */
@Singleton
class LoggingStreakManager @Inject constructor(
    private val foodDao: FoodDao
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    private val _currentStreak = MutableStateFlow(0)
    val currentStreak: StateFlow<Int> = _currentStreak.asStateFlow()

    init {
        // Observe the Flow<List<Date>> Room emits on every food_entries change.
        foodDao.getAllLoggedDatesFlow()
            .catch { /* ignore DB errors, streak stays at last value */ }
            .onEach { dates -> _currentStreak.value = computeStreak(dates) }
            .launchIn(scope)
    }

    /**
     * Compute the streak from a raw list of Date timestamps.
     * Mirrors the iOS algorithm: normalise to start-of-day, then
     * walk backwards until a gap is found.
     */
    private fun computeStreak(dates: List<Date>): Int {
        val calendar = Calendar.getInstance()

        // Normalise every timestamp to start-of-day
        val loggedDays: Set<Long> = dates.mapTo(mutableSetOf()) { date ->
            calendar.time = date
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            calendar.timeInMillis
        }

        // today (start of day)
        calendar.time = Date()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val today = calendar.timeInMillis

        // yesterday (start of day)
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val yesterday = calendar.timeInMillis

        // Determine start day — mirror iOS exactly
        val startDay: Long = when {
            loggedDays.contains(today) -> today
            loggedDays.contains(yesterday) -> yesterday
            else -> return 0
        }

        // Walk backwards counting consecutive days
        var streak = 1
        var checkDay = startDay - DAY_MILLIS
        while (loggedDays.contains(checkDay)) {
            streak++
            checkDay -= DAY_MILLIS
        }

        return streak
    }

    companion object {
        private const val DAY_MILLIS = 24L * 60 * 60 * 1000
    }
}
