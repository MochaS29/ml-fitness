package com.mochasmindlab.mlhealth.ui.screens.copy

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.CopyFromPreviousDayViewModel
import kotlinx.coroutines.flow.collectLatest
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CopyFromPreviousDayScreen(
    navController: NavController,
    targetDateMillis: Long? = null,
    viewModel: CopyFromPreviousDayViewModel = hiltViewModel()
) {
    val targetDate = remember { targetDateMillis?.let { Date(it) } ?: Date() }

    LaunchedEffect(targetDate) {
        viewModel.setTargetDate(targetDate)
    }

    val sourceDate by viewModel.selectedSourceDate.collectAsState()
    val foodEntries by viewModel.foodEntries.collectAsState()
    val supplementEntries by viewModel.supplementEntries.collectAsState()
    val selectedFoodIds by viewModel.selectedFoodIds.collectAsState()
    val selectedSupplementIds by viewModel.selectedSupplementIds.collectAsState()
    val isCopying by viewModel.isCopying.collectAsState()

    val snackbarHostState = remember { SnackbarHostState() }
    val dateFormat = remember { SimpleDateFormat("MMM d, yyyy", Locale.getDefault()) }

    LaunchedEffect(Unit) {
        viewModel.done.collectLatest { count ->
            snackbarHostState.showSnackbar("Copied $count item${if (count != 1) "s" else ""} to ${dateFormat.format(targetDate)}")
            navController.popBackStack()
        }
    }

    val foodByMeal = remember(foodEntries) {
        MealType.values().associateWith { meal ->
            foodEntries.filter { it.mealType.equals(meal.name, ignoreCase = true) }
        }.filterValues { it.isNotEmpty() }
    }

    val totalSelected = selectedFoodIds.size + selectedSupplementIds.size

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Copy from Previous Day", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    if (foodEntries.isNotEmpty() || supplementEntries.isNotEmpty()) {
                        TextButton(onClick = {
                            if (totalSelected == foodEntries.size + supplementEntries.size) viewModel.selectNone()
                            else viewModel.selectAll()
                        }) {
                            Text(
                                if (totalSelected == foodEntries.size + supplementEntries.size) "None" else "All",
                                color = MochaBrown
                            )
                        }
                    }
                }
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        "Copy to: ${dateFormat.format(targetDate)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Button(
                        onClick = { viewModel.copy(targetDate) },
                        enabled = totalSelected > 0 && !isCopying,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = MochaBrown)
                    ) {
                        if (isCopying) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(18.dp),
                                strokeWidth = 2.dp,
                                color = MaterialTheme.colorScheme.onPrimary
                            )
                        } else {
                            Text("Copy $totalSelected item${if (totalSelected != 1) "s" else ""}")
                        }
                    }
                }
            }
        },
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(bottom = 8.dp)
        ) {
            item { SourceDateStepper(sourceDate, dateFormat, viewModel) }

            if (foodEntries.isEmpty() && supplementEntries.isEmpty()) {
                item { EmptyState(sourceDate, dateFormat, viewModel) }
            } else {
                foodByMeal.forEach { (meal, entries) ->
                    val allSelected = entries.all { it.id in selectedFoodIds }
                    item {
                        MealGroupHeader(
                            meal = meal,
                            count = entries.size,
                            totalCals = entries.sumOf { it.calories }.toInt(),
                            allSelected = allSelected,
                            onToggleAll = {
                                if (allSelected) viewModel.deselectAllForMeal(meal.name)
                                else viewModel.selectAllForMeal(meal.name)
                            }
                        )
                    }
                    items(entries, key = { it.id }) { entry ->
                        FoodEntryRow(
                            name = entry.name,
                            brand = entry.brand,
                            calories = entry.calories.toInt(),
                            serving = "${entry.servingCount}×${entry.servingSize} ${entry.servingUnit}",
                            checked = entry.id in selectedFoodIds,
                            onChecked = { viewModel.toggleFood(entry.id) }
                        )
                    }
                }

                if (supplementEntries.isNotEmpty()) {
                    item {
                        ListItem(
                            headlineContent = {
                                Text("Supplements", fontWeight = FontWeight.SemiBold)
                            },
                            supportingContent = { Text("${supplementEntries.size} item${if (supplementEntries.size != 1) "s" else ""}") },
                            trailingContent = {
                                val allSuppSelected = supplementEntries.all { it.id in selectedSupplementIds }
                                TextButton(onClick = {
                                    supplementEntries.forEach { s ->
                                        if (allSuppSelected) {
                                            if (s.id in selectedSupplementIds) viewModel.toggleSupplement(s.id)
                                        } else {
                                            if (s.id !in selectedSupplementIds) viewModel.toggleSupplement(s.id)
                                        }
                                    }
                                }) {
                                    Text(if (allSuppSelected) "Deselect all" else "Select all", color = MochaBrown)
                                }
                            }
                        )
                    }
                    items(supplementEntries, key = { it.id }) { entry ->
                        SupplementEntryRow(
                            name = entry.name,
                            brand = entry.brand,
                            serving = "${entry.servingSize} ${entry.servingUnit}",
                            checked = entry.id in selectedSupplementIds,
                            onChecked = { viewModel.toggleSupplement(entry.id) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SourceDateStepper(
    sourceDate: Date,
    fmt: SimpleDateFormat,
    viewModel: CopyFromPreviousDayViewModel
) {
    val today = remember { Calendar.getInstance().time }
    Surface(
        tonalElevation = 2.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = MaterialTheme.shapes.medium
    ) {
        Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(
                "Copy from",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                IconButton(onClick = {
                    val cal = Calendar.getInstance().apply { time = sourceDate; add(Calendar.DAY_OF_YEAR, -1) }
                    viewModel.setSourceDate(cal.time)
                }) {
                    Icon(Icons.Default.ChevronLeft, contentDescription = "Previous day")
                }
                Text(
                    fmt.format(sourceDate),
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.weight(1f)
                )
                IconButton(
                    onClick = {
                        val cal = Calendar.getInstance().apply { time = sourceDate; add(Calendar.DAY_OF_YEAR, 1) }
                        viewModel.setSourceDate(cal.time)
                    },
                    enabled = sourceDate.before(today)
                ) {
                    Icon(Icons.Default.ChevronRight, contentDescription = "Next day")
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                QuickDateChip("Yesterday", -1, viewModel)
                QuickDateChip("2 days ago", -2, viewModel)
                QuickDateChip("Last week", -7, viewModel)
            }
        }
    }
}

@Composable
private fun QuickDateChip(label: String, offset: Int, viewModel: CopyFromPreviousDayViewModel) {
    AssistChip(
        onClick = {
            val cal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, offset) }
            viewModel.setSourceDate(cal.time)
        },
        label = { Text(label, style = MaterialTheme.typography.labelSmall) }
    )
}

@Composable
private fun MealGroupHeader(
    meal: MealType,
    count: Int,
    totalCals: Int,
    allSelected: Boolean,
    onToggleAll: () -> Unit
) {
    ListItem(
        headlineContent = {
            Text(meal.displayName, fontWeight = FontWeight.SemiBold)
        },
        supportingContent = { Text("$count item${if (count != 1) "s" else ""} · $totalCals cal") },
        trailingContent = {
            Checkbox(
                checked = allSelected,
                onCheckedChange = { onToggleAll() },
                colors = CheckboxDefaults.colors(checkedColor = MochaBrown)
            )
        }
    )
    Divider(modifier = Modifier.padding(horizontal = 16.dp))
}

@Composable
private fun FoodEntryRow(
    name: String,
    brand: String?,
    calories: Int,
    serving: String,
    checked: Boolean,
    onChecked: () -> Unit
) {
    ListItem(
        modifier = Modifier.padding(start = 16.dp),
        headlineContent = { Text(name) },
        supportingContent = {
            Text(
                buildString {
                    if (!brand.isNullOrBlank()) append("$brand · ")
                    append(serving)
                },
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        },
        trailingContent = {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    "$calories cal",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Checkbox(
                    checked = checked,
                    onCheckedChange = { onChecked() },
                    colors = CheckboxDefaults.colors(checkedColor = MochaBrown)
                )
            }
        }
    )
}

@Composable
private fun SupplementEntryRow(
    name: String,
    brand: String?,
    serving: String,
    checked: Boolean,
    onChecked: () -> Unit
) {
    ListItem(
        modifier = Modifier.padding(start = 16.dp),
        headlineContent = { Text(name) },
        supportingContent = {
            Text(
                buildString {
                    if (!brand.isNullOrBlank()) append("$brand · ")
                    append(serving)
                },
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        },
        trailingContent = {
            Checkbox(
                checked = checked,
                onCheckedChange = { onChecked() },
                colors = CheckboxDefaults.colors(checkedColor = MochaBrown)
            )
        }
    )
}

@Composable
private fun EmptyState(sourceDate: Date, fmt: SimpleDateFormat, viewModel: CopyFromPreviousDayViewModel) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            "No entries on ${fmt.format(sourceDate)}",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            "Try a different source date",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        TextButton(onClick = {
            val cal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -1) }
            viewModel.setSourceDate(cal.time)
        }) {
            Text("Go to yesterday", color = MochaBrown)
        }
    }
}

// TODO: Wire this screen into navigation.
//
// In ui/navigation/MLFitnessNavigation.kt, add inside the NavHost block:
//
//   composable("copy_from_previous") {
//       CopyFromPreviousDayScreen(navController = navController)
//   }
//
//   // With optional target date param:
//   composable(
//       "copy_from_previous?targetDate={targetDate}",
//       arguments = listOf(navArgument("targetDate") { type = NavType.LongType; defaultValue = -1L })
//   ) { backStackEntry ->
//       val millis = backStackEntry.arguments?.getLong("targetDate")?.takeIf { it >= 0 }
//       CopyFromPreviousDayScreen(navController = navController, targetDateMillis = millis)
//   }
//
// In ui/screens/diary/DiaryScreen.kt, add a content-copy action in the TopAppBar actions slot:
//
//   IconButton(onClick = { navController.navigate("copy_from_previous") }) {
//       Icon(Icons.Default.ContentCopy, contentDescription = "Copy from previous day", tint = MochaBrown)
//   }
