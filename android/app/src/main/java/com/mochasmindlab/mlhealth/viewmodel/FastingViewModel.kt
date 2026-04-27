package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.FastingDao
import com.mochasmindlab.mlhealth.data.entities.FastingSession
import com.mochasmindlab.mlhealth.data.models.FastingPlan
import com.mochasmindlab.mlhealth.services.FastingScheduler
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.Date
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class FastingViewModel @Inject constructor(
    private val dao: FastingDao,
    private val scheduler: FastingScheduler
) : ViewModel() {

    val activeSession: StateFlow<FastingSession?> = dao.activeFlow()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    val recent: StateFlow<List<FastingSession>> = dao.getAll()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    private val _selectedPlan = MutableStateFlow(FastingPlan.SIXTEEN_EIGHT)
    val selectedPlan: StateFlow<FastingPlan> = _selectedPlan.asStateFlow()

    // 1-second tick that only runs while there's an active session
    val elapsedMillis: StateFlow<Long> = activeSession
        .flatMapLatest { session ->
            if (session == null) {
                flowOf(0L)
            } else {
                flow {
                    while (true) {
                        emit(System.currentTimeMillis() - session.startTime.time)
                        delay(1_000)
                    }
                }
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 0L)

    fun selectPlan(plan: FastingPlan) {
        _selectedPlan.value = plan
    }

    fun startFast() {
        val plan = _selectedPlan.value
        val now = Date()
        val session = FastingSession(
            id = UUID.randomUUID(),
            startTime = now,
            endTime = null,
            targetHours = plan.fastHours,
            planName = plan.displayName
        )
        viewModelScope.launch {
            dao.insert(session)
            scheduler.scheduleEndNotification(
                sessionId = session.id,
                fastHours = plan.fastHours,
                startMillis = now.time,
                planName = plan.displayName
            )
        }
    }

    fun endFast() {
        viewModelScope.launch {
            val session = dao.getActive() ?: return@launch
            val ended = session.copy(endTime = Date())
            dao.update(ended)
            scheduler.cancelEndNotification(session.id)
        }
    }

    fun cancelFast() {
        viewModelScope.launch {
            val session = dao.getActive() ?: return@launch
            dao.delete(session)
            scheduler.cancelEndNotification(session.id)
        }
    }
}
