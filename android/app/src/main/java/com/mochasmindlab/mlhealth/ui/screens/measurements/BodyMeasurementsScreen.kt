package com.mochasmindlab.mlhealth.ui.screens.measurements

import android.app.DatePickerDialog
import android.widget.DatePicker
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Straighten
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.entities.BodyMeasurementEntry
import com.mochasmindlab.mlhealth.viewmodel.BodyMeasurementsViewModel
import java.text.SimpleDateFormat
import java.util.*

// ── Date format helpers ────────────────────────────────────────────────────────
private val DATE_FMT = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())

private fun Date.toDisplayString(): String = DATE_FMT.format(this)

// ── Screen ─────────────────────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BodyMeasurementsScreen(
    navController: NavController,
    viewModel: BodyMeasurementsViewModel = hiltViewModel()
) {
    val entries by viewModel.entries.collectAsState()
    val canSave by viewModel.canSave.collectAsState()

    // Form state
    val waist  by viewModel.waist.collectAsState()
    val hips   by viewModel.hips.collectAsState()
    val chest  by viewModel.chest.collectAsState()
    val biceps by viewModel.biceps.collectAsState()
    val thighs by viewModel.thighs.collectAsState()
    val height by viewModel.height.collectAsState()
    val selectedDate by viewModel.selectedDate.collectAsState()

    // Date picker
    val context = LocalContext.current
    val calendar = Calendar.getInstance().apply { time = selectedDate }
    val datePickerDialog = DatePickerDialog(
        context,
        { _: DatePicker, year: Int, month: Int, day: Int ->
            val cal = Calendar.getInstance()
            cal.set(year, month, day, 0, 0, 0)
            cal.set(Calendar.MILLISECOND, 0)
            viewModel.onDateChanged(cal.time)
        },
        calendar.get(Calendar.YEAR),
        calendar.get(Calendar.MONTH),
        calendar.get(Calendar.DAY_OF_MONTH)
    )

    // Delete confirmation
    var entryToDelete by remember { mutableStateOf<BodyMeasurementEntry?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Body Measurements", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            // ── Form card ──────────────────────────────────────────────────────
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = MaterialTheme.shapes.large
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Text(
                            "Log Measurements",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )

                        // Date picker row
                        OutlinedButton(
                            onClick = { datePickerDialog.show() },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("Date: ${selectedDate.toDisplayString()}")
                        }

                        Divider()

                        Text(
                            "Values in centimetres (cm)",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )

                        MeasurementTextField(
                            label = "Waist",
                            value = waist,
                            onValueChange = viewModel::onWaistChanged
                        )
                        MeasurementTextField(
                            label = "Hips",
                            value = hips,
                            onValueChange = viewModel::onHipsChanged
                        )
                        MeasurementTextField(
                            label = "Chest",
                            value = chest,
                            onValueChange = viewModel::onChestChanged
                        )
                        MeasurementTextField(
                            label = "Biceps",
                            value = biceps,
                            onValueChange = viewModel::onBicepsChanged
                        )
                        MeasurementTextField(
                            label = "Thighs",
                            value = thighs,
                            onValueChange = viewModel::onThighsChanged
                        )
                        MeasurementTextField(
                            label = "Height",
                            value = height,
                            onValueChange = viewModel::onHeightChanged
                        )

                        Button(
                            onClick = { viewModel.saveFromForm() },
                            enabled = canSave,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("Save")
                        }
                    }
                }
            }

            // ── Empty state ────────────────────────────────────────────────────
            if (entries.isEmpty()) {
                item {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 48.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            Icons.Default.Straighten,
                            contentDescription = null,
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            "No measurements yet",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Medium
                        )
                        Text(
                            "Fill in at least one field above and tap Save",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            } else {
                // ── History header ─────────────────────────────────────────────
                item {
                    Text(
                        "History",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }

                // ── History rows ───────────────────────────────────────────────
                items(entries, key = { it.id }) { entry ->
                    MeasurementHistoryRow(
                        entry = entry,
                        onDeleteClick = { entryToDelete = entry }
                    )
                }
            }
        }
    }

    // ── Delete confirmation dialog ─────────────────────────────────────────────
    entryToDelete?.let { entry ->
        AlertDialog(
            onDismissRequest = { entryToDelete = null },
            title = { Text("Delete entry?") },
            text  = { Text("Remove measurement logged on ${entry.date.toDisplayString()}?") },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.delete(entry)
                    entryToDelete = null
                }) { Text("Delete") }
            },
            dismissButton = {
                TextButton(onClick = { entryToDelete = null }) { Text("Cancel") }
            }
        )
    }
}

// ── Reusable text field ────────────────────────────────────────────────────────
@Composable
private fun MeasurementTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        suffix = { Text("cm") },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        singleLine = true,
        modifier = Modifier.fillMaxWidth()
    )
}

// ── History row ────────────────────────────────────────────────────────────────
@Composable
private fun MeasurementHistoryRow(
    entry: BodyMeasurementEntry,
    onDeleteClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.Top
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = entry.date.toDisplayString(),
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Medium
                )
                Spacer(Modifier.height(6.dp))
                val parts = buildList {
                    entry.height?.let { add("Height: ${"%.1f".format(it)} cm") }
                    entry.waist?.let  { add("Waist: ${"%.1f".format(it)} cm") }
                    entry.hips?.let   { add("Hips: ${"%.1f".format(it)} cm") }
                    entry.chest?.let  { add("Chest: ${"%.1f".format(it)} cm") }
                    entry.biceps?.let { add("Biceps: ${"%.1f".format(it)} cm") }
                    entry.thighs?.let { add("Thighs: ${"%.1f".format(it)} cm") }
                }
                parts.chunked(2).forEach { pair ->
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        pair.forEach { label ->
                            Text(
                                text = label,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.weight(1f)
                            )
                        }
                        // Pad to fill second column if odd number
                        if (pair.size < 2) Spacer(Modifier.weight(1f))
                    }
                }
            }
            IconButton(onClick = onDeleteClick) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete entry",
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

// TODO: Add navigation route "body_measurements" → BodyMeasurementsScreen in MLFitnessNavigation.kt
