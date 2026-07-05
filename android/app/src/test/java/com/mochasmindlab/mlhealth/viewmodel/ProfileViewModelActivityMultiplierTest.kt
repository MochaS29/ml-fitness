package com.mochasmindlab.mlhealth.viewmodel

import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.models.ActivityLevel
import org.junit.Test

/**
 * Guards the TDEE activity-multiplier mapping used by [ProfileViewModel.recalculateCalorieGoals].
 * Values must stay in parity with PreferencesManager.calculateTDEE and the iOS 5-tier model.
 */
class ProfileViewModelActivityMultiplierTest {

    @Test
    fun `each activity level maps to the iOS-parity Mifflin factor`() {
        assertThat(ProfileViewModel.activityMultiplier(ActivityLevel.SEDENTARY)).isEqualTo(1.2)
        assertThat(ProfileViewModel.activityMultiplier(ActivityLevel.LIGHT)).isEqualTo(1.375)
        assertThat(ProfileViewModel.activityMultiplier(ActivityLevel.MODERATE)).isEqualTo(1.55)
        assertThat(ProfileViewModel.activityMultiplier(ActivityLevel.ACTIVE)).isEqualTo(1.725)
        assertThat(ProfileViewModel.activityMultiplier(ActivityLevel.VERY_ACTIVE)).isEqualTo(1.9)
    }

    @Test
    fun `stored profile labels resolve to the correct multiplier`() {
        // Regression: "Active" previously fell through to the moderate default (1.55).
        assertThat(multiplierForLabel("Active")).isEqualTo(1.725)
        assertThat(multiplierForLabel("Sedentary")).isEqualTo(1.2)
        assertThat(multiplierForLabel("Lightly Active")).isEqualTo(1.375)
        assertThat(multiplierForLabel("Moderately Active")).isEqualTo(1.55)
        assertThat(multiplierForLabel("Very Active")).isEqualTo(1.725)
        assertThat(multiplierForLabel("Extra Active")).isEqualTo(1.9)
    }

    private fun multiplierForLabel(label: String): Double =
        ProfileViewModel.activityMultiplier(ProfileViewModel.activityLevelStringToEnum(label))
}
