package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.foundation.clickable
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochasmindlab.mlhealth.data.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuickSetupScreen(
    onSetupComplete: (userData: Map<String, Any>) -> Unit,
    onSkip: () -> Unit
) {
    var name by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var weight by remember { mutableStateOf("") }
    var height by remember { mutableStateOf("") }
    var selectedGender by remember { mutableStateOf(Gender.OTHER) }
    var selectedGoal by remember { mutableStateOf(GoalCategory.NUTRITION) }
    var isMetric by remember { mutableStateOf(true) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Quick Setup") },
                actions = {
                    TextButton(
                        onClick = onSkip,
                        colors = ButtonDefaults.textButtonColors(
                            contentColor = MaterialTheme.colorScheme.primary
                        )
                    ) {
                        Text(
                            "Skip",
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 24.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Welcome Text
            Text(
                "Welcome to MindLabs Fitness!",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(top = 16.dp)
            )
            
            Text(
                "Set up your profile for a personalized experience, or skip to explore the app.",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            // Name Input
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Name (Optional)") },
                leadingIcon = { Icon(Icons.Default.Person, contentDescription = null) },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true
            )
            
            // Age and Gender Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedTextField(
                    value = age,
                    onValueChange = { if (it.all { char -> char.isDigit() }) age = it },
                    label = { Text("Age") },
                    leadingIcon = { Icon(Icons.Default.Cake, contentDescription = null) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
                
                // Gender Selection
                Box(modifier = Modifier.weight(1f)) {
                    var expanded by remember { mutableStateOf(false) }
                    
                    OutlinedTextField(
                        value = selectedGender.name.lowercase().replaceFirstChar { it.uppercase() },
                        onValueChange = { },
                        label = { Text("Gender") },
                        readOnly = true,
                        trailingIcon = {
                            ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { expanded = !expanded }
                    )
                    
                    DropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        Gender.values().forEach { gender ->
                            DropdownMenuItem(
                                text = { Text(gender.name.lowercase().replaceFirstChar { it.uppercase() }) },
                                onClick = {
                                    selectedGender = gender
                                    expanded = false
                                }
                            )
                        }
                    }
                }
            }
            
            // Units Toggle
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Units", style = MaterialTheme.typography.bodyLarge)
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        FilterChip(
                            selected = isMetric,
                            onClick = { isMetric = true },
                            label = { Text("Metric") }
                        )
                        FilterChip(
                            selected = !isMetric,
                            onClick = { isMetric = false },
                            label = { Text("Imperial") }
                        )
                    }
                }
            }
            
            // Height and Weight Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedTextField(
                    value = height,
                    onValueChange = { if (it.all { char -> char.isDigit() || char == '.' }) height = it },
                    label = { Text(if (isMetric) "Height (cm)" else "Height (in)") },
                    leadingIcon = { Icon(Icons.Default.Height, contentDescription = null) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
                
                OutlinedTextField(
                    value = weight,
                    onValueChange = { if (it.all { char -> char.isDigit() || char == '.' }) weight = it },
                    label = { Text(if (isMetric) "Weight (kg)" else "Weight (lbs)") },
                    leadingIcon = { Icon(Icons.Default.FitnessCenter, contentDescription = null) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
            }
            
            // Goal Selection
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    "Primary Goal",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                
                // Goal chips in a grid
                val goals = listOf(
                    GoalCategory.WEIGHT_LOSS to Icons.Default.TrendingDown,
                    GoalCategory.WEIGHT_GAIN to Icons.Default.TrendingUp,
                    GoalCategory.NUTRITION to Icons.Default.Restaurant,
                    GoalCategory.EXERCISE to Icons.Default.FitnessCenter,
                    GoalCategory.HYDRATION to Icons.Default.WaterDrop,
                    GoalCategory.SLEEP to Icons.Default.Bedtime
                )
                
                Column(
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    goals.chunked(2).forEach { rowGoals ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            rowGoals.forEach { (goal, icon) ->
                                FilterChip(
                                    selected = selectedGoal == goal,
                                    onClick = { selectedGoal = goal },
                                    label = {
                                        Row(
                                            horizontalArrangement = Arrangement.spacedBy(4.dp),
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Icon(
                                                icon,
                                                contentDescription = null,
                                                modifier = Modifier.size(18.dp)
                                            )
                                            Text(
                                                goal.name.replace("_", " ")
                                                    .lowercase()
                                                    .replaceFirstChar { it.uppercase() }
                                            )
                                        }
                                    },
                                    modifier = Modifier.weight(1f)
                                )
                            }
                            if (rowGoals.size == 1) {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }
            }
            
            // Action Buttons
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 24.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Button(
                    onClick = {
                        val userData = mutableMapOf<String, Any>()
                        
                        if (name.isNotBlank()) userData["name"] = name
                        if (age.isNotBlank()) userData["age"] = age.toIntOrNull() ?: 25
                        if (weight.isNotBlank()) {
                            userData["weight"] = weight.toFloatOrNull() ?: 70f
                            userData["weightUnit"] = if (isMetric) WeightUnit.KG else WeightUnit.LBS
                        }
                        if (height.isNotBlank()) {
                            userData["height"] = height.toFloatOrNull() ?: 170f
                            userData["heightUnit"] = if (isMetric) HeightUnit.CM else HeightUnit.FEET_INCHES
                        }
                        userData["gender"] = selectedGender
                        userData["goalType"] = selectedGoal
                        userData["activityLevel"] = ActivityLevel.MODERATE
                        
                        onSetupComplete(userData)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    )
                ) {
                    Icon(Icons.Default.Check, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Complete Setup",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                
                TextButton(
                    onClick = onSkip,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                ) {
                    Text(
                        "Skip for Now",
                        fontSize = 16.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}