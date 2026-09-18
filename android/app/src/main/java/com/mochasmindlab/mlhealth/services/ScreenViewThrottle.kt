package com.mochasmindlab.mlhealth.services

/**
 * Drops repeats of the same screen name that arrive within [windowMillis] of
 * the last one that was admitted. Pure Kotlin so the rule is unit-testable
 * without touching the network. Mirrors iOS `ScreenViewThrottle`.
 */
class ScreenViewThrottle(
    private val windowMillis: Long = DEFAULT_WINDOW_MILLIS,
    private val clock: () -> Long = System::currentTimeMillis,
) {
    private var lastScreen: String? = null
    private var lastAdmittedAt: Long = 0L

    /** Returns true when [screen] should be logged, and remembers it if so. */
    @Synchronized
    fun admit(screen: String): Boolean {
        val now = clock()
        if (lastScreen == screen && now - lastAdmittedAt < windowMillis) return false
        lastScreen = screen
        lastAdmittedAt = now
        return true
    }

    companion object {
        const val DEFAULT_WINDOW_MILLIS = 2_000L
    }
}
