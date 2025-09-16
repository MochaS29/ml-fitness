package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FunctionalDashboardScreen(
    navController: NavController,
    viewModel: DashboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val aiInsights by viewModel.aiInsights.collectAsStateWithLifecycle()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            "Hello, ${uiState.userName}!",
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            "Ready to crush your goals?",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { 
                        navController.navigate("notifications")
                    }) {
                        Icon(Icons.Default.Notifications, contentDescription = "Notifications")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
        ) {
            // Time Range Selector
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                DashboardPeriod.values().forEach { period ->
                    FilterChip(
                        selected = uiState.selectedPeriod == period,
                        onClick = { viewModel.selectPeriod(period) },
                        label = { 
                            Text(when(period) {
                                DashboardPeriod.DAY -> "Day"
                                DashboardPeriod.WEEK -> "Week"
                                DashboardPeriod.MONTH -> "Month"
                            })
                        }
                    )
                }
            }
            
            // AI Insights Section
            if (aiInsights.isNotEmpty()) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF7B68EE).copy(alpha = 0.1f)
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    Icons.Default.Psychology,
                                    contentDescription = "AI Insights",
                                    tint = Color(0xFF7B68EE)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    "AI Insights",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 18.sp
                                )
                            }
                            TextButton(onClick = { 
                                navController.navigate("ai_insights")
                            }) {
                                Text("View All", color = MindfulTeal)
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(12.dp))
                        
                        // Display first AI Insight
                        aiInsights.firstOrNull()?.let { insight ->
                            Card(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { navController.navigate("ai_insights") },
                                colors = CardDefaults.cardColors(containerColor = Color.White)
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(12.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = getInsightIcon(insight.type),
                                        contentDescription = null,
                                        tint = getInsightColor(insight.priority),
                                        modifier = Modifier.size(32.dp)
                                    )
                                    Spacer(modifier = Modifier.width(12.dp))
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(
                                            insight.title,
                                            fontWeight = FontWeight.SemiBold
                                        )
                                        Text(
                                            insight.description,
                                            fontSize = 12.sp,
                                            color = Color.Gray
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Metrics Grid
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Calories",
                    value = "${uiState.caloriesConsumed}",
                    subtitle = "/ ${uiState.caloriesGoal} kcal",
                    icon = Icons.Default.LocalFireDepartment,
                    color = EnergeticOrange,
                    progress = (uiState.caloriesConsumed.toFloat() / uiState.caloriesGoal).coerceIn(0f, 1f),
                    onClick = { navController.navigate("nutrition") }
                )
                
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Water",
                    value = "${uiState.waterCups}",
                    subtitle = "/ ${uiState.waterGoal} cups",
                    icon = Icons.Default.WaterDrop,
                    color = HydrationBlue,
                    progress = (uiState.waterCups.toFloat() / uiState.waterGoal).coerceIn(0f, 1f),
                    onClick = { navController.navigate("water") }
                )
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Exercise",
                    value = "${uiState.exerciseMinutes}",
                    subtitle = "minutes",
                    icon = Icons.Default.DirectionsRun,
                    color = ExerciseGreen,
                    progress = (uiState.exerciseMinutes.toFloat() / uiState.exerciseGoal).coerceIn(0f, 1f),
                    onClick = { navController.navigate("exercise") }
                )
                
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Weight",
                    value = String.format("%.1f", uiState.currentWeight),
                    subtitle = "lbs",
                    icon = Icons.Default.Monitor,
                    color = BalancedPurple,
                    progress = 0.9f,
                    onClick = { navController.navigate("weight") }
                )
            }
            
            // Quick Actions
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        "Quick Actions",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        QuickActionButton(
                            icon = Icons.Default.QrCodeScanner,
                            label = "Scan",
                            onClick = { navController.navigate("barcode_scan") }
                        )
                        QuickActionButton(
                            icon = Icons.Default.Add,
                            label = "Log Food",
                            onClick = { navController.navigate("food_search") }
                        )
                        QuickActionButton(
                            icon = Icons.Default.CalendarMonth,
                            label = "Plan",
                            onClick = { navController.navigate("meal_planning") }
                        )
                        QuickActionButton(
                            icon = Icons.Default.EmojiEvents,
                            label = "Goals",
                            onClick = { navController.navigate("goals") }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun MetricCard(
    modifier: Modifier = Modifier,
    title: String,
    value: String,
    subtitle: String,
    icon: ImageVector,
    color: Color,
    progress: Float,
    onClick: () -> Unit = {}
) {
    Card(
        modifier = modifier.clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = Color.White
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = 2.dp
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = color,
                modifier = Modifier.size(24.dp)
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = value,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black
            )
            
            Text(
                text = subtitle,
                fontSize = 11.sp,
                color = Color.Gray
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            LinearProgressIndicator(
                progress = progress,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp),
                color = color,
                trackColor = color.copy(alpha = 0.2f)
            )
        }
    }
}

@Composable
private fun QuickActionButton(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        FilledIconButton(
            onClick = onClick,
            modifier = Modifier.size(56.dp),
            colors = IconButtonDefaults.filledIconButtonColors(
                containerColor = Color(0xFF7B68EE).copy(alpha = 0.1f)
            )
        ) {
            Icon(
                icon,
                contentDescription = label,
                tint = Color(0xFF7B68EE)
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            label,
            fontSize = 12.sp,
            color = Color.Gray
        )
    }
}

private fun getInsightIcon(type: InsightType): ImageVector {
    return when (type) {
        InsightType.NUTRITION -> Icons.Default.Restaurant
        InsightType.HYDRATION -> Icons.Default.WaterDrop
        InsightType.EXERCISE -> Icons.Default.DirectionsRun
        InsightType.WEIGHT -> Icons.Default.Monitor
        InsightType.SLEEP -> Icons.Default.Bedtime
        InsightType.GENERAL -> Icons.Default.TipsAndUpdates
    }
}

private fun getInsightColor(priority: InsightPriority): Color {
    return when (priority) {
        InsightPriority.HIGH -> Color(0xFFFF6B6B)
        InsightPriority.MEDIUM -> Color(0xFFFF9800)
        InsightPriority.LOW -> Color(0xFF4CAF50)
    }
}