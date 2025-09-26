package com.mlhealth.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mlhealth.app.data.Supplement
import com.mlhealth.app.data.SupplementDatabase
import com.mlhealth.app.services.SupplementBarcodeScannerScreen
import com.mlhealth.app.viewmodel.SupplementViewModel
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SupplementTrackingScreen(
    viewModel: SupplementViewModel = hiltViewModel()
) {
    var showBarcodeScanner by remember { mutableStateOf(false) }
    var showManualEntry by remember { mutableStateOf(false) }
    var showLabelScanner by remember { mutableStateOf(false) }

    val supplements by viewModel.supplements.collectAsState()
    val todaysSupplements = supplements.filter { supplement ->
        supplement.date.toLocalDate() == LocalDate.now()
    }
    val previousSupplements = supplements.filter { supplement ->
        supplement.date.toLocalDate() != LocalDate.now()
    }

    if (showBarcodeScanner) {
        SupplementBarcodeScannerScreen(
            onSupplementFound = { supplement ->
                viewModel.addSupplement(supplement)
                showBarcodeScanner = false
            },
            onDismiss = {
                showBarcodeScanner = false
            }
        )
    } else if (showManualEntry) {
        ManualSupplementEntryScreen(
            onSave = { supplement ->
                viewModel.addSupplement(supplement)
                showManualEntry = false
            },
            onDismiss = {
                showManualEntry = false
            }
        )
    } else {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Supplements") },
                    actions = {
                        IconButton(onClick = { /* Show analysis */ }) {
                            Icon(
                                Icons.Default.Analytics,
                                contentDescription = "Analysis"
                            )
                        }
                    }
                )
            }
        ) { paddingValues ->
            if (supplements.isEmpty()) {
                EmptySupplementsView(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    onScanBarcode = { showBarcodeScanner = true },
                    onScanLabel = { showLabelScanner = true },
                    onManualEntry = { showManualEntry = true }
                )
            } else {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    contentPadding = PaddingValues(16.dp)
                ) {
                    // Action buttons
                    item {
                        Card(
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Button(
                                        onClick = { showBarcodeScanner = true },
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Icon(
                                            Icons.Default.QrCodeScanner,
                                            contentDescription = null,
                                            modifier = Modifier.size(18.dp)
                                        )
                                        Spacer(modifier = Modifier.width(8.dp))
                                        Text("Scan Barcode")
                                    }

                                    OutlinedButton(
                                        onClick = { showLabelScanner = true },
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Icon(
                                            Icons.Default.CameraAlt,
                                            contentDescription = null,
                                            modifier = Modifier.size(18.dp)
                                        )
                                        Spacer(modifier = Modifier.width(8.dp))
                                        Text("Scan Label")
                                    }
                                }

                                OutlinedButton(
                                    onClick = { showManualEntry = true },
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Icon(
                                        Icons.Default.Add,
                                        contentDescription = null,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Manual Entry")
                                }
                            }
                        }
                    }

                    // Today's supplements
                    if (todaysSupplements.isNotEmpty()) {
                        item {
                            Text(
                                "Today's Supplements",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(vertical = 8.dp)
                            )
                        }

                        items(todaysSupplements) { supplement ->
                            SupplementCard(
                                supplement = supplement,
                                onDelete = { viewModel.deleteSupplement(supplement) }
                            )
                        }
                    }

                    // Previous supplements
                    if (previousSupplements.isNotEmpty()) {
                        item {
                            Text(
                                "Previous Days",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(vertical = 8.dp)
                            )
                        }

                        items(previousSupplements) { supplement ->
                            SupplementCard(
                                supplement = supplement,
                                onDelete = { viewModel.deleteSupplement(supplement) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun EmptySupplementsView(
    modifier: Modifier = Modifier,
    onScanBarcode: () -> Unit,
    onScanLabel: () -> Unit,
    onManualEntry: () -> Unit
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            Icons.Default.Medication,
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            "No Supplements Tracked",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.SemiBold
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            "Start tracking your vitamins and supplements\nto monitor your nutrient intake",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 32.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        Column(
            modifier = Modifier.padding(horizontal = 48.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick = onScanBarcode,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    Icons.Default.QrCodeScanner,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Scan Supplement Barcode")
            }

            OutlinedButton(
                onClick = onScanLabel,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    Icons.Default.CameraAlt,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Scan Supplement Label")
            }

            OutlinedButton(
                onClick = onManualEntry,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Manual Entry")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SupplementCard(
    supplement: SupplementEntry,
    onDelete: () -> Unit
) {
    var showDetails by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = { showDetails = !showDetails }
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.Medication,
                        contentDescription = null,
                        modifier = Modifier.size(32.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )

                    Spacer(modifier = Modifier.width(12.dp))

                    Column {
                        Text(
                            supplement.name,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Medium
                        )

                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                supplement.brand,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )

                            Text(
                                "• ${supplement.nutrientCount} nutrients",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        supplement.date.format(DateTimeFormatter.ofPattern("HH:mm")),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    IconButton(onClick = onDelete) {
                        Icon(
                            Icons.Default.Delete,
                            contentDescription = "Delete",
                            tint = MaterialTheme.colorScheme.error,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }

            AnimatedVisibility(visible = showDetails) {
                Column(
                    modifier = Modifier.padding(top = 12.dp)
                ) {
                    Divider(modifier = Modifier.padding(vertical = 8.dp))

                    // Show nutrient details
                    supplement.nutrients.forEach { (nutrientName, amount) ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 2.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                nutrientName,
                                style = MaterialTheme.typography.bodySmall
                            )
                            Text(
                                "$amount ${getUnitForNutrient(nutrientName)}",
                                style = MaterialTheme.typography.bodySmall,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ManualSupplementEntryScreen(
    onSave: (Supplement) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedSupplement by remember { mutableStateOf<Supplement?>(null) }
    var searchQuery by remember { mutableStateOf("") }

    val allSupplements = remember { SupplementDatabase.supplements.value }
    val filteredSupplements = remember(searchQuery) {
        if (searchQuery.isBlank()) {
            allSupplements
        } else {
            SupplementDatabase.searchByName(searchQuery)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add Supplement") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                },
                actions = {
                    if (selectedSupplement != null) {
                        TextButton(
                            onClick = {
                                selectedSupplement?.let(onSave)
                            }
                        ) {
                            Text("Add", fontWeight = FontWeight.Bold)
                        }
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
        ) {
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                label = { Text("Search supplements") },
                leadingIcon = {
                    Icon(Icons.Default.Search, contentDescription = null)
                },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(16.dp))

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(filteredSupplements) { supplement ->
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = if (selectedSupplement == supplement) {
                                MaterialTheme.colorScheme.primaryContainer
                            } else {
                                MaterialTheme.colorScheme.surface
                            }
                        ),
                        onClick = { selectedSupplement = supplement }
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(
                                    supplement.name,
                                    style = MaterialTheme.typography.titleMedium
                                )
                                Text(
                                    supplement.brand,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }

                            if (selectedSupplement == supplement) {
                                Icon(
                                    Icons.Default.CheckCircle,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.primary
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// Data class for supplement entries
data class SupplementEntry(
    val id: String,
    val name: String,
    val brand: String,
    val date: LocalDateTime,
    val nutrients: Map<String, Double>,
    val barcode: String? = null
) {
    val nutrientCount: Int
        get() = nutrients.size
}

// Helper function to get unit for nutrient
fun getUnitForNutrient(nutrientName: String): String {
    return when (nutrientName.lowercase()) {
        "vitamin a" -> "mcg"
        "vitamin c" -> "mg"
        "vitamin d" -> "mcg"
        "vitamin e" -> "mg"
        "vitamin k" -> "mcg"
        "thiamine", "riboflavin", "niacin", "vitamin b6", "pantothenic acid" -> "mg"
        "folate", "vitamin b12", "biotin" -> "mcg"
        "calcium", "iron", "magnesium", "phosphorus", "potassium", "sodium", "zinc", "copper", "manganese" -> "mg"
        "selenium", "chromium", "molybdenum", "iodine" -> "mcg"
        else -> ""
    }
}