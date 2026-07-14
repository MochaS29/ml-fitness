package com.mochasmindlab.mlhealth.ui.screens.settings

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.importer.MfpImporter
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.viewmodel.ImportHistoryViewModel
import java.text.DateFormat
import java.util.Date

private val ImportGreen = Color(0xFF7FB069)   // matches iOS wellnessGreen
private val ImportTeal = Color(0xFF00796B)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ImportHistoryScreen(
    navController: NavController,
    viewModel: ImportHistoryViewModel = hiltViewModel()
) {
    val stage by viewModel.stage.collectAsState()
    val context = LocalContext.current
    var showGuide by remember { mutableStateOf(false) }
    var weightUnit by remember { mutableStateOf(MfpImporter.WeightUnit.POUNDS) }

    val picker = rememberLauncherForActivityResult(
        ActivityResultContracts.OpenDocument()
    ) { uri ->
        if (uri != null) {
            val text = context.contentResolver.openInputStream(uri)?.bufferedReader()?.use { it.readText() }
            if (text != null) viewModel.preview(text)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Import History") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            when (val s = stage) {
                is ImportHistoryViewModel.Stage.Idle -> IdleSection(
                    onChooseFile = { picker.launch(arrayOf("text/csv", "text/comma-separated-values", "text/plain", "*/*")) },
                    onShowGuide = { showGuide = true }
                )
                is ImportHistoryViewModel.Stage.Preview -> PreviewSection(
                    summary = s.summary,
                    weightUnit = weightUnit,
                    onUnitChange = { weightUnit = it },
                    onImport = { viewModel.runImport(s.summary, weightUnit) },
                    onReset = { viewModel.reset() }
                )
                is ImportHistoryViewModel.Stage.Importing -> ImportingSection(s.progress)
                is ImportHistoryViewModel.Stage.Done -> DoneSection(s.inserted, s.noun) { viewModel.reset() }
                is ImportHistoryViewModel.Stage.Failed -> FailedSection(s.message) { viewModel.reset() }
            }
        }
    }

    if (showGuide) {
        MfpExportGuideDialog(onDismiss = { showGuide = false })
    }
}

@Composable
private fun IdleSection(onChooseFile: () -> Unit, onShowGuide: () -> Unit) {
    Card(shape = RoundedCornerShape(16.dp)) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Icon(Icons.Default.Download, contentDescription = null, tint = ImportGreen, modifier = Modifier.size(40.dp))
            Column {
                Text("Import your history", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                Text("Food, exercise & weight history", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }

    Text(
        "Coming from another fitness app? Bring your history with you. Import your food diary, workouts, and weight so you don't start from scratch.",
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    Button(
        onClick = onChooseFile,
        modifier = Modifier.fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(containerColor = ImportGreen)
    ) {
        Icon(Icons.Default.UploadFile, contentDescription = null)
        Spacer(Modifier.width(8.dp))
        Text("Choose a CSV file")
    }

    Text(
        "Works with exported food, exercise, and weight files. Import one at a time.",
        style = MaterialTheme.typography.bodySmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    TextButton(onClick = onShowGuide) {
        Icon(Icons.Default.HelpOutline, contentDescription = null, tint = ImportTeal)
        Spacer(Modifier.width(6.dp))
        Text("How do I export my data?", color = ImportTeal)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PreviewSection(
    summary: MfpImporter.Summary,
    weightUnit: MfpImporter.WeightUnit,
    onUnitChange: (MfpImporter.WeightUnit) -> Unit,
    onImport: () -> Unit,
    onReset: () -> Unit
) {
    Text("Ready to import", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)

    Card(shape = RoundedCornerShape(16.dp)) {
        Column(Modifier.padding(16.dp)) {
            StatRow("${kindLabel(summary.kind)} found", "${summary.importableRows}")
            Divider(Modifier.padding(vertical = 6.dp))
            StatRow("Date range", dateRangeText(summary))
            if (summary.skippedRows > 0) {
                Divider(Modifier.padding(vertical = 6.dp))
                StatRow("Rows skipped", "${summary.skippedRows}")
            }
        }
    }

    if (summary.kind == MfpImporter.Kind.NUTRITION && summary.mealCounts.isNotEmpty()) {
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
            MealType.values().forEach { meal ->
                val n = summary.mealCounts[meal] ?: 0
                if (n > 0) {
                    Card(shape = RoundedCornerShape(12.dp), modifier = Modifier.weight(1f)) {
                        Column(
                            Modifier.padding(vertical = 10.dp).fillMaxWidth(),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text("$n", style = MaterialTheme.typography.titleMedium)
                            Text(meal.displayName, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }
        }
    }

    if (summary.kind == MfpImporter.Kind.WEIGHT) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text("These weights are in", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                FilterChip(
                    selected = weightUnit == MfpImporter.WeightUnit.POUNDS,
                    onClick = { onUnitChange(MfpImporter.WeightUnit.POUNDS) },
                    label = { Text("Pounds (lb)") }
                )
                FilterChip(
                    selected = weightUnit == MfpImporter.WeightUnit.KILOGRAMS,
                    onClick = { onUnitChange(MfpImporter.WeightUnit.KILOGRAMS) },
                    label = { Text("Kilograms (kg)") }
                )
            }
        }
    }

    if (summary.sampleNames.isNotEmpty()) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text("For example", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            summary.sampleNames.forEach { name ->
                Text("• $name", style = MaterialTheme.typography.bodyMedium, maxLines = 1)
            }
        }
    }

    Text(
        "Anything already in your diary for these days won't be duplicated.",
        style = MaterialTheme.typography.bodySmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    Button(
        onClick = onImport,
        enabled = summary.importableRows > 0,
        modifier = Modifier.fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(containerColor = ImportGreen)
    ) {
        Text("Import ${summary.importableRows} ${summary.noun}")
    }
    TextButton(onClick = onReset, modifier = Modifier.fillMaxWidth()) {
        Text("Choose a different file", color = ImportTeal)
    }
}

@Composable
private fun ImportingSection(progress: Float) {
    Column(
        Modifier.fillMaxWidth().padding(top = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        LinearProgressIndicator(progress = progress, color = ImportGreen, modifier = Modifier.fillMaxWidth())
        Text("Importing your history…", color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun DoneSection(inserted: Int, noun: String, onReset: () -> Unit) {
    Column(
        Modifier.fillMaxWidth().padding(top = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(Icons.Default.CheckCircle, contentDescription = null, tint = ImportGreen, modifier = Modifier.size(56.dp))
        Text(
            if (inserted > 0) "Imported $inserted $noun" else "Nothing new to import",
            style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold
        )
        Text(
            if (inserted > 0) "Your history is now in the app. Open the Diary tab to see it."
            else "These were already in your diary, so nothing was duplicated.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        TextButton(onClick = onReset) { Text("Import another file", color = ImportTeal) }
    }
}

@Composable
private fun FailedSection(message: String, onReset: () -> Unit) {
    Column(
        Modifier.fillMaxWidth().padding(top = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(Icons.Default.Warning, contentDescription = null, tint = Color(0xFFFF9800), modifier = Modifier.size(48.dp))
        Text("Couldn't import that file", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Text(message, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        TextButton(onClick = onReset) { Text("Try again", color = ImportTeal) }
    }
}

@Composable
private fun StatRow(label: String, value: String) {
    Row(Modifier.fillMaxWidth().padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.weight(1f))
        Text(value, fontWeight = FontWeight.SemiBold)
    }
}

private fun kindLabel(kind: MfpImporter.Kind): String = when (kind) {
    MfpImporter.Kind.NUTRITION -> "Entries"
    MfpImporter.Kind.EXERCISE -> "Workouts"
    MfpImporter.Kind.WEIGHT -> "Weigh-ins"
}

private fun dateRangeText(summary: MfpImporter.Summary): String {
    val start = summary.startDate ?: return "—"
    val end = summary.endDate ?: return "—"
    val df = DateFormat.getDateInstance(DateFormat.MEDIUM)
    return if (sameDay(start, end)) df.format(start) else "${df.format(start)} – ${df.format(end)}"
}

private fun sameDay(a: Date, b: Date): Boolean {
    val fmt = java.text.SimpleDateFormat("yyyyMMdd", java.util.Locale.US)
    return fmt.format(a) == fmt.format(b)
}

/** Step-by-step guide for getting a MyFitnessPal export out of MFP. */
@Composable
private fun MfpExportGuideDialog(onDismiss: () -> Unit) {
    Dialog(onDismissRequest = onDismiss) {
        Card(shape = RoundedCornerShape(16.dp)) {
            Column(
                Modifier
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(18.dp)
            ) {
                Text("Getting your data from another app", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                Text(
                    "Most fitness apps can export your food diary, exercise, and weight as CSV files. There are usually two ways to get them:",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                GuideBlock(
                    number = "1",
                    title = "Export from your account (fastest)",
                    steps = listOf(
                        "On a computer, sign in to your current app's website.",
                        "Open its account or data settings and look for an Export Data option.",
                        "Request your data. Many apps email you CSV files for food, exercise, and measurements.",
                        "Save the files to your phone, then come back here and choose one."
                    ),
                    note = "Some apps keep the one-tap export behind a paid plan."
                )
                GuideBlock(
                    number = "2",
                    title = "Request your data for free",
                    steps = listOf(
                        "If export isn't on the free plan, you can still ask the app for a copy of your data.",
                        "In the app, open Settings, then look for a Privacy Center or a data request option.",
                        "They'll email you an archive within a few days. It includes your food, exercise, and weight history as CSV.",
                        "Save the files to your phone and choose them here, one at a time."
                    ),
                    note = "This is your data. The app has to provide it on request."
                )
                Button(onClick = onDismiss, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = ImportGreen)) {
                    Text("Got it")
                }
            }
        }
    }
}

@Composable
private fun GuideBlock(number: String, title: String, steps: List<String>, note: String) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Surface(shape = RoundedCornerShape(50), color = ImportGreen, modifier = Modifier.size(28.dp)) {
                Box(contentAlignment = Alignment.Center) {
                    Text(number, color = Color.White, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.bodyMedium)
                }
            }
            Text(title, style = MaterialTheme.typography.titleMedium)
        }
        steps.forEach { step ->
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("•", color = ImportGreen)
                Text(step, style = MaterialTheme.typography.bodyMedium)
            }
        }
        Text(note, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
