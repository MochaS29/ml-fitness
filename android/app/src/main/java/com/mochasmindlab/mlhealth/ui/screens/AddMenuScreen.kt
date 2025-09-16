package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMenuScreen(
    navController: NavController,
    onDismiss: () -> Unit
) {
    var showExerciseList by remember { mutableStateOf(false) }
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        contentColor = MaterialTheme.colorScheme.onSurface
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp)
        ) {
            // Title
            Text(
                "Quick Add",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp)
            )
            
            // Primary Actions
            AddMenuItem(
                icon = Icons.Default.Restaurant,
                title = "Log Food",
                subtitle = "Track meals and snacks",
                backgroundColor = NutritionGreen,
                onClick = {
                    onDismiss()
                    navController.navigate("food_entry")
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.LocalDrink,
                title = "Log Water",
                subtitle = "Track hydration",
                backgroundColor = HydrationBlue,
                onClick = {
                    onDismiss()
                    navController.navigate("water_intake")
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.FitnessCenter,
                title = "Log Exercise",
                subtitle = "Record workouts",
                backgroundColor = ExerciseGreen,
                onClick = {
                    showExerciseList = true
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.MonitorWeight,
                title = "Log Weight",
                subtitle = "Update body weight",
                backgroundColor = MindLabsPurple,
                onClick = {
                    onDismiss()
                    navController.navigate("weight_tracking")
                }
            )
            
            Divider(
                modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp)
            )
            
            // Secondary Actions
            AddMenuItem(
                icon = Icons.Default.Medication,
                title = "Log Supplements",
                subtitle = "Track vitamins & supplements",
                backgroundColor = SupplementPurple,
                onClick = {
                    onDismiss()
                    navController.navigate("supplements")
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.Timer,
                title = "Start Fasting",
                subtitle = "Begin intermittent fasting",
                backgroundColor = FastingOrange,
                onClick = {
                    onDismiss()
                    navController.navigate("fasting")
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.CameraAlt,
                title = "Scan Barcode",
                subtitle = "Quick food entry",
                backgroundColor = EnergeticOrange,
                onClick = {
                    onDismiss()
                    navController.navigate("barcode_scanner")
                }
            )
            
            AddMenuItem(
                icon = Icons.Default.BookmarkAdd,
                title = "Save Recipe",
                subtitle = "Add to recipe book",
                backgroundColor = MindfulTeal,
                onClick = {
                    onDismiss()
                    navController.navigate("add_recipe")
                }
            )
        }
    }
    
    // Exercise Selection Dialog
    if (showExerciseList) {
        ExerciseSelectionDialog(
            onDismiss = { showExerciseList = false },
            onExerciseSelected = { exerciseType ->
                showExerciseList = false
                onDismiss()
                // Navigate to exercise logging with the selected type
                navController.navigate("log_exercise/$exerciseType")
            }
        )
    }
}

@Composable
private fun AddMenuItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    backgroundColor: Color,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(horizontal = 24.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(backgroundColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon,
                contentDescription = title,
                tint = backgroundColor,
                modifier = Modifier.size(24.dp)
            )
        }
        
        Spacer(modifier = Modifier.width(16.dp))
        
        Column(modifier = Modifier.weight(1f)) {
            Text(
                title,
                fontWeight = FontWeight.Medium,
                fontSize = 16.sp
            )
            Text(
                subtitle,
                fontSize = 14.sp,
                color = Color.Gray
            )
        }
        
        Icon(
            Icons.Default.ChevronRight,
            contentDescription = null,
            tint = Color.Gray.copy(alpha = 0.5f)
        )
    }
}