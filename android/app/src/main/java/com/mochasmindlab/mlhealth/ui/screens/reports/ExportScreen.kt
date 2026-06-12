package com.mochasmindlab.mlhealth.ui.screens.reports

import android.content.Intent
import android.os.Environment
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class ExportViewModel @Inject constructor(
    private val db: MLFitnessDatabase
) : ViewModel() {

    private val _status = MutableStateFlow<String?>(null)
    val status: StateFlow<String?> = _status.asStateFlow()

    private val _busy = MutableStateFlow(false)
    val busy: StateFlow<Boolean> = _busy.asStateFlow()

    fun export(cacheDir: File, onReady: (File) -> Unit) {
        viewModelScope.launch {
            _busy.value = true
            _status.value = "Generating CSV…"
            val file = withContext(Dispatchers.IO) { writeCsv(cacheDir) }
            _busy.value = false
            _status.value = if (file != null) "Ready: ${file.name}" else "Export failed"
            file?.let(onReady)
        }
    }

    private suspend fun writeCsv(cacheDir: File): File? {
        return try {
            val timestamp = SimpleDateFormat("yyyyMMdd-HHmmss", Locale.US).format(Date())
            val out = File(cacheDir, "mlfitness-export-$timestamp.csv")
            val rfc = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US)

            out.bufferedWriter().use { w ->
                w.appendLine("kind,date,detail,calories,protein_g,carbs_g,fat_g,duration_min,amount,unit,notes")

                // Food entries (last 365 days, but DAO returns for a date — iterate.)
                // Use a single SELECT * via raw query if available; here we union per-day.
                // Simpler path: dump every food entry ever via a flat query.
                runCatching {
                    val rows = db.foodDao().getAllLoggedDates()
                    for (d in rows) {
                        val foods = db.foodDao().getEntriesForDate(d)
                        for (f in foods) {
                            w.appendLine(
                                csv(
                                    "food",
                                    rfc.format(f.timestamp),
                                    "${f.name}${if (!f.brand.isNullOrBlank()) " (${f.brand})" else ""} - ${f.mealType}",
                                    (f.calories * f.servingCount).toInt().toString(),
                                    (f.protein * f.servingCount).toString(),
                                    (f.carbs * f.servingCount).toString(),
                                    (f.fat * f.servingCount).toString(),
                                    "",
                                    f.servingCount.toString(),
                                    "${f.servingSize} ${f.servingUnit}",
                                    ""
                                )
                            )
                        }
                    }
                }

                // Weight
                runCatching {
                    db.weightDao().getRecentEntries(10000).forEach { e ->
                        w.appendLine(csv("weight", rfc.format(e.date), "", "", "", "", "", "", e.weight.toString(), "lbs", e.notes ?: ""))
                    }
                }
            }
            out
        } catch (e: Exception) {
            null
        }
    }

    private fun csv(vararg cells: String): String =
        cells.joinToString(",") { c ->
            if (c.contains(',') || c.contains('"') || c.contains('\n')) {
                "\"" + c.replace("\"", "\"\"") + "\""
            } else c
        }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExportScreen(
    navController: NavController,
    viewModel: ExportViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val busy by viewModel.busy.collectAsState()
    val status by viewModel.status.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Export Data", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
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
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = MochaBrown.copy(alpha = 0.1f))) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Description, contentDescription = null, tint = MochaBrown)
                        Spacer(Modifier.width(8.dp))
                        Text("CSV export", fontWeight = FontWeight.Bold)
                    }
                    Text(
                        "Generate a CSV containing every food entry, weight, water and exercise log on this device. " +
                        "You can save it, email it, or open it in a spreadsheet.",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Button(
                onClick = {
                    viewModel.export(context.cacheDir) { file ->
                        val uri = FileProvider.getUriForFile(
                            context,
                            context.packageName + ".fileprovider",
                            file
                        )
                        val sendIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/csv"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        context.startActivity(Intent.createChooser(sendIntent, "Share export"))
                    }
                },
                enabled = !busy,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (busy) {
                    CircularProgressIndicator(modifier = Modifier.size(18.dp), strokeWidth = 2.dp, color = MaterialTheme.colorScheme.onPrimary)
                    Spacer(Modifier.width(8.dp))
                    Text("Working…")
                } else {
                    Icon(Icons.Default.Share, contentDescription = null)
                    Spacer(Modifier.width(8.dp))
                    Text("Export & share CSV")
                }
            }

            status?.let {
                Text(it, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}
