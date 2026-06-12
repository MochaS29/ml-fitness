package com.mochasmindlab.mlhealth.ui.screens.supplements

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry
import com.mochasmindlab.mlhealth.ui.theme.SupplementPurple
import com.mochasmindlab.mlhealth.viewmodel.SupplementsViewModel
import java.text.SimpleDateFormat
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SupplementsScreen(
    navController: NavController,
    viewModel: SupplementsViewModel = hiltViewModel()
) {
    val entries by viewModel.entries.collectAsState()
    val suggestions by viewModel.suggestions.collectAsState()
    var showAddDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Supplements", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddDialog = true },
                containerColor = SupplementPurple
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Supplement")
            }
        }
    ) { padding ->
        if (entries.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("💊", fontSize = 48.sp)
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "No supplements logged today",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        "Tap + to add your first one",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(entries, key = { it.id }) { entry ->
                    SupplementRow(
                        entry = entry,
                        onDelete = { viewModel.delete(entry) }
                    )
                }
            }
        }
    }

    if (showAddDialog) {
        AddSupplementDialog(
            suggestions = suggestions,
            onDismiss = { showAddDialog = false },
            onSave = { name, brand, size, unit ->
                viewModel.add(name, brand, size, unit)
                showAddDialog = false
            }
        )
    }
}

@Composable
private fun SupplementRow(
    entry: SupplementEntry,
    onDelete: () -> Unit
) {
    val timeFmt = remember { SimpleDateFormat("h:mm a", Locale.getDefault()) }
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = SupplementPurple.copy(alpha = 0.08f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("💊", fontSize = 24.sp)
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(entry.name, fontWeight = FontWeight.Medium, fontSize = 16.sp)
                val detail = buildString {
                    append("${entry.servingSize} ${entry.servingUnit}")
                    if (!entry.brand.isNullOrBlank()) append(" • ${entry.brand}")
                }
                Text(
                    detail,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    timeFmt.format(entry.timestamp),
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

/** Common supplements offered as one-tap presets in the Add dialog. */
private data class SupplementPreset(
    val name: String,
    val defaultUnit: String
)

private val COMMON_SUPPLEMENTS = listOf(
    SupplementPreset("Multivitamin", "tablet"),
    SupplementPreset("Vitamin D3", "softgel"),
    SupplementPreset("Omega-3 / Fish Oil", "softgel"),
    SupplementPreset("Vitamin C", "tablet"),
    SupplementPreset("Vitamin B12", "tablet"),
    SupplementPreset("Magnesium", "capsule"),
    SupplementPreset("Calcium", "tablet"),
    SupplementPreset("Iron", "tablet"),
    SupplementPreset("Zinc", "tablet"),
    SupplementPreset("Probiotic", "capsule"),
    SupplementPreset("Collagen", "scoop"),
    SupplementPreset("Whey Protein", "scoop"),
    SupplementPreset("Creatine", "scoop"),
    SupplementPreset("Biotin", "tablet"),
    SupplementPreset("Turmeric / Curcumin", "capsule"),
    SupplementPreset("Melatonin", "tablet"),
    SupplementPreset("Ashwagandha", "capsule"),
    SupplementPreset("CoQ10", "softgel")
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddSupplementDialog(
    suggestions: List<String>,
    onDismiss: () -> Unit,
    onSave: (name: String, brand: String?, servingSize: String, servingUnit: String) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var brand by remember { mutableStateOf("") }
    var servingSize by remember { mutableStateOf("1") }
    var servingUnit by remember { mutableStateOf("tablet") }

    val canSave = name.isNotBlank() && servingSize.isNotBlank() && servingUnit.isNotBlank()

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Supplement") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    "Pick a common one or type your own:",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Row(
                    modifier = Modifier.horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    COMMON_SUPPLEMENTS.forEach { preset ->
                        AssistChip(
                            onClick = {
                                name = preset.name
                                servingUnit = preset.defaultUnit
                            },
                            label = { Text(preset.name, fontSize = 12.sp) }
                        )
                    }
                }
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Name") },
                    placeholder = { Text("e.g. Vitamin D3") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                if (suggestions.isNotEmpty() && name.isNotBlank()) {
                    val matches = suggestions.filter {
                        it.contains(name, ignoreCase = true) && it != name
                    }.take(3)
                    matches.forEach { suggestion ->
                        AssistChip(
                            onClick = { name = suggestion },
                            label = { Text(suggestion, fontSize = 12.sp) }
                        )
                    }
                }
                OutlinedTextField(
                    value = brand,
                    onValueChange = { brand = it },
                    label = { Text("Brand (optional)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(
                        value = servingSize,
                        onValueChange = { servingSize = it },
                        label = { Text("Amount") },
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = servingUnit,
                        onValueChange = { servingUnit = it },
                        label = { Text("Unit") },
                        placeholder = { Text("tablet") },
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    onSave(name, brand.ifBlank { null }, servingSize, servingUnit)
                },
                enabled = canSave
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}
