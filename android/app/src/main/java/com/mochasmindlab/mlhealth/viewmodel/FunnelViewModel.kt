package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import com.mochasmindlab.mlhealth.services.FunnelAnalytics
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

/**
 * Hands the navigation host a Hilt-injected [FunnelAnalytics] so screen_view
 * events can be logged centrally from the current route, the same
 * thin-coordinator shape as [OnboardingViewModel]. Composables that are not
 * routes (the add-to-diary bottom sheet) use it too.
 */
@HiltViewModel
class FunnelViewModel @Inject constructor(
    private val funnel: FunnelAnalytics
) : ViewModel() {

    /** One screen_view per appearance; repeats inside two seconds are dropped. */
    fun logScreen(screen: FunnelAnalytics.Screen) = funnel.logScreen(screen)
}
