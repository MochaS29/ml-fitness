package com.mochasmindlab.mlhealth.ui.screens.fasting

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mochasmindlab.mlhealth.data.entities.FastingSession
import com.mochasmindlab.mlhealth.data.models.FastingPlan
import com.mochasmindlab.mlhealth.viewmodel.FastingViewModel
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.min

// TODO: Route "fasting" in MLFitnessNavigation should point to FastingScreen (currently → ComingSoon)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FastingScreen(
    onBack: () -> Unit,
    viewModel: FastingViewModel = hiltViewModel()
) {
    val activeSession by viewModel.activeSession.collectAsState()
    val recent by viewModel.recent.collectAsState()
    val selectedPlan by viewModel.selectedPlan.collectAsState()
    val elapsedMillis by viewModel.elapsedMillis.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Intermittent Fasting") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(vertical = 16.dp)
        ) {
            item {
                if (activeSession != null) {
                    ActiveFastCard(
                        session = activeSession!!,
                        elapsedMillis = elapsedMillis,
                        onEndFast = { viewModel.endFast() },
                        onCancelFast = { viewModel.cancelFast() }
                    )
                } else {
                    IdleCard(
                        selectedPlan = selectedPlan,
                        onSelectPlan = { viewModel.selectPlan(it) },
                        onStartFast = { viewModel.startFast() }
                    )
                }
            }

            if (recent.isNotEmpty()) {
                item {
                    Text(
                        text = "History",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                items(recent.take(10)) { session ->
                    FastingHistoryItem(session = session)
                    Divider()
                }
            }
        }
    }
}

// ── Idle card: plan picker + Start ──────────────────────────────────────────

@Composable
private fun IdleCard(
    selectedPlan: FastingPlan,
    onSelectPlan: (FastingPlan) -> Unit,
    onStartFast: () -> Unit
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Choose your fasting plan",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )

            // Plan chips
            val plans = FastingPlan.entries
            val chunked = plans.chunked(3)
            chunked.forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    row.forEach { plan ->
                        FilterChip(
                            selected = plan == selectedPlan,
                            onClick = { onSelectPlan(plan) },
                            label = { Text(plan.displayName, fontSize = 13.sp) }
                        )
                    }
                }
            }

            // Selected plan details
            Surface(
                color = MaterialTheme.colorScheme.surfaceVariant,
                shape = MaterialTheme.shapes.small,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    Text(
                        text = selectedPlan.displayName,
                        style = MaterialTheme.typography.labelLarge
                    )
                    Text(
                        text = "${selectedPlan.fastHours.toInt()}h fasting  •  ${selectedPlan.eatHours.toInt()}h eating",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Button(
                onClick = onStartFast,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Start Fast")
            }
        }
    }
}

// ── Active fast card: circular progress + actions ───────────────────────────

@Composable
private fun ActiveFastCard(
    session: FastingSession,
    elapsedMillis: Long,
    onEndFast: () -> Unit,
    onCancelFast: () -> Unit
) {
    val targetMillis = (session.targetHours * 3600 * 1000).toLong()
    val progress = if (targetMillis > 0) {
        min(elapsedMillis.toFloat() / targetMillis.toFloat(), 1f)
    } else 0f

    val elapsedSec = elapsedMillis / 1000
    val remainMillis = (targetMillis - elapsedMillis).coerceAtLeast(0L)
    val remainSec = remainMillis / 1000

    var showEndDialog by remember { mutableStateOf(false) }
    var showCancelDialog by remember { mutableStateOf(false) }

    if (showEndDialog) {
        AlertDialog(
            onDismissRequest = { showEndDialog = false },
            title = { Text("End Fast?") },
            text = { Text("You've been fasting for ${formatHms(elapsedSec)}. End now?") },
            confirmButton = {
                TextButton(onClick = { showEndDialog = false; onEndFast() }) {
                    Text("End Fast")
                }
            },
            dismissButton = {
                TextButton(onClick = { showEndDialog = false }) {
                    Text("Keep Going")
                }
            }
        )
    }

    if (showCancelDialog) {
        AlertDialog(
            onDismissRequest = { showCancelDialog = false },
            title = { Text("Cancel Fast?") },
            text = { Text("This will discard the current session.") },
            confirmButton = {
                TextButton(onClick = { showCancelDialog = false; onCancelFast() }) {
                    Text("Cancel Fast", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showCancelDialog = false }) {
                    Text("Keep Going")
                }
            }
        )
    }

    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Fasting: ${session.planName}",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )

            // Circular progress
            Box(contentAlignment = Alignment.Center) {
                CircularProgressIndicator(
                    progress = progress,
                    modifier = Modifier.size(180.dp),
                    strokeWidth = 12.dp,
                    trackColor = MaterialTheme.colorScheme.surfaceVariant
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = formatHms(elapsedSec),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                    )
                    Text(
                        text = "elapsed",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    if (remainMillis > 0) {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "${formatHm(remainSec)} left",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    } else {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Goal reached!",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            // Start time
            val fmt = remember { SimpleDateFormat("h:mm a", Locale.getDefault()) }
            val endTime = Date(session.startTime.time + targetMillis)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                LabeledValue("Started", fmt.format(session.startTime))
                LabeledValue("Eating opens", fmt.format(endTime))
            }

            // Action buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = { showEndDialog = true },
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("End Fast")
                }
                OutlinedButton(
                    onClick = { showCancelDialog = true },
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(Icons.Default.Close, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Cancel")
                }
            }
        }
    }
}

// ── History row ──────────────────────────────────────────────────────────────

@Composable
private fun FastingHistoryItem(session: FastingSession) {
    val dateFmt = remember { SimpleDateFormat("MMM d, h:mm a", Locale.getDefault()) }
    val endTime = session.endTime
    val durationMillis = when {
        endTime != null -> endTime.time - session.startTime.time
        else -> 0L
    }
    val targetMillis = (session.targetHours * 3600 * 1000).toLong()
    val completed = endTime != null && durationMillis >= targetMillis

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = session.planName,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium
                )
                Spacer(modifier = Modifier.width(6.dp))
                if (completed) {
                    Icon(
                        Icons.Default.Check,
                        contentDescription = "Completed",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
            Text(
                text = dateFmt.format(session.startTime),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Text(
            text = if (endTime != null) formatHm(durationMillis / 1000) else "—",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.End
        )
    }
}

// ── Helper composable ────────────────────────────────────────────────────────

@Composable
private fun LabeledValue(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
    }
}

// ── Time formatting helpers ──────────────────────────────────────────────────

private fun formatHms(totalSec: Long): String {
    val h = totalSec / 3600
    val m = (totalSec % 3600) / 60
    val s = totalSec % 60
    return "%02d:%02d:%02d".format(h, m, s)
}

private fun formatHm(totalSec: Long): String {
    val h = totalSec / 3600
    val m = (totalSec % 3600) / 60
    return "${h}h ${m}m"
}
