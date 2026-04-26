package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.services.HealthConnectManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * Possible states for the Health Connect integration screen.
 */
enum class HealthConnectState {
    /** Initial / in-flight data fetch. */
    Loading,

    /** Health Connect app is not installed on the device. */
    NotInstalled,

    /**
     * HC is installed but one or more required permissions have not been granted.
     * The screen should trigger the permission request contract.
     */
    NeedsPermissions,

    /** All permissions granted, data is (or was recently) loaded. */
    Connected,

    /** An unexpected error occurred; message is in [HealthConnectViewModel.errorMessage]. */
    Error
}

@HiltViewModel
class HealthConnectViewModel @Inject constructor(
    private val healthConnectManager: HealthConnectManager
) : ViewModel() {

    private val _state = MutableStateFlow<HealthConnectState>(HealthConnectState.Loading)
    val state: StateFlow<HealthConnectState> = _state.asStateFlow()

    private val _stepsToday = MutableStateFlow<Long?>(null)
    val stepsToday: StateFlow<Long?> = _stepsToday.asStateFlow()

    private val _latestWeightKg = MutableStateFlow<Double?>(null)
    val latestWeightKg: StateFlow<Double?> = _latestWeightKg.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        refresh()
    }

    /**
     * Re-checks availability and permissions, then fetches data if connected.
     * Safe to call multiple times (e.g. after returning from permission dialog).
     */
    fun refresh() {
        viewModelScope.launch {
            _state.value = HealthConnectState.Loading
            _errorMessage.value = null

            try {
                val availability = healthConnectManager.isAvailable()

                when (availability) {
                    HealthConnectManager.SdkAvailabilityStatus.NOT_INSTALLED,
                    HealthConnectManager.SdkAvailabilityStatus.PROVIDER_UPDATE_REQUIRED -> {
                        _state.value = HealthConnectState.NotInstalled
                        return@launch
                    }
                    HealthConnectManager.SdkAvailabilityStatus.AVAILABLE -> { /* continue */ }
                }

                val hasPermissions = healthConnectManager.hasAllPermissions()
                if (!hasPermissions) {
                    _state.value = HealthConnectState.NeedsPermissions
                    return@launch
                }

                // Fetch data concurrently — use individual launches to isolate failures
                val stepsJob = viewModelScope.launch {
                    _stepsToday.value = healthConnectManager.readStepsToday()
                }
                val weightJob = viewModelScope.launch {
                    _latestWeightKg.value = healthConnectManager.readLatestWeightKg()
                }
                stepsJob.join()
                weightJob.join()

                _state.value = HealthConnectState.Connected
            } catch (e: Exception) {
                _errorMessage.value = e.localizedMessage ?: "Unknown error"
                _state.value = HealthConnectState.Error
            }
        }
    }

    /**
     * Called by the Compose permission launcher callback with the set of permissions that
     * were actually granted. Transitions to [HealthConnectState.Connected] if all required
     * permissions are now present; otherwise stays in [HealthConnectState.NeedsPermissions].
     */
    fun onPermissionResult(granted: Set<String>) {
        val allGranted = granted.containsAll(healthConnectManager.requiredPermissions)
        if (allGranted) {
            // Kick off a full refresh to populate data
            refresh()
        } else {
            _state.value = HealthConnectState.NeedsPermissions
        }
    }

    /**
     * Convenience accessor so the screen can build the Play Store deep-link CTA.
     */
    val installPlayStoreLink: String
        get() = healthConnectManager.installPlayStoreLink

    /**
     * Expose the required permissions set so the Compose launcher can call
     * `launcher.launch(viewModel.requiredPermissions)`.
     */
    val requiredPermissions: Set<String>
        get() = healthConnectManager.requiredPermissions

    /**
     * Expose the permission contract from the manager for use with
     * [androidx.activity.compose.rememberLauncherForActivityResult].
     */
    fun permissionsContract() = healthConnectManager.permissionsContract()
}
