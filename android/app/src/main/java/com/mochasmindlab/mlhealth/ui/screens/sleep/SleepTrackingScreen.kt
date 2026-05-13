package com.mochasmindlab.mlhealth.ui.screens.sleep

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.entities.SleepEntry
import com.mochasmindlab.mlhealth.viewmodel.SleepTrackingViewModel
import java.text.SimpleDateFormat
import java.util.*

// TODO: Register this screen in MLFitnessNavigation.kt — add composable("sleep") { SleepTrackingScreen(navController) }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SleepTrackingScreen(
    navController: NavController,
    viewModel: SleepTrackingViewModel = hiltViewModel()
) {
    val entries by viewModel.entries.collectAsState()
    val last7Days by viewModel.last7Days.collectAsState()
    val avgHours by viewModel.avgHoursLast7.collectAsState()
    val isSyncing by viewModel.isSyncing.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()

    var showAddDialog by remember { mutableStateOf(false) }

    // Error snackbar
    val snackbarHostState = remember { SnackbarHostState() }
    LaunchedEffect(errorMessage) {
        errorMessage?.let {
            snackbarHostState.showSnackbar(it)
            viewModel.clearError()
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = { Text("Sleep") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    TextButton(
                        onClick = { viewModel.syncFromHealthConnect() },
                        enabled = !isSyncing
                    ) {
                        if (isSyncing) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                strokeWidth = 2.dp
                            )
                            Spacer(Modifier.width(4.dp))
                        }
                        Text("Sync HC")
                    }
                    IconButton(onClick = { showAddDialog = true }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Sleep Entry")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onSurface
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(vertical = 16.dp)
        ) {
            // ── 7-day average card ────────────────────────────────────────────
            item {
                SleepAverageCard(avgHours = avgHours, entryCount = last7Days.size)
            }

            // ── Empty state ───────────────────────────────────────────────────
            if (entries.isEmpty()) {
                item {
                    EmptySleepState()
                }
            } else {
                item {
                    Text(
                        text = "History",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                items(entries, key = { it.id.toString() }) { entry ->
                    SleepEntryCard(
                        entry = entry,
                        onDelete = { viewModel.delete(entry) }
                    )
                }
            }
        }
    }

    // ── Add-entry dialog ──────────────────────────────────────────────────────
    if (showAddDialog) {
        AddSleepDialog(
            onDismiss = { showAddDialog = false },
            onConfirm = { bedTime, wakeTime, quality, notes ->
                viewModel.addEntry(bedTime, wakeTime, quality, notes)
                showAddDialog = false
            }
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-composables
// ─────────────────────────────────────────────────────────────────────────────

@Composable
private fun SleepAverageCard(avgHours: Double, entryCount: Int) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.Bedtime,
                contentDescription = null,
                modifier = Modifier.size(36.dp),
                tint = MaterialTheme.colorScheme.onPrimaryContainer
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = if (avgHours > 0) "%.1f hrs".format(avgHours) else "—",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
            Text(
                text = "7-day average ($entryCount entries)",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
            )
        }
    }
}

@Composable
private fun EmptySleepState() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(
            imageVector = Icons.Default.Bedtime,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.outlineVariant
        )
        Text(
            text = "No sleep entries yet.\nTap '+' or sync from Health Connect.",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.outline,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun SleepEntryCard(
    entry: SleepEntry,
    onDelete: () -> Unit
) {
    val dateFmt = remember { SimpleDateFormat("EEE, MMM d", Locale.getDefault()) }
    val timeFmt = remember { SimpleDateFormat("h:mm a", Locale.getDefault()) }

    val hours = entry.durationMinutes / 60
    val minutes = entry.durationMinutes % 60
    val durationText = when {
        hours > 0 && minutes > 0 -> "${hours}h ${minutes}m"
        hours > 0 -> "${hours}h"
        else -> "${minutes}m"
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Date + times
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = dateFmt.format(entry.bedTime),
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text = "${timeFmt.format(entry.bedTime)} → ${timeFmt.format(entry.wakeTime)}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.outline
                )
                if (!entry.notes.isNullOrBlank()) {
                    Spacer(Modifier.height(2.dp))
                    Text(
                        text = entry.notes,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.outline,
                        maxLines = 1
                    )
                }
            }

            // Duration + quality + source
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = durationText,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                if (entry.quality != null) {
                    Text(
                        text = "★".repeat(entry.quality) + "☆".repeat(5 - entry.quality),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.tertiary
                    )
                }
                // Source badge
                val badgeLabel = if (entry.source == "health_connect") "HC" else "✏"
                Surface(
                    color = if (entry.source == "health_connect")
                        MaterialTheme.colorScheme.secondaryContainer
                    else
                        MaterialTheme.colorScheme.surfaceVariant,
                    shape = RoundedCornerShape(4.dp)
                ) {
                    Text(
                        text = badgeLabel,
                        style = MaterialTheme.typography.labelSmall,
                        modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Delete button
            Spacer(Modifier.width(4.dp))
            IconButton(onClick = onDelete, modifier = Modifier.size(32.dp)) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    modifier = Modifier.size(18.dp),
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Sleep Dialog
// ─────────────────────────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddSleepDialog(
    onDismiss: () -> Unit,
    onConfirm: (bedTime: Date, wakeTime: Date, quality: Int?, notes: String?) -> Unit
) {
    // State for bed-time date (defaults to yesterday)
    val cal = remember {
        Calendar.getInstance().apply { add(Calendar.DAY_OF_MONTH, -1) }
    }

    var bedDateText by remember {
        mutableStateOf(
            SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(cal.time)
        )
    }
    var bedTimeText by remember { mutableStateOf("22:00") }
    var wakeTimeText by remember { mutableStateOf("06:30") }
    var qualityText by remember { mutableStateOf("") }
    var notesText by remember { mutableStateOf("") }
    var validationError by remember { mutableStateOf<String?>(null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Sleep Entry") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                // Bed date
                OutlinedTextField(
                    value = bedDateText,
                    onValueChange = { bedDateText = it },
                    label = { Text("Bed Date (yyyy-MM-dd)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    isError = validationError != null
                )
                // Bed time
                OutlinedTextField(
                    value = bedTimeText,
                    onValueChange = { bedTimeText = it },
                    label = { Text("Bed Time (HH:mm)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
                // Wake time (assumed next day if < bed time)
                OutlinedTextField(
                    value = wakeTimeText,
                    onValueChange = { wakeTimeText = it },
                    label = { Text("Wake Time (HH:mm)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
                // Quality stars 0-5
                OutlinedTextField(
                    value = qualityText,
                    onValueChange = { qualityText = it.filter { c -> c.isDigit() }.take(1) },
                    label = { Text("Quality (0–5, optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
                // Notes
                OutlinedTextField(
                    value = notesText,
                    onValueChange = { notesText = it },
                    label = { Text("Notes (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 2
                )
                validationError?.let {
                    Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                val parsed = parseSleepTimes(bedDateText, bedTimeText, wakeTimeText)
                if (parsed == null) {
                    validationError = "Invalid date/time. Use yyyy-MM-dd and HH:mm."
                    return@TextButton
                }
                val (bedTime, wakeTime) = parsed
                val quality = qualityText.toIntOrNull()?.coerceIn(0, 5)
                onConfirm(bedTime, wakeTime, quality, notesText.ifBlank { null })
            }) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

/**
 * Parses bed-date + bed-time + wake-time strings into a pair of [Date]s.
 * Wake time is bumped to the next day when its hour:minute is less than bed time (overnight sleep).
 * Returns null on any parse failure.
 */
private fun parseSleepTimes(bedDateStr: String, bedTimeStr: String, wakeTimeStr: String): Pair<Date, Date>? {
    return try {
        val dateFmt = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
        val bedDate = dateFmt.parse("$bedDateStr $bedTimeStr") ?: return null

        val bedCal = Calendar.getInstance().apply { time = bedDate }
        val wakeCal = Calendar.getInstance().apply {
            time = dateFmt.parse("$bedDateStr $wakeTimeStr") ?: return null
        }
        // If wake hour:min is before (or equal to) bed hour:min → overnight → add 1 day
        if (!wakeCal.after(bedCal)) {
            wakeCal.add(Calendar.DAY_OF_MONTH, 1)
        }
        Pair(bedCal.time, wakeCal.time)
    } catch (e: Exception) {
        null
    }
}
