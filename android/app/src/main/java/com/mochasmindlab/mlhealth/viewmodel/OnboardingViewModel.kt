package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import com.mochasmindlab.mlhealth.services.FunnelAnalytics
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

/**
 * ViewModel for [com.mochasmindlab.mlhealth.ui.screens.OnboardingScreen].
 *
 * Exists only to give the onboarding Composable a Hilt-injected
 * [FunnelAnalytics], the same thin-coordinator shape as [PaywallViewModel],
 * which is how the paywall half of the funnel is already logged. Onboarding
 * takes its [com.mochasmindlab.mlhealth.utils.PreferencesManager] as a plain
 * parameter, so there was no other injection point on this screen.
 */
@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val funnel: FunnelAnalytics
) : ViewModel() {

    /**
     * Funnel event: setup finished, so this install is activated. Once per
     * install, see `FunnelAnalytics.logOnce`.
     */
    fun logOnboardingComplete() = funnel.logOnce(FunnelAnalytics.Event.ONBOARDING_COMPLETE)

    /**
     * screen_view for each onboarding step, so the drop-off between steps is
     * visible. [step] is the zero-based index the screen keeps in state.
     */
    fun logStep(step: Int) {
        val screen = when (step) {
            0 -> FunnelAnalytics.Screen.ONBOARDING_WELCOME
            1 -> FunnelAnalytics.Screen.ONBOARDING_BASIC_INFO
            2 -> FunnelAnalytics.Screen.ONBOARDING_BODY_METRICS
            3 -> FunnelAnalytics.Screen.ONBOARDING_ACTIVITY_LEVEL
            4 -> FunnelAnalytics.Screen.ONBOARDING_GOALS
            else -> return
        }
        funnel.logScreen(screen)
    }
}
