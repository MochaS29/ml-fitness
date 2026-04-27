package com.mochasmindlab.mlhealth.ui.screens.rda

// TODO: register route in MLFitnessNavigation.kt:
//   composable("rda") { RDAScreen(navController) }

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.RDAEntry
import com.mochasmindlab.mlhealth.ui.theme.ErrorRed
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.ui.theme.SuccessGreen
import com.mochasmindlab.mlhealth.viewmodel.RDAViewModel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.min

// ---------------------------------------------------------------------------
// Explanation copy for each nutrient tap
// ---------------------------------------------------------------------------
private val explanations = mapOf(
    "Calories"      to "Total energy intake. Consistently eating above your target leads to weight gain; below leads to weight loss.",
    "Protein"       to "Essential for muscle repair and immune function. Aim to meet your daily target, especially on active days.",
    "Carbohydrates" to "Your body's primary energy source. Focus on complex carbs (whole grains, legumes) over refined carbs.",
    "Total Fat"     to "Healthy unsaturated fats support brain and heart health. Balance fat intake within your daily goal.",
    "Fiber"         to "Supports digestion, blood sugar stability, and cholesterol levels. Most people fall short of their daily target.",
    "Sugar"         to "Excess free sugar raises blood sugar and is linked to metabolic disease. Stay under 50 g/day.",
    "Sodium"        to "Sodium > 2 300 mg/day raises blood pressure risk over time. Watch packaged and restaurant foods.",
    "Saturated Fat" to "High saturated fat intake is linked to elevated LDL cholesterol. Limit to < 10% of daily calories.",
    "Cholesterol"   to "Dietary cholesterol has modest effects on blood levels for most people. Keeping under 300 mg is a prudent limit."
)

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RDAScreen(
    navController: NavController,
    viewModel: RDAViewModel = hiltViewModel()
) {
    val entries   by viewModel.entries.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    val dateLabel = remember {
        SimpleDateFormat("EEEE, MMM d", Locale.getDefault()).format(Date())
    }

    var expandedEntry by remember { mutableStateOf<String?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Daily Nutrients", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->

        when {
            isLoading -> {
                Box(
                    Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = MochaBrown)
                }
            }

            entries.isEmpty() -> {
                EmptyState(
                    Modifier
                        .fillMaxSize()
                        .padding(padding)
                )
            }

            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Header card
                    item {
                        HeaderCard(dateLabel)
                        Spacer(Modifier.height(4.dp))
                    }

                    // Goal rows
                    items(entries.filter { !it.isLimit }, key = { it.name }) { entry ->
                        RDARow(
                            entry       = entry,
                            isExpanded  = expandedEntry == entry.name,
                            onToggle    = {
                                expandedEntry = if (expandedEntry == entry.name) null else entry.name
                            }
                        )
                    }

                    // Divider + limit rows
                    item {
                        Spacer(Modifier.height(4.dp))
                        Text(
                            "Daily Limits",
                            style     = MaterialTheme.typography.labelMedium,
                            color     = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier  = Modifier.padding(vertical = 4.dp)
                        )
                    }

                    items(entries.filter { it.isLimit }, key = { it.name }) { entry ->
                        RDARow(
                            entry      = entry,
                            isExpanded = expandedEntry == entry.name,
                            onToggle   = {
                                expandedEntry = if (expandedEntry == entry.name) null else entry.name
                            }
                        )
                    }

                    item { Spacer(Modifier.height(8.dp)) }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

@Composable
private fun HeaderCard(dateLabel: String) {
    Card(
        shape  = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MochaBrown),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(
                "Today's RDA Analysis",
                style      = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color      = Color.White
            )
            Text(
                dateLabel,
                style = MaterialTheme.typography.bodySmall,
                color = Color.White.copy(alpha = 0.85f)
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Single nutrient row
// ---------------------------------------------------------------------------

@Composable
private fun RDARow(
    entry: RDAEntry,
    isExpanded: Boolean,
    onToggle: () -> Unit
) {
    val progress  = if (entry.goal > 0) (entry.current / entry.goal).toFloat() else 0f
    val clamped   = min(progress, 1f)

    // Color logic:
    //  limit nutrient  → green when under (progress < 1), red when over
    //  goal nutrient   → green when met (progress >= 1), primary below
    val barColor = when {
        entry.isLimit && progress >= 1f -> ErrorRed
        entry.isLimit                   -> SuccessGreen
        progress >= 1f                  -> SuccessGreen
        else                            -> MochaBrown
    }

    Card(
        shape  = RoundedCornerShape(10.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onToggle() }
    ) {
        Column(Modifier.padding(horizontal = 14.dp, vertical = 12.dp)) {

            // Top row: name + value
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(entry.name, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.width(4.dp))
                    Icon(
                        Icons.Default.Info,
                        contentDescription = "Info",
                        tint     = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(14.dp)
                    )
                }
                Text(
                    text  = "${formatValue(entry.current, entry.unit)} / ${formatValue(entry.goal, entry.unit)} ${entry.unit}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(Modifier.height(6.dp))

            // Progress bar
            LinearProgressIndicator(
                progress  = clamped,
                color     = barColor,
                trackColor = MaterialTheme.colorScheme.surfaceVariant,
                modifier  = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
            )

            // Percent label
            val pct = (progress * 100).toInt()
            Text(
                text  = if (entry.isLimit) "$pct% of limit" else "$pct% of goal",
                style = MaterialTheme.typography.labelSmall,
                color = barColor,
                modifier = Modifier.padding(top = 2.dp)
            )

            // Explanation banner (animated)
            AnimatedVisibility(visible = isExpanded, enter = fadeIn(), exit = fadeOut()) {
                val text = explanations[entry.name] ?: ""
                if (text.isNotEmpty()) {
                    Surface(
                        color    = barColor.copy(alpha = 0.10f),
                        shape    = RoundedCornerShape(6.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 8.dp)
                    ) {
                        Text(
                            text     = text,
                            style    = MaterialTheme.typography.bodySmall,
                            color    = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier.padding(8.dp)
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

@Composable
private fun EmptyState(modifier: Modifier = Modifier) {
    Box(modifier, contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                "No food logged today",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(Modifier.height(4.dp))
            Text(
                "Log a meal to see your RDA analysis.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

private fun formatValue(value: Double, unit: String): String {
    return if (unit == "mg") value.toInt().toString()
    else "%.1f".format(value)
}
