package com.mochasmindlab.mlhealth.ui.screens

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochasmindlab.mlhealth.ui.components.MetricCard
import com.mochasmindlab.mlhealth.ui.components.AIInsightCard
import com.mochasmindlab.mlhealth.ui.theme.MLHealthTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    onNavigateToDiary: () -> Unit = {},
    onNavigateToMealPlan: () -> Unit = {},
    onNavigateToMore: () -> Unit = {}
) {
    var selectedTimeRange by remember { mutableStateOf("Week") }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            "Hello, Sarah!",
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
                    IconButton(onClick = { /* TODO: Notifications */ }) {
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
                listOf("Day", "Week", "Month").forEach { range ->
                    FilterChip(
                        selected = selectedTimeRange == range,
                        onClick = { selectedTimeRange = range },
                        label = { Text(range) }
                    )
                }
            }
            
            // AI Insights Section
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
                        TextButton(onClick = { /* TODO: View All */ }) {
                            Text("View All", color = Color(0xFF4A9B9B))
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    // Sample AI Insight
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(containerColor = Color.White)
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.TipsAndUpdates,
                                contentDescription = null,
                                tint = Color(0xFFFF9800),
                                modifier = Modifier.size(32.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    "Hydration Alert",
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    "You're 40% below your daily water goal",
                                    fontSize = 12.sp,
                                    color = Color.Gray
                                )
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
                    value = "1,847",
                    subtitle = "/ 2,200 kcal",
                    icon = Icons.Default.LocalFireDepartment,
                    color = Color(0xFFFF6B6B),
                    progress = 0.84f
                )
                
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Water",
                    value = "5",
                    subtitle = "/ 8 cups",
                    icon = Icons.Default.WaterDrop,
                    color = Color(0xFF4ECDC4),
                    progress = 0.625f
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
                    value = "45",
                    subtitle = "minutes",
                    icon = Icons.Default.DirectionsRun,
                    color = Color(0xFF7FB069),
                    progress = 0.75f
                )
                
                MetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Weight",
                    value = "165.5",
                    subtitle = "lbs",
                    icon = Icons.Default.Monitor,
                    color = Color(0xFF6C5CE7),
                    progress = 0.9f
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
                            onClick = { /* TODO */ }
                        )
                        QuickActionButton(
                            icon = Icons.Default.Add,
                            label = "Log Food",
                            onClick = onNavigateToDiary
                        )
                        QuickActionButton(
                            icon = Icons.Default.CalendarMonth,
                            label = "Plan",
                            onClick = onNavigateToMealPlan
                        )
                        QuickActionButton(
                            icon = Icons.Default.EmojiEvents,
                            label = "Goals",
                            onClick = onNavigateToMore
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun QuickActionButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
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